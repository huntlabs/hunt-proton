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


module hunt.proton.amqp.messaging.Header;

import hunt.proton.amqp.UnsignedByte;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.messaging.Section;
import hunt.Boolean;
class Header : Section
{
    private Boolean _durable;
    private UnsignedByte _priority;
    private UnsignedInteger _ttl;
    private Boolean _firstAcquirer;
    private UnsignedInteger _deliveryCount;

    this ()
    {

    }

    this(Header other)
    {
        this._durable = other._durable;
        this._priority = other._priority;
        this._ttl = other._ttl;
        this._firstAcquirer = other._firstAcquirer;
        this._deliveryCount = other._deliveryCount;
    }

    public Boolean getDurable()
    {
        return _durable;
    }

    public void setDurable(bool durable)
    {
        _durable = new Boolean(durable);
    }

    public UnsignedByte getPriority()
    {
        return _priority;
    }

    public void setPriority(UnsignedByte priority)
    {
        _priority = priority;
    }

    public UnsignedInteger getTtl()
    {
        return _ttl;
    }

    public void setTtl(UnsignedInteger ttl)
    {
        _ttl = ttl;
    }

    public Boolean getFirstAcquirer()
    {
        return _firstAcquirer;
    }

    public void setFirstAcquirer(bool firstAcquirer)
    {
        _firstAcquirer = new Boolean(firstAcquirer);
    }

    public UnsignedInteger getDeliveryCount()
    {
        return _deliveryCount;
    }

    public void setDeliveryCount(UnsignedInteger deliveryCount)
    {
        _deliveryCount = deliveryCount;
    }

    override
    public SectionType getType() {
        return SectionType.Header;
    }
}
