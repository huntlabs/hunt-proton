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

module hunt.proton.engine.impl.LinkImpl;

import hunt.collection.Set;
import hunt.collection.Map;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.ReceiverSettleMode;
import hunt.proton.amqp.transport.SenderSettleMode;
import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.transport.Target;
import hunt.proton.engine.EndpointState;
import hunt.proton.engine.Event;
import hunt.proton.engine.Link;
import hunt.proton.engine.impl.EndpointImpl;
import hunt.proton.engine.impl.DeliveryImpl;
import hunt.proton.engine.impl.LinkNode;
import hunt.Exceptions;
import hunt.proton.engine.impl.SessionImpl;
import hunt.proton.engine.impl.ConnectionImpl;
import hunt.proton.engine.impl.TransportLink;
import hunt.collection.Set;
import hunt.proton.engine.impl.EndpointImplQuery;
import hunt.proton.engine.impl.SenderImpl;

class LinkImpl : EndpointImpl , Link
{

    private  SessionImpl _session;

    DeliveryImpl _head;
    DeliveryImpl _tail;
    DeliveryImpl _current;
    private string _name;
    private Source _source;
    private Source _remoteSource;
    private Target _target;
    private Target _remoteTarget;
    private int _queued;
    private int _credit;
    private int _unsettled;
    private int _drained;
    private UnsignedLong _maxMessageSize;
    private UnsignedLong _remoteMaxMessageSize;

    private SenderSettleMode _senderSettleMode;
    private SenderSettleMode _remoteSenderSettleMode;
    private ReceiverSettleMode _receiverSettleMode;
    private ReceiverSettleMode _remoteReceiverSettleMode;


    private LinkNode!(LinkImpl) _node;
    private bool _drain;
    private bool _detached;
    private Map!(Symbol, Object) _properties;
    private Map!(Symbol, Object) _remoteProperties;
    private Symbol[] _offeredCapabilities;
    private Symbol[] _remoteOfferedCapabilities;
    private Symbol[] _desiredCapabilities;
    private Symbol[] _remoteDesiredCapabilities;

    this(SessionImpl session, string name)
    {
        _session = session;
        _session.incref();
        _name = name;
        ConnectionImpl conn = session.getConnectionImpl();
        _node = conn.addLinkEndpoint(this);
        conn.put(Type.LINK_INIT, this);
    }


    public string getName()
    {
        return _name;
    }

    public DeliveryImpl delivery(byte[] tag)
    {
        return delivery(tag, 0, cast(int)tag.length);
    }

    public DeliveryImpl delivery(byte[] tag, int offset, int length)
    {
        if (offset != 0 || length != tag.length)
        {
            throw new IllegalArgumentException("At present delivery tag must be the whole byte array");
        }
        incrementQueued();
        try
        {
            DeliveryImpl delivery = new DeliveryImpl(tag, this, _tail);
            if (_tail is null)
            {
                _head = delivery;
            }
            _tail = delivery;
            if (_current is null)
            {
                _current = delivery;
            }
            getConnectionImpl().workUpdate(delivery);
            return delivery;
        }
        catch (RuntimeException e)
        {
            //e.printStackTrace();
            //throw e;
        }
        return null;
    }

    override
    void postFinal() {
        _session.getConnectionImpl().put(Type.LINK_FINAL, this);
        _session.decref();
    }

    override
    void doFree()
    {
        DeliveryImpl dlv = _head;
        while (dlv !is null) {
            DeliveryImpl next = dlv.next();
            dlv.free();
            dlv = next;
        }

        _session.getConnectionImpl().removeLinkEndpoint(_node);
        _node = null;
    }

    void modifyEndpoints() {
        modified();
    }

    /*
     * Called when settling a message to ensure that the head/tail refs of the link are updated.
     * The caller ensures the delivery updates its own refs appropriately.
     */
    void remove(DeliveryImpl delivery)
    {
        if(_head == delivery)
        {
            _head = delivery.getLinkNext();
        }
        if(_tail == delivery)
        {
            _tail = delivery.getLinkPrevious();
        }
    }

    public DeliveryImpl current()
    {
        return _current;
    }

    public bool advance()
    {
        if(_current !is null )
        {
            DeliveryImpl oldCurrent = _current;
            _current = _current.getLinkNext();
            getConnectionImpl().workUpdate(oldCurrent);

            if(_current !is null)
            {
                getConnectionImpl().workUpdate(_current);
            }
            return true;
        }
        else
        {
            return false;
        }

    }

    override
    public ConnectionImpl getConnectionImpl()
    {
        return _session.getConnectionImpl();
    }

    public SessionImpl getSession()
    {
        return _session;
    }

    public Source getRemoteSource()
    {
        return _remoteSource;
    }

    void setRemoteSource(Source source)
    {
        _remoteSource = source;
    }

    public Target getRemoteTarget()
    {
        return _remoteTarget;
    }

    void setRemoteTarget(Target target)
    {
        _remoteTarget = target;
    }

    public Source getSource()
    {
        return _source;
    }

    public void setSource(Source source)
    {
        // TODO - should be an error if local state is ACTIVE
        _source = source;
    }

    public Target getTarget()
    {
        return _target;
    }

    public void setTarget(Target target)
    {
        // TODO - should be an error if local state is ACTIVE
        _target = target;
    }

    public Link next(Set!EndpointState local, Set!EndpointState remote)
    {
        Query!LinkImpl query = new EndpointImplQuery!LinkImpl(local, remote);

        LinkNode!LinkImpl linkNode = _node.next(query);

        return linkNode is null ? null : linkNode.getValue();

    }

    abstract TransportLink getTransportLink();

    public int getCredit()
    {
        return _credit;
    }

    public void addCredit(int credit)
    {
        _credit+=credit;
    }

    public void setCredit(int credit)
    {
        _credit = credit;
    }

    bool hasCredit()
    {
        return _credit > 0;
    }

    void incrementCredit()
    {
        _credit++;
    }

    void decrementCredit()
    {
        _credit--;
    }

    public int getQueued()
    {
        return _queued;
    }

    void incrementQueued()
    {
        _queued++;
    }

    void decrementQueued()
    {
        _queued--;
    }

    public int getUnsettled()
    {
        return _unsettled;
    }

    void incrementUnsettled()
    {
        _unsettled++;
    }

    void decrementUnsettled()
    {
        _unsettled--;
    }

    void setDrain(bool drain)
    {
        _drain = drain;
    }

    override
    public bool getDrain()
    {
        return _drain;
    }

    override
    public SenderSettleMode getSenderSettleMode()
    {
        return _senderSettleMode;
    }

    override
    public void setSenderSettleMode(SenderSettleMode senderSettleMode)
    {
        _senderSettleMode = senderSettleMode;
    }

    override
    public SenderSettleMode getRemoteSenderSettleMode()
    {
        return _remoteSenderSettleMode;
    }

    override
    public void setRemoteSenderSettleMode(SenderSettleMode remoteSenderSettleMode)
    {
        _remoteSenderSettleMode = remoteSenderSettleMode;
    }

    override
    public ReceiverSettleMode getReceiverSettleMode()
    {
        return _receiverSettleMode;
    }

    override
    public void setReceiverSettleMode(ReceiverSettleMode receiverSettleMode)
    {
        _receiverSettleMode = receiverSettleMode;
    }

    override
    public ReceiverSettleMode getRemoteReceiverSettleMode()
    {
        return _remoteReceiverSettleMode;
    }

    void setRemoteReceiverSettleMode(ReceiverSettleMode remoteReceiverSettleMode)
    {
        _remoteReceiverSettleMode = remoteReceiverSettleMode;
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

    override
    public UnsignedLong getMaxMessageSize()
    {
        return _maxMessageSize;
    }

    override
    public void setMaxMessageSize(UnsignedLong maxMessageSize)
    {
        _maxMessageSize = maxMessageSize;
    }

    override
    public UnsignedLong getRemoteMaxMessageSize()
    {
        return _remoteMaxMessageSize;
    }

    void setRemoteMaxMessageSize(UnsignedLong remoteMaxMessageSize)
    {
        _remoteMaxMessageSize = remoteMaxMessageSize;
    }

    override
    public int drained()
    {
        int drained = 0;

        if (cast(SenderImpl)this !is null) {
            if(getDrain() && hasCredit())
            {
                _drained = getCredit();
                setCredit(0);
                modified();
                drained = _drained;
            }
        } else {
            drained = _drained;
            _drained = 0;
        }

        return drained;
    }

    int getDrained()
    {
        return _drained;
    }

    void setDrained(int value)
    {
        _drained = value;
    }

    override
    public DeliveryImpl head()
    {
        return _head;
    }

    override
    void localOpen()
    {
        getConnectionImpl().put(Type.LINK_LOCAL_OPEN, this);
    }

    override
    void localClose()
    {
        getConnectionImpl().put(Type.LINK_LOCAL_CLOSE, this);
    }

    override
    public void detach()
    {
        _detached = true;
        getConnectionImpl().put(Type.LINK_LOCAL_DETACH, this);
        modified();
    }

    public bool detached()
    {
        return _detached;
    }
}
