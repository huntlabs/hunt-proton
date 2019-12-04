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

module hunt.proton.engine.impl.TransportSender;

import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.transport.Flow;
import hunt.proton.engine.impl.TransportLink;
import hunt.proton.engine.impl.SenderImpl;
import hunt.proton.engine.impl.DeliveryImpl;
import std.concurrency : initOnce;


class TransportSender : TransportLink
{
    private bool _drain;
    private DeliveryImpl _inProgressDelivery;
    //private static UnsignedInteger ORIGINAL_DELIVERY_COUNT = UnsignedInteger.ZERO;

    static UnsignedInteger  ORIGINAL_DELIVERY_COUNT() {
        __gshared UnsignedInteger  inst;
        return initOnce!inst(UnsignedInteger.ZERO);
    }

    this(SenderImpl link)
    {
        super(link);
        setDeliveryCount(ORIGINAL_DELIVERY_COUNT);
        link.setTransportLink(this);
    }

    override
    void handleFlow(Flow flow)
    {
        super.handleFlow(flow);
        _drain = flow.getDrain().booleanValue;
        (cast(SenderImpl)getLink()).setDrain(flow.getDrain().booleanValue);
        int oldCredit = (cast(SenderImpl)getLink()).getCredit();
        UnsignedInteger oldLimit = getLinkCredit().add(getDeliveryCount());
        UnsignedInteger transferLimit = flow.getLinkCredit().add(flow.getDeliveryCount() is null
                                                                         ? ORIGINAL_DELIVERY_COUNT
                                                                         : flow.getDeliveryCount());
        UnsignedInteger linkCredit = transferLimit.subtract(getDeliveryCount());

        setLinkCredit(linkCredit);
        (cast(SenderImpl)getLink()).setCredit(transferLimit.subtract(oldLimit).intValue() + oldCredit);

        DeliveryImpl current = (cast(SenderImpl)getLink()).current();
        (cast(SenderImpl)getLink()).getConnectionImpl().workUpdate(current);
        setLinkCredit(linkCredit);
    }

    public void setInProgressDelivery(DeliveryImpl inProgressDelivery)
    {
        _inProgressDelivery = inProgressDelivery;
    }

    public DeliveryImpl getInProgressDelivery()
    {
        return _inProgressDelivery;
    }
}
