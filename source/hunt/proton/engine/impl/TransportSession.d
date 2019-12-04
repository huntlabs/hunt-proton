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

module hunt.proton.engine.impl.TransportSession;

import hunt.collection.HashMap;
import hunt.collection.Map;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.transport.Disposition;
import hunt.proton.amqp.transport.Flow;
import hunt.proton.amqp.transport.Role;
import hunt.proton.amqp.transport.Transfer;
import hunt.proton.engine.Event;
import std.concurrency : initOnce;
import hunt.proton.engine.impl.TransportImpl;
import hunt.proton.engine.impl.SessionImpl;
import hunt.proton.engine.impl.TransportLink;
import hunt.proton.engine.impl.DeliveryImpl;
import hunt.proton.engine.impl.TransportReceiver;
import hunt.Exceptions;
import hunt.proton.engine.impl.ReceiverImpl;
import hunt.proton.engine.impl.TransportDelivery;
import hunt.Boolean;

class TransportSession
{
    private static int HANDLE_MAX = 65535;
    //private static UnsignedInteger DEFAULT_WINDOW_SIZE = UnsignedInteger.valueOf(2147483647); // biggest legal value

     static UnsignedInteger  DEFAULT_WINDOW_SIZE() {
         __gshared UnsignedInteger  inst;
         return initOnce!inst(UnsignedInteger.valueOf(2147483647));
     }

    //static UnsignedInteger  _handleMax() {
    //    __gshared UnsignedInteger  inst;
    //    return initOnce!inst(UnsignedInteger.valueOf(HANDLE_MAX));
    //}
    //
    // static UnsignedInteger  _outgoingDeliveryId() {
    //     __gshared UnsignedInteger  inst;
    //     return initOnce!inst(UnsignedInteger.ZERO);
    // }
    //
    //static UnsignedInteger  _incomingWindowSize() {
    //    __gshared UnsignedInteger  inst;
    //    return initOnce!inst(UnsignedInteger.ZERO);
    //}
    //
    // static UnsignedInteger  _outgoingWindowSize() {
    //     __gshared UnsignedInteger  inst;
    //     return initOnce!inst(UnsignedInteger.ZERO);
    // }
    //
    //static UnsignedInteger  _nextOutgoingId() {
    //    __gshared UnsignedInteger  inst;
    //    return initOnce!inst(UnsignedInteger.ONE);
    //}

    private TransportImpl _transport;
    private SessionImpl _session;
    private int _localChannel = -1;
    private int _remoteChannel = -1;
    private bool _openSent;
    private UnsignedInteger _handleMax ;//= UnsignedInteger.valueOf(HANDLE_MAX); //TODO: should this be configurable?
    // This is used for the delivery-id actually stamped in each transfer frame of a given message delivery.
    private UnsignedInteger _outgoingDeliveryId ;//= UnsignedInteger.ZERO;
     //These are used for the session windows communicated via Begin/Flow frames
     //and the conceptual transfer-id relating to updating them.
    private UnsignedInteger _incomingWindowSize ;//= UnsignedInteger.ZERO;
    private UnsignedInteger _outgoingWindowSize ;//= UnsignedInteger.ZERO;
    private UnsignedInteger _nextOutgoingId  ;//UnsignedInteger.ONE;
    private UnsignedInteger _nextIncomingId = null;

    private Map!(UnsignedInteger, TransportLink) _remoteHandlesMap ;// = new HashMap<UnsignedInteger, TransportLink<?>>();
    private Map!(UnsignedInteger, TransportLink) _localHandlesMap ;// = new HashMap<UnsignedInteger, TransportLink<?>>();
    private Map!(string, TransportLink) _halfOpenLinks  ;//= new HashMap<String, TransportLink>();


    private UnsignedInteger _incomingDeliveryId = null;
    private UnsignedInteger _remoteIncomingWindow;
    private UnsignedInteger _remoteOutgoingWindow;
    private UnsignedInteger _remoteNextIncomingId ;//= _nextOutgoingId;
    private UnsignedInteger _remoteNextOutgoingId;
    private Map!(UnsignedInteger, DeliveryImpl) _unsettledIncomingDeliveriesById  ;//= new HashMap<UnsignedInteger, DeliveryImpl>();
    private Map!(UnsignedInteger, DeliveryImpl) _unsettledOutgoingDeliveriesById ;// = new HashMap<UnsignedInteger, DeliveryImpl>();
    private int _unsettledIncomingSize;
    private bool _endReceived;
    private bool _beginSent;


    this(TransportImpl transport, SessionImpl session)
    {
        _transport = transport;
        _session = session;
        _outgoingWindowSize = UnsignedInteger.valueOf(session.getOutgoingWindow());

        _handleMax = UnsignedInteger.valueOf(HANDLE_MAX);
        _outgoingDeliveryId = UnsignedInteger.ZERO;
        _incomingWindowSize = UnsignedInteger.ZERO;
       //
        // _outgoingWindowSize = UnsignedInteger.ZERO;
        _nextOutgoingId = UnsignedInteger.ONE;

        _remoteNextIncomingId = _nextOutgoingId;
        _remoteHandlesMap = new HashMap!(UnsignedInteger, TransportLink)();
        _localHandlesMap = new HashMap!(UnsignedInteger, TransportLink)();
         _halfOpenLinks = new HashMap!(string, TransportLink)();
        _unsettledIncomingDeliveriesById = new HashMap!(UnsignedInteger, DeliveryImpl)();
        _unsettledOutgoingDeliveriesById = new HashMap!(UnsignedInteger, DeliveryImpl)();
    }

    void unbind()
    {
        unsetLocalChannel();
        unsetRemoteChannel();
    }

    public SessionImpl getSession()
    {
        return _session;
    }

    public int getLocalChannel()
    {
        return _localChannel;
    }

    public void setLocalChannel(int localChannel)
    {
        if (!isLocalChannelSet()) {
            _session.incref();
        }
        _localChannel = localChannel;
    }

    public int getRemoteChannel()
    {
        return _remoteChannel;
    }

    public void setRemoteChannel(int remoteChannel)
    {
        if (!isRemoteChannelSet()) {
            _session.incref();
        }
        _remoteChannel = remoteChannel;
    }

    public bool isOpenSent()
    {
        return _openSent;
    }

    public void setOpenSent(bool openSent)
    {
        _openSent = openSent;
    }

    public bool isRemoteChannelSet()
    {
        return _remoteChannel != -1;
    }

    public bool isLocalChannelSet()
    {
        return _localChannel != -1;
    }

    public void unsetLocalChannel()
    {
        if (isLocalChannelSet()) {
            unsetLocalHandles();
            _session.decref();
        }
        _localChannel = -1;
    }

    private void unsetLocalHandles()
    {
        foreach (TransportLink tl ; _localHandlesMap.values())
        {
            tl.clearLocalHandle();
        }
        _localHandlesMap.clear();
    }

    public void unsetRemoteChannel()
    {
        if (isRemoteChannelSet()) {
            unsetRemoteHandles();
            _session.decref();
        }
        _remoteChannel = -1;
    }

    private void unsetRemoteHandles()
    {
        foreach (TransportLink tl ; _remoteHandlesMap.values())
        {
            tl.clearRemoteHandle();
        }
        _remoteHandlesMap.clear();
    }

    public UnsignedInteger getHandleMax()
    {
        return _handleMax;
    }

    public UnsignedInteger getIncomingWindowSize()
    {
        return _incomingWindowSize;
    }

    void updateIncomingWindow()
    {
        int incomingCapacity = _session.getIncomingCapacity();
        int size = _transport.getMaxFrameSize();
        if (incomingCapacity <= 0 || size <= 0) {
            _incomingWindowSize = DEFAULT_WINDOW_SIZE;
        } else {
            _incomingWindowSize = UnsignedInteger.valueOf((incomingCapacity - _session.getIncomingBytes())/size);
        }
    }

    public UnsignedInteger getOutgoingDeliveryId()
    {
        return _outgoingDeliveryId;
    }

    void incrementOutgoingDeliveryId()
    {
        _outgoingDeliveryId = _outgoingDeliveryId.add(UnsignedInteger.ONE);
    }

    public UnsignedInteger getOutgoingWindowSize()
    {
        return _outgoingWindowSize;
    }

    public UnsignedInteger getNextOutgoingId()
    {
        return _nextOutgoingId;
    }

    public TransportLink getLinkFromRemoteHandle(UnsignedInteger handle)
    {
        return _remoteHandlesMap.get(handle);
    }

    public UnsignedInteger allocateLocalHandle(TransportLink transportLink)
    {
        for(int i = 0; i <= HANDLE_MAX; i++)
        {
            UnsignedInteger handle = UnsignedInteger.valueOf(i);
            if(!_localHandlesMap.containsKey(handle))
            {
                _localHandlesMap.put(handle, transportLink);
                transportLink.setLocalHandle(handle);
                return handle;
            }
        }
        throw new IllegalStateException("no local handle available for allocation");
    }

    public void addLinkRemoteHandle(TransportLink link, UnsignedInteger remoteHandle)
    {
        _remoteHandlesMap.put(remoteHandle, link);
    }

    public void addLinkLocalHandle(TransportLink link, UnsignedInteger localhandle)
    {
        _localHandlesMap.put(localhandle, link);
    }

    public void freeLocalHandle(UnsignedInteger handle)
    {
        _localHandlesMap.remove(handle);
    }

    public void freeRemoteHandle(UnsignedInteger handle)
    {
        _remoteHandlesMap.remove(handle);
    }

    public TransportLink resolveHalfOpenLink(string name)
    {
        return _halfOpenLinks.remove(name);
    }

    public void addHalfOpenLink(TransportLink link)
    {
        _halfOpenLinks.put(link.getName(), link);
    }

    public void handleTransfer(Transfer transfer, Binary payload)
    {
        DeliveryImpl delivery;
        incrementNextIncomingId(); // The conceptual/non-wire transfer-id, for the session window.

        TransportReceiver transportReceiver = cast(TransportReceiver) getLinkFromRemoteHandle(transfer.getHandle());
        UnsignedInteger linkIncomingDeliveryId = transportReceiver.getIncomingDeliveryId();
        UnsignedInteger deliveryId = transfer.getDeliveryId();

        if(linkIncomingDeliveryId !is null && (linkIncomingDeliveryId == (deliveryId) || deliveryId is null))
        {
            delivery = _unsettledIncomingDeliveriesById.get(linkIncomingDeliveryId);
            delivery.getTransportDelivery().incrementSessionSize();
        }
        else
        {
            verifyNewDeliveryIdSequence(_incomingDeliveryId, linkIncomingDeliveryId, deliveryId);

            _incomingDeliveryId = deliveryId;

            ReceiverImpl receiver = transportReceiver.getReceiver();
            Binary deliveryTag = transfer.getDeliveryTag();
            delivery = receiver.delivery(deliveryTag.getArray(), deliveryTag.getArrayOffset(),
                                                      deliveryTag.getLength());
            UnsignedInteger messageFormat = transfer.getMessageFormat();
            if(messageFormat !is null) {
                delivery.setMessageFormat(messageFormat.intValue());
            }
            TransportDelivery transportDelivery = new TransportDelivery(deliveryId, delivery, transportReceiver);
            delivery.setTransportDelivery(transportDelivery);
            transportReceiver.setIncomingDeliveryId(deliveryId);
            _unsettledIncomingDeliveriesById.put(deliveryId, delivery);
            getSession().incrementIncomingDeliveries(1);
        }

        if( transfer.getState()!is null )
        {
            delivery.setRemoteDeliveryState(transfer.getState());
        }
        _unsettledIncomingSize++;

        bool aborted = transfer.getAborted().booleanValue;
        if (payload !is null && !aborted)
        {
            delivery.append(payload);
            getSession().incrementIncomingBytes(payload.getLength());
        }

        delivery.updateWork();

        if(!transfer.getMore().booleanValue || aborted)
        {
            transportReceiver.setIncomingDeliveryId(null);
            if(aborted) {
                delivery.setAborted();
            } else {
                delivery.setComplete();
            }

            delivery.getLink().getTransportLink().decrementLinkCredit();
            delivery.getLink().getTransportLink().incrementDeliveryCount();
        }

        if(Boolean.TRUE == (transfer.getSettled()) || aborted)
        {
            delivery.setRemoteSettled(true);
        }

        _incomingWindowSize = _incomingWindowSize.subtract(UnsignedInteger.ONE);

        // this will cause a flow to happen
        if (_incomingWindowSize == (UnsignedInteger.ZERO)) {
            delivery.getLink().modified(false);
        }

        getSession().getConnection().put(Type.DELIVERY, delivery);
    }

    private void verifyNewDeliveryIdSequence(UnsignedInteger previousId, UnsignedInteger linkIncomingId, UnsignedInteger newDeliveryId) {
        if(newDeliveryId is null) {
            throw new IllegalStateException("No delivery-id specified on first Transfer of new delivery");
        }

        // Doing a primitive comparison, uses intValue() since its a uint sequence
        // and we need the primitive values to wrap appropriately during comparison.
        if(previousId !is null && previousId.intValue() + 1 != newDeliveryId.intValue()) {
            throw new IllegalStateException("Expected delivery-id " );
        }

        if(linkIncomingId !is null) {
            throw new IllegalStateException("Illegal multiplex of deliveries on same link with delivery-id ");
        }
    }

    public void freeLocalChannel()
    {
        unsetLocalChannel();
    }

    public void freeRemoteChannel()
    {
        unsetRemoteChannel();
    }

    private void setRemoteIncomingWindow(UnsignedInteger incomingWindow)
    {
        _remoteIncomingWindow = incomingWindow;
    }

    void decrementRemoteIncomingWindow()
    {
        _remoteIncomingWindow = _remoteIncomingWindow.subtract(UnsignedInteger.ONE);
    }

    private void setRemoteOutgoingWindow(UnsignedInteger outgoingWindow)
    {
        _remoteOutgoingWindow = outgoingWindow;
    }

    void handleFlow(Flow flow)
    {
        UnsignedInteger inext = flow.getNextIncomingId();
        UnsignedInteger iwin = flow.getIncomingWindow();

        if(inext !is null)
        {
            setRemoteNextIncomingId(inext);
            setRemoteIncomingWindow(inext.add(iwin).subtract(_nextOutgoingId));
        }
        else
        {
            setRemoteIncomingWindow(iwin);
        }
        setRemoteNextOutgoingId(flow.getNextOutgoingId());
        setRemoteOutgoingWindow(flow.getOutgoingWindow());

        if(flow.getHandle() !is null)
        {
            TransportLink transportLink = getLinkFromRemoteHandle(flow.getHandle());
            transportLink.handleFlow(flow);


        }
    }

    private void setRemoteNextOutgoingId(UnsignedInteger nextOutgoingId)
    {
        _remoteNextOutgoingId = nextOutgoingId;
    }

    private void setRemoteNextIncomingId(UnsignedInteger remoteNextIncomingId)
    {
        _remoteNextIncomingId = remoteNextIncomingId;
    }

    void handleDisposition(Disposition disposition)
    {
        UnsignedInteger id = disposition.getFirst();
        UnsignedInteger last = disposition.getLast() is null ? id : disposition.getLast();
        Map!(UnsignedInteger, DeliveryImpl) unsettledDeliveries =
                disposition.getRole() == Role.RECEIVER ? _unsettledOutgoingDeliveriesById
                        : _unsettledIncomingDeliveriesById;

        while(id <= (last))
        {
            DeliveryImpl delivery = unsettledDeliveries.get(id);
            if(delivery !is null)
            {
                if(disposition.getState() !is null)
                {
                    delivery.setRemoteDeliveryState(disposition.getState());
                }
                if(Boolean.TRUE == (disposition.getSettled()))
                {
                    delivery.setRemoteSettled(true);
                    unsettledDeliveries.remove(id);
                }
                delivery.updateWork();

                getSession().getConnection().put(Type.DELIVERY, delivery);
            }
            id = id.add(UnsignedInteger.ONE);
        }
        //TODO - Implement.
    }

    void addUnsettledOutgoing(UnsignedInteger deliveryId, DeliveryImpl delivery)
    {
        _unsettledOutgoingDeliveriesById.put(deliveryId, delivery);
    }

    public bool hasOutgoingCredit()
    {
        return _remoteIncomingWindow is null ? false
            : _remoteIncomingWindow > (UnsignedInteger.ZERO);

    }

    void incrementOutgoingId()
    {
        _nextOutgoingId = _nextOutgoingId.add(UnsignedInteger.ONE);
    }

    public void settled(TransportDelivery transportDelivery)
    {
        if( cast(ReceiverImpl) (transportDelivery.getTransportLink().getLink()) !is null )
        {
            _unsettledIncomingDeliveriesById.remove(transportDelivery.getDeliveryId());
            getSession().modified(false);
        }
        else
        {
            _unsettledOutgoingDeliveriesById.remove(transportDelivery.getDeliveryId());
            getSession().modified(false);
        }
    }

    public UnsignedInteger getNextIncomingId()
    {
        return _nextIncomingId;
    }

    public void setNextIncomingId(UnsignedInteger nextIncomingId)
    {
        _nextIncomingId = nextIncomingId;
    }

    public void incrementNextIncomingId()
    {
        _nextIncomingId = _nextIncomingId.add(UnsignedInteger.ONE);
    }

    public bool endReceived()
    {
        return _endReceived;
    }

    public void receivedEnd()
    {
        _endReceived = true;
    }

    public bool beginSent()
    {
        return _beginSent;
    }

    public void sentBegin()
    {
        _beginSent = true;
    }
}
