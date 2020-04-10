/*
 * hunt-proton: AMQP Protocol library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net/
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module hunt.proton.engine.impl.ConnectionImpl;

import hunt.collection.ArrayList;
import hunt.collection.Set;
import hunt.collection.List;
import hunt.collection.Map;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.transport.Open;
import hunt.proton.engine.Collector;
import hunt.proton.engine.EndpointState;
import hunt.proton.engine.Event;
import hunt.proton.engine.Link;
import hunt.proton.engine.ProtonJConnection;
import hunt.proton.engine.Session;
import hunt.proton.engine.Reactor;
import hunt.proton.engine.impl.EndpointImpl;
import hunt.proton.engine.impl.SessionImpl;
import hunt.proton.engine.impl.LinkNode;
import hunt.proton.engine.impl.LinkImpl;
import hunt.proton.engine.impl.DeliveryImpl;
import hunt.proton.engine.impl.TransportImpl;
import hunt.proton.engine.impl.CollectorImpl;
import hunt.proton.engine.impl.EndpointImplQuery;
import hunt.collection.Iterator;
import hunt.proton.engine.impl.EventImpl;
import hunt.proton.engine.ReactorChild;
import hunt.logging;


/**
 * 
 */
class ConnectionImpl : EndpointImpl, ProtonJConnection {
    static int MAX_CHANNELS = 65535;

    private List!SessionImpl _sessions; // = new ArrayList<SessionImpl>();
    private EndpointImpl _transportTail;
    private EndpointImpl _transportHead;
    private int _maxChannels; //= MAX_CHANNELS;

    private LinkNode!SessionImpl _sessionHead;
    private LinkNode!SessionImpl _sessionTail;

    private LinkNode!(LinkImpl) _linkHead;
    private LinkNode!(LinkImpl) _linkTail;

    private DeliveryImpl _workHead;
    private DeliveryImpl _workTail;

    private TransportImpl _transport;
    private DeliveryImpl _transportWorkHead;
    private DeliveryImpl _transportWorkTail;
    private int _transportWorkSize = 0;
    private string _localContainerId = "";
    private string _localHostname;
    private string _remoteContainer;
    private string _remoteHostname;
    private Symbol[] _offeredCapabilities;
    private Symbol[] _desiredCapabilities;
    private Symbol[] _remoteOfferedCapabilities;
    private Symbol[] _remoteDesiredCapabilities;
    private Map!(Symbol, Object) _properties;
    private Map!(Symbol, Object) _remoteProperties;

    private Object _context;
    private CollectorImpl _collector;
    private Reactor _reactor;

    private static Symbol[] EMPTY_SYMBOL_ARRAY;

    //static Symbol[]  EMPTY_SYMBOL_ARRAY () {
    //    __gshared Symbol[]  inst;
    //    return initOnce!inst(new TransportResultImpl(OK, null, null));
    //}
    /**
     * Application code should use {@link hunt.proton.engine.Connection.Factory#create()} instead.
     */
    this() {
        _maxChannels = MAX_CHANNELS;
        _sessions = new ArrayList!SessionImpl();
    }

    override SessionImpl session() {
        SessionImpl session = new SessionImpl(this);
        _sessions.add(session);

        return session;
    }

    override void free() {
        super.free();
    }

    override int opCmp(ReactorChild o) {
        ConnectionImpl other = cast(ConnectionImpl) o;
        return cast(int)(this._localContainerId.hashOf - other._localContainerId.hashOf);
    }

    void freeSession(SessionImpl session) {
        _sessions.remove(session);
    }

    LinkNode!SessionImpl addSessionEndpoint(SessionImpl endpoint) {
        LinkNode!SessionImpl node;
        if (_sessionHead is null) {
            node = _sessionHead = _sessionTail = LinkNode!SessionImpl.newList!SessionImpl(
                    endpoint);
        } else {
            node = _sessionTail = _sessionTail.addAtTail(endpoint);
        }
        return node;
    }

    void removeSessionEndpoint(LinkNode!SessionImpl node) {
        LinkNode!SessionImpl prev = node.getPrev();
        LinkNode!SessionImpl next = node.getNext();

        if (_sessionHead == node) {
            _sessionHead = next;
        }
        if (_sessionTail == node) {
            _sessionTail = prev;
        }
        node.remove();
    }

    LinkNode!LinkImpl addLinkEndpoint(LinkImpl endpoint) {
        LinkNode!LinkImpl node;
        if (_linkHead is null) {
            node = _linkHead = _linkTail = LinkNode!LinkImpl.newList!LinkImpl(endpoint);
        } else {
            node = _linkTail = _linkTail.addAtTail(endpoint);
        }
        return node;
    }

    void removeLinkEndpoint(LinkNode!LinkImpl node) {
        LinkNode!LinkImpl prev = node.getPrev();
        LinkNode!LinkImpl next = node.getNext();

        if (_linkHead == node) {
            _linkHead = next;
        }
        if (_linkTail == node) {
            _linkTail = prev;
        }
        node.remove();
    }

    override Session sessionHead(Set!EndpointState local, Set!EndpointState remote) {
        if (_sessionHead is null) {
            return null;
        } else {
            Query!SessionImpl query = new EndpointImplQuery!SessionImpl(local, remote);
            LinkNode!SessionImpl node = query.matches(_sessionHead)
                ? _sessionHead : _sessionHead.next(query);
            return node is null ? null : node.getValue();
        }
    }

    override Link linkHead(Set!EndpointState local, Set!EndpointState remote) {
        if (_linkHead is null) {
            return null;
        } else {
            Query!LinkImpl query = new EndpointImplQuery!LinkImpl(local, remote);
            LinkNode!LinkImpl node = query.matches(_linkHead) ? _linkHead : _linkHead.next(query);
            return node is null ? null : node.getValue();
        }
    }

    override protected ConnectionImpl getConnectionImpl() {
        return this;
    }

    override void postFinal() {
        put(Type.CONNECTION_FINAL, this);
    }

    override void doFree() {
        List!SessionImpl sessions = new ArrayList!SessionImpl(_sessions);
        foreach (SessionImpl session; sessions) {
            session.free();
        }
        _sessions = null;
    }

    void modifyEndpoints() {
        if (_sessions !is null) {
            foreach (SessionImpl ssn; _sessions) {
                ssn.modifyEndpoints();
            }
        }
        if (!freed) {
            modified();
        }
    }

    void handleOpen(Open open) {
        // TODO - store state
        setRemoteState(EndpointState.ACTIVE);
        setRemoteHostname(open.getHostname() is null ? null : open.getHostname().value);
        setRemoteContainer(open.getContainerId() is null ? null : open.getContainerId().value);
        if (open.getDesiredCapabilities() !is null) {
            setRemoteDesiredCapabilities(open.getDesiredCapabilities().toArray);
        }
        if (open.getOfferedCapabilities() !is null) {
            setRemoteOfferedCapabilities(open.getOfferedCapabilities().toArray);
        }
        setRemoteProperties(open.getProperties());
        put(Type.CONNECTION_REMOTE_OPEN, this);
    }

    EndpointImpl getTransportHead() {
        return _transportHead;
    }

    EndpointImpl getTransportTail() {
        return _transportTail;
    }

    void addModified(EndpointImpl endpoint) {
        if (_transportTail is null) {
            endpoint.setTransportNext(null);
            endpoint.setTransportPrev(null);
            _transportHead = _transportTail = endpoint;
        } else {
            _transportTail.setTransportNext(endpoint);
            endpoint.setTransportPrev(_transportTail);
            _transportTail = endpoint;
            _transportTail.setTransportNext(null);
        }
    }

    void removeModified(EndpointImpl endpoint) {
        if (_transportHead == endpoint) {
            _transportHead = endpoint.transportNext();
        } else {
            endpoint.transportPrev().setTransportNext(endpoint.transportNext());
        }

        if (_transportTail == endpoint) {
            _transportTail = endpoint.transportPrev();
        } else {
            endpoint.transportNext().setTransportPrev(endpoint.transportPrev());
        }
    }

    override int getMaxChannels() {
        return _maxChannels;
    }

    string getLocalContainerId() {
        return _localContainerId;
    }

    override void setLocalContainerId(string localContainerId) {
        _localContainerId = localContainerId;
    }

    override DeliveryImpl getWorkHead() {
        return _workHead;
    }

    override void setContainer(string container) {
        _localContainerId = container;
    }

    override string getContainer() {
        return _localContainerId;
    }

    override void setHostname(string hostname) {
        _localHostname = hostname;
    }

    override string getRemoteContainer() {
        return _remoteContainer;
    }

    override string getRemoteHostname() {
        return _remoteHostname;
    }

    override void setOfferedCapabilities(Symbol[] capabilities) {
        _offeredCapabilities = capabilities;
    }

    override void setDesiredCapabilities(Symbol[] capabilities) {
        _desiredCapabilities = capabilities;
    }

    override Symbol[] getRemoteOfferedCapabilities() {
        return _remoteOfferedCapabilities is null ? EMPTY_SYMBOL_ARRAY : _remoteOfferedCapabilities;
    }

    override Symbol[] getRemoteDesiredCapabilities() {
        return _remoteDesiredCapabilities is null ? EMPTY_SYMBOL_ARRAY : _remoteDesiredCapabilities;
    }

    Symbol[] getOfferedCapabilities() {
        return _offeredCapabilities;
    }

    Symbol[] getDesiredCapabilities() {
        return _desiredCapabilities;
    }

    void setRemoteOfferedCapabilities(Symbol[] remoteOfferedCapabilities) {
        _remoteOfferedCapabilities = remoteOfferedCapabilities;
    }

    void setRemoteDesiredCapabilities(Symbol[] remoteDesiredCapabilities) {
        _remoteDesiredCapabilities = remoteDesiredCapabilities;
    }

    Map!(Symbol, Object) getProperties() {
        return _properties;
    }

    override void setProperties(Map!(Symbol, Object) properties) {
        _properties = properties;
    }

    override Map!(Symbol, Object) getRemoteProperties() {
        return _remoteProperties;
    }

    void setRemoteProperties(Map!(Symbol, Object) remoteProperties) {
        _remoteProperties = remoteProperties;
    }

    override string getHostname() {
        return _localHostname;
    }

    void setRemoteContainer(string remoteContainerId) {
        _remoteContainer = remoteContainerId;
    }

    void setRemoteHostname(string remoteHostname) {
        _remoteHostname = remoteHostname;
    }

    DeliveryImpl getWorkTail() {
        return _workTail;
    }

    void removeWork(DeliveryImpl delivery) {
        if (!delivery._work)
            return;

        DeliveryImpl next = delivery.getWorkNext();
        DeliveryImpl prev = delivery.getWorkPrev();

        if (prev !is null) {
            prev.setWorkNext(next);
        }

        if (next !is null) {
            next.setWorkPrev(prev);
        }

        delivery.setWorkNext(null);
        delivery.setWorkPrev(null);

        if (_workHead == delivery) {
            _workHead = next;

        }

        if (_workTail == delivery) {
            _workTail = prev;
        }

        delivery._work = false;
    }

    void addWork(DeliveryImpl delivery) {
        if (delivery._work)
            return;

        delivery.setWorkNext(null);
        delivery.setWorkPrev(_workTail);

        if (_workTail !is null) {
            _workTail.setWorkNext(delivery);
        }

        _workTail = delivery;

        if (_workHead is null) {
            _workHead = delivery;
        }

        delivery._work = true;
    }

    Iterator!DeliveryImpl getWorkSequence() {
        return new WorkSequence(_workHead);
    }

    void setTransport(TransportImpl transport) {
        _transport = transport;
    }

    override TransportImpl getTransport() {
        return _transport;
    }

    class WorkSequence : Iterator!DeliveryImpl {
        private DeliveryImpl _next;

        this(DeliveryImpl workHead) {
            _next = workHead;
        }

        bool hasNext() {
            return _next !is null;
        }

        //override
        //void remove()
        //{
        //    import
        //   // throw new UnsupportedOperationException();
        //}

        DeliveryImpl next() {
            DeliveryImpl next = _next;
            if (next !is null) {
                _next = next.getWorkNext();
            }
            return next;
        }
    }

    DeliveryImpl getTransportWorkHead() {
        return _transportWorkHead;
    }

    int getTransportWorkSize() {
        return _transportWorkSize;
    }

    void removeTransportWork(DeliveryImpl delivery) {
        if (!delivery._transportWork)
            return;

        DeliveryImpl next = delivery.getTransportWorkNext();
        DeliveryImpl prev = delivery.getTransportWorkPrev();

        if (prev !is null) {
            prev.setTransportWorkNext(next);
        }

        if (next !is null) {
            next.setTransportWorkPrev(prev);
        }

        delivery.setTransportWorkNext(null);
        delivery.setTransportWorkPrev(null);

        if (_transportWorkHead == delivery) {
            _transportWorkHead = next;

        }

        if (_transportWorkTail == delivery) {
            _transportWorkTail = prev;
        }

        delivery._transportWork = false;
        _transportWorkSize--;
    }

    void addTransportWork(DeliveryImpl delivery) {
        modified();
        if (delivery._transportWork)
            return;

        delivery.setTransportWorkNext(null);
        delivery.setTransportWorkPrev(_transportWorkTail);

        if (_transportWorkTail !is null) {
            _transportWorkTail.setTransportWorkNext(delivery);
        }

        _transportWorkTail = delivery;

        if (_transportWorkHead is null) {
            _transportWorkHead = delivery;
        }

        delivery._transportWork = true;
        _transportWorkSize++;
    }

    void workUpdate(DeliveryImpl delivery) {
        if (delivery !is null) {
            if (!delivery.isSettled() && (delivery.isReadable()
                    || delivery.isWritable() || delivery.isUpdated())) {
                addWork(delivery);
            } else {
                removeWork(delivery);
            }
        }
    }

    override Object getContext() {
        return _context;
    }

    override void setContext(Object context) {
        _context = context;
    }

    override void collect(Collector collector) {
        _collector = cast(CollectorImpl) collector;

        put(Type.CONNECTION_INIT, this);

        LinkNode!SessionImpl ssn = _sessionHead;
        while (ssn !is null) {
            put(Type.SESSION_INIT, ssn.getValue());
            ssn = ssn.getNext();
        }

        LinkNode!LinkImpl lnk = _linkHead;
        while (lnk !is null) {
            put(Type.LINK_INIT, lnk.getValue());
            lnk = lnk.getNext();
        }
    }

    EventImpl put(Type type, Object context) {
        //logInfo("EventImpl put ############################### %d ", type.ordinal);
        if (_collector !is null) {
            // logInfo("EventImpl put in ###############################");
            return _collector.put(type, context);
        } else {
            return null;
        }
    }

    override void localOpen() {
        put(Type.CONNECTION_LOCAL_OPEN, this);
    }

    override void localClose() {
        put(Type.CONNECTION_LOCAL_CLOSE, this);
    }

    override Reactor getReactor() {
        return _reactor;
    }

    void setReactor(Reactor reactor) {
        _reactor = reactor;
    }
}
