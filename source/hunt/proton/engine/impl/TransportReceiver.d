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

module hunt.proton.engine.impl.TransportReceiver;

import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.transport.Flow;
import hunt.proton.engine.impl.TransportLink;
import hunt.proton.engine.impl.ReceiverImpl;

class TransportReceiver : TransportLink
{
    private UnsignedInteger _incomingDeliveryId;

    this(ReceiverImpl link)
    {
        super(link);
        link.setTransportLink(this);
    }

    public ReceiverImpl getReceiver()
    {
        return cast(ReceiverImpl)getLink();
    }

    override
    void handleFlow(Flow flow)
    {
        super.handleFlow(flow);
        int remote = getRemoteDeliveryCount().intValue();
        int local = getDeliveryCount().intValue();
        int delta = remote - local;
        if(delta > 0)
        {
            (cast(ReceiverImpl)getLink()).addCredit(-delta);
            addCredit(-delta);
            setDeliveryCount(getRemoteDeliveryCount());
            (cast(ReceiverImpl)getLink()).setDrained((cast(ReceiverImpl)getLink()).getDrained() + delta);
        }
    }

    UnsignedInteger getIncomingDeliveryId() {
        return _incomingDeliveryId;
    }

    void setIncomingDeliveryId(UnsignedInteger _incomingDeliveryId) {
        this._incomingDeliveryId = _incomingDeliveryId;
    }

}
