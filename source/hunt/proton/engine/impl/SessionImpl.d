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

module hunt.proton.engine.impl.SessionImpl;

import hunt.collection.ArrayList;
import hunt.collection.Set;
import hunt.collection.LinkedHashMap;
import hunt.collection.List;
import hunt.collection.Map;

import hunt.proton.engine.impl.EndpointImplQuery;
import hunt.proton.amqp.Symbol;
import hunt.proton.engine.EndpointState;
import hunt.proton.engine.Event;
import hunt.proton.engine.ProtonJSession;
import hunt.proton.engine.Session;
import hunt.proton.engine.impl.EndpointImpl;
import hunt.proton.engine.impl.ConnectionImpl;
import hunt.proton.engine.impl.SenderImpl;
import hunt.proton.engine.impl.ReceiverImpl;
import hunt.proton.engine.impl.LinkImpl;
import hunt.proton.engine.impl.TransportSession;
import hunt.proton.engine.impl.LinkNode;
import hunt.Exceptions;
import std.conv: to;
import hunt.logging;
class SessionImpl : EndpointImpl , ProtonJSession
{
    private ConnectionImpl _connection;

    private Map!(string, SenderImpl) _senders ;// = new LinkedHashMap<string, SenderImpl>();
    private Map!(string, ReceiverImpl)  _receivers  ;//= new LinkedHashMap<String, ReceiverImpl>();
    private List!LinkImpl _oldLinksToFree  ;// = new ArrayList<LinkImpl>();
    private TransportSession _transportSession;
    private int _incomingCapacity = 0;
    private int _incomingBytes = 0;
    private int _outgoingBytes = 0;
    private int _incomingDeliveries = 0;
    private int _outgoingDeliveries = 0;
    private long _outgoingWindow = 2147483647;
    private Map!(Symbol, Object) _properties;
    private Map!(Symbol, Object) _remoteProperties;
    private Symbol[] _offeredCapabilities;
    private Symbol[] _remoteOfferedCapabilities;
    private Symbol[] _desiredCapabilities;
    private Symbol[] _remoteDesiredCapabilities;

    private LinkNode!SessionImpl _node;


    this(ConnectionImpl connection)
    {
        _senders = new LinkedHashMap!(string, SenderImpl)();
        _receivers = new LinkedHashMap!(string, ReceiverImpl)();
        _oldLinksToFree = new ArrayList!LinkImpl;

        _connection = connection;
        _connection.incref();
        _node = _connection.addSessionEndpoint(this);
        _connection.put(Type.SESSION_INIT, this);
    }

    override
    public SenderImpl sender(string name)
    {
        SenderImpl sender = _senders.get(name);
        if(sender is null)
        {
            sender = new SenderImpl(this, name);
            _senders.put(name, sender);
        }
        else
        {
            if(sender.getLocalState() == EndpointState.CLOSED
                  && sender.getRemoteState() == EndpointState.CLOSED)
            {
                _oldLinksToFree.add(sender);

                sender = new SenderImpl(this, name);
                _senders.put(name, sender);
            }
        }
        return sender;
    }

    override
    public ReceiverImpl receiver(string name)
    {
        ReceiverImpl receiver = _receivers.get(name);
        if(receiver is null)
        {
            receiver = new ReceiverImpl(this, name);
            _receivers.put(name, receiver);
        }
        else
        {
            if(receiver.getLocalState() == EndpointState.CLOSED
                  && receiver.getRemoteState() == EndpointState.CLOSED)
            {
                _oldLinksToFree.add(receiver);

                receiver = new ReceiverImpl(this, name);
                _receivers.put(name, receiver);
            }
        }
        return receiver;
    }

    override
    public Session next(Set!EndpointState local, Set!EndpointState remote)
    {
        Query!SessionImpl query = new EndpointImplQuery!SessionImpl(local, remote);

        LinkNode!SessionImpl sessionNode = _node.next(query);

        return sessionNode is null ? null : sessionNode.getValue();
    }

    override
    public ConnectionImpl getConnectionImpl()
    {
        return _connection;
    }

    override
    public ConnectionImpl getConnection()
    {
        return getConnectionImpl();
    }

    override
    void postFinal() {
        _connection.put(Type.SESSION_FINAL, this);
        _connection.decref();
    }

    override
    void doFree() {
        _connection.freeSession(this);
        _connection.removeSessionEndpoint(_node);
        _node = null;

        List!SenderImpl senders = new ArrayList!SenderImpl(_senders.values());
        foreach(SenderImpl sender ; senders) {
            sender.free();
        }
        _senders.clear();

        List!ReceiverImpl receivers = new ArrayList!ReceiverImpl(_receivers.values());
        foreach(ReceiverImpl receiver ; receivers) {
            receiver.free();
        }
        _receivers.clear();

        List!LinkImpl links = new ArrayList!LinkImpl(_oldLinksToFree);
        foreach(LinkImpl link ; links) {
            link.free();
        }
    }

    void modifyEndpoints() {
        foreach (SenderImpl snd ; _senders.values()) {
            snd.modifyEndpoints();
        }

        foreach (ReceiverImpl rcv ; _receivers.values()) {
            rcv.modifyEndpoints();
        }
        modified();
    }

    TransportSession getTransportSession()
    {
        return _transportSession;
    }

    void setTransportSession(TransportSession transportSession)
    {
        _transportSession = transportSession;
    }

    void setNode(LinkNode!SessionImpl node)
    {
        _node = node;
    }

    void freeSender(SenderImpl sender)
    {
        string name = sender.getName();
        SenderImpl existing = _senders.get(name);
        if (sender is (existing))
        {
            _senders.remove(name);
        }
        else
        {
            _oldLinksToFree.remove(sender);
        }
    }

    void freeReceiver(ReceiverImpl receiver)
    {
        string name = receiver.getName();
        ReceiverImpl existing = _receivers.get(name);
        if (receiver is (existing))
        {
            _receivers.remove(name);
        }
        else
        {
            _oldLinksToFree.remove(receiver);
        }
    }

    override
    public int getIncomingCapacity()
    {
        return _incomingCapacity;
    }

    override
    public void setIncomingCapacity(int capacity)
    {
        _incomingCapacity = capacity;
    }

    override
    public int getIncomingBytes()
    {
        return _incomingBytes;
    }

    void incrementIncomingBytes(int delta)
    {
        _incomingBytes += delta;
    }

    override
    public int getOutgoingBytes()
    {
        return _outgoingBytes;
    }

    void incrementOutgoingBytes(int delta)
    {
        _outgoingBytes += delta;
    }

    void incrementIncomingDeliveries(int delta)
    {
        _incomingDeliveries += delta;
    }

    int getOutgoingDeliveries()
    {
        return _outgoingDeliveries;
    }

    void incrementOutgoingDeliveries(int delta)
    {
        _outgoingDeliveries += delta;
    }

    override
    void localOpen()
    {
        getConnectionImpl().put(Type.SESSION_LOCAL_OPEN, this);
    }

    override
    void localClose()
    {
        getConnectionImpl().put(Type.SESSION_LOCAL_CLOSE, this);
    }

    override
    public void setOutgoingWindow(long outgoingWindow) {
        if(outgoingWindow < 0 || outgoingWindow > 0xFFFFFFFFL)
        {
            throw new IllegalArgumentException("Value '" ~ to!string(outgoingWindow) ~ "' must be in the"
                    ~ " range [0 - 2^32-1]");
        }
        logInfo("!!!!!!!!!!!!!!!!!!!setOutgoingWindow!!!!!!!!!!!!!!!!!!! %d",outgoingWindow);
        _outgoingWindow = outgoingWindow;
    }

    override
    public long getOutgoingWindow()
    {
        return _outgoingWindow;
    }

    override
    public Map!(Symbol, Object) getProperties()
    {
        return _properties;
    }

    override
    public void setProperties(Map!(Symbol, Object) properties)
    {
        _properties = properties;
    }

    override
    public Map!(Symbol, Object) getRemoteProperties()
    {
        return _remoteProperties;
    }

    void setRemoteProperties(Map!(Symbol, Object) remoteProperties)
    {
        _remoteProperties = remoteProperties;
    }

    override
    public Symbol[] getDesiredCapabilities()
    {
        return _desiredCapabilities;
    }

    override
    public void setDesiredCapabilities(Symbol[] desiredCapabilities)
    {
        _desiredCapabilities = desiredCapabilities;
    }

    override
    public Symbol[] getRemoteDesiredCapabilities()
    {
        return _remoteDesiredCapabilities;
    }

    void setRemoteDesiredCapabilities(Symbol[] remoteDesiredCapabilities)
    {
        _remoteDesiredCapabilities = remoteDesiredCapabilities;
    }

    override
    public Symbol[] getOfferedCapabilities()
    {
        return _offeredCapabilities;
    }

    override
    public void setOfferedCapabilities(Symbol[] offeredCapabilities)
    {
        _offeredCapabilities = offeredCapabilities;
    }

    override
    public Symbol[] getRemoteOfferedCapabilities()
    {
        return _remoteOfferedCapabilities;
    }

    void setRemoteOfferedCapabilities(Symbol[] remoteOfferedCapabilities)
    {
        _remoteOfferedCapabilities = remoteOfferedCapabilities;
    }
}
