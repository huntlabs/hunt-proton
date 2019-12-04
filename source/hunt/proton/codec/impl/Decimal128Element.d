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

module hunt.proton.codec.impl.Decimal128Element;

/*
import hunt.collection.ByteBuffer;

import hunt.proton.amqp.Decimal128;
import hunt.proton.codec.Data;

class Decimal128Element : AtomicElement!(Decimal128)
{

    private Decimal128 _value;

    Decimal128Element(Element parent, Element prev, Decimal128 d)
    {
        super(parent, prev);
        _value = d;
    }

    override
    public int size()
    {
        return isElementOfArray() ? 16 : 17;
    }

    override
    public Decimal128 getValue()
    {
        return _value;
    }

    override
    public Data.DataType getDataType()
    {
        return Data.DataType.DECIMAL128;
    }

    override
    public int encode(ByteBuffer b)
    {
        int size = size();
        if(b.remaining()>=size)
        {
            if(size == 17)
            {
                b.put((byte)0x94);
            }
            b.putLong(_value.getMostSignificantBits());
            b.putLong(_value.getLeastSignificantBits());
            return size;
        }
        else
        {
            return 0;
        }
    }
}
*/