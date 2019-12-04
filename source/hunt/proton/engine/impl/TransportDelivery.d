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

module hunt.proton.engine.impl.TransportDelivery;

import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.engine.impl.DeliveryImpl;
import hunt.proton.engine.impl.TransportLink;

class TransportDelivery
{
    private UnsignedInteger _deliveryId;
    private DeliveryImpl _delivery;
    private TransportLink _transportLink;
    private int _sessionSize = 1;

    this(UnsignedInteger currentDeliveryId, DeliveryImpl delivery, TransportLink transportLink)
    {
        _deliveryId = currentDeliveryId;
        _delivery = delivery;
        _transportLink = transportLink;
    }

    public UnsignedInteger getDeliveryId()
    {
        return _deliveryId;
    }

    public TransportLink getTransportLink()
    {
        return _transportLink;
    }

    void incrementSessionSize()
    {
        _sessionSize++;
    }

    int getSessionSize()
    {
        return _sessionSize;
    }

    void settled()
    {
        _transportLink.settled(this);
        _delivery.updateWork();
    }
}
