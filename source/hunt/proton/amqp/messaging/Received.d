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


module hunt.proton.amqp.messaging.Received;

import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.DeliveryState;

class Received : DeliveryState
{
    private UnsignedInteger _sectionNumber;
    private UnsignedLong _sectionOffset;

    public UnsignedInteger getSectionNumber()
    {
        return _sectionNumber;
    }

    public void setSectionNumber(UnsignedInteger sectionNumber)
    {
        _sectionNumber = sectionNumber;
    }

    public UnsignedLong getSectionOffset()
    {
        return _sectionOffset;
    }

    public void setSectionOffset(UnsignedLong sectionOffset)
    {
        _sectionOffset = sectionOffset;
    }

    override
    public DeliveryStateType getType() {
        return DeliveryStateType.Received;
    }
}
