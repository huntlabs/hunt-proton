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

module hunt.proton.engine.impl.TransportLink;

import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.transport.Flow;
import hunt.proton.engine.Event;
import hunt.proton.engine.impl.ReceiverImpl;
import hunt.proton.engine.impl.TransportReceiver;
import hunt.proton.engine.impl.SenderImpl;
import hunt.proton.engine.impl.TransportSender;
import hunt.proton.engine.impl.TransportDelivery;
import hunt.proton.engine.impl.LinkImpl;

class TransportLink
{
    private UnsignedInteger _localHandle;
    private string _name;
    private UnsignedInteger _remoteHandle;
    private UnsignedInteger _deliveryCount;
    private UnsignedInteger _linkCredit  ;//= UnsignedInteger.ZERO;
    private Object _link;
    private UnsignedInteger _remoteDeliveryCount;
    private UnsignedInteger _remoteLinkCredit;
    private bool _detachReceived;
    private bool _attachSent;

    this(Object link)
    {
        _link = link;
        _linkCredit = UnsignedInteger.ZERO;
        _name = (cast(LinkImpl)link).getName();
    }

    static TransportLink createTransportLink(Object link)
    {
        ReceiverImpl r = cast(ReceiverImpl)link;
        if (r !is null)
        {
            TransportReceiver tr = new TransportReceiver(r);
            r.setTransportLink(tr);

            return cast(TransportLink) tr;
        }
        else
        {
            SenderImpl s = cast(SenderImpl) link;
            TransportSender ts = new TransportSender(s);
            s.setTransportLink(ts);

            return cast(TransportLink) ts;
        }
    }

    void unbind()
    {
        clearLocalHandle();
        clearRemoteHandle();
    }

    public UnsignedInteger getLocalHandle()
    {
        return _localHandle;
    }

    public void setLocalHandle(UnsignedInteger localHandle)
    {
        if (_localHandle is null) {
            (cast(LinkImpl)_link).incref();
        }
        _localHandle = localHandle;
    }

    public bool isLocalHandleSet()
    {
        return _localHandle !is null;
    }

    public string getName()
    {
        return _name;
    }

    public void setName(string name)
    {
        _name = name;
    }

    public void clearLocalHandle()
    {
        if (_localHandle !is null) {
            (cast(LinkImpl)_link).decref();
        }
        _localHandle = null;
    }

    public UnsignedInteger getRemoteHandle()
    {
        return _remoteHandle;
    }

    public void setRemoteHandle(UnsignedInteger remoteHandle)
    {
        if (_remoteHandle is null) {
            (cast(LinkImpl)_link).incref();
        }
        _remoteHandle = remoteHandle;
    }

    public void clearRemoteHandle()
    {
        if (_remoteHandle !is null) {
            (cast(LinkImpl)_link).decref();
        }
        _remoteHandle = null;
    }

    public UnsignedInteger getDeliveryCount()
    {
        return _deliveryCount;
    }

    public UnsignedInteger getLinkCredit()
    {
        return _linkCredit;
    }

    public void addCredit(int credits)
    {
        _linkCredit = UnsignedInteger.valueOf(_linkCredit.intValue() + credits);
    }

    public bool hasCredit()
    {
        return getLinkCredit() > (UnsignedInteger.ZERO);
    }

    public Object getLink()
    {
        return _link;
    }

    void handleFlow(Flow flow)
    {
        _remoteDeliveryCount = flow.getDeliveryCount();
        _remoteLinkCredit = flow.getLinkCredit();


        (cast(LinkImpl)_link).getConnectionImpl().put(Type.LINK_FLOW, _link);
    }

    void setLinkCredit(UnsignedInteger linkCredit)
    {
        _linkCredit = linkCredit;
    }

    public void setDeliveryCount(UnsignedInteger deliveryCount)
    {
        _deliveryCount = deliveryCount;
    }

    public void settled(TransportDelivery transportDelivery)
    {
        (cast(LinkImpl)getLink()).getSession().getTransportSession().settled(transportDelivery);
    }


    UnsignedInteger getRemoteDeliveryCount()
    {
        return _remoteDeliveryCount;
    }

    UnsignedInteger getRemoteLinkCredit()
    {
        return _remoteLinkCredit;
    }

    public void setRemoteLinkCredit(UnsignedInteger remoteLinkCredit)
    {
        _remoteLinkCredit = remoteLinkCredit;
    }

    void decrementLinkCredit()
    {
        _linkCredit = _linkCredit.subtract(UnsignedInteger.ONE);
    }

    void incrementDeliveryCount()
    {
        _deliveryCount = _deliveryCount.add(UnsignedInteger.ONE);
    }

    public void receivedDetach()
    {
        _detachReceived = true;
    }

    public bool detachReceived()
    {
        return _detachReceived;
    }

    public bool attachSent()
    {
        return _attachSent;
    }

    public void sentAttach()
    {
        _attachSent = true;
    }

    public void setRemoteDeliveryCount(UnsignedInteger remoteDeliveryCount)
    {
        _remoteDeliveryCount = remoteDeliveryCount;
    }
}
