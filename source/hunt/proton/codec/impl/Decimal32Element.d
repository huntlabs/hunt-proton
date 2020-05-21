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

module hunt.proton.codec.impl.Decimal32Element;


import hunt.io.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;

import hunt.proton.amqp.Decimal32;
import hunt.proton.codec.Data;

class Decimal32Element : AtomicElement!Decimal32
{

    private Decimal32 _value;

    this(Element!Decimal32 parent, Element!Decimal32 prev, Decimal32 d)
    {
        super(parent, prev);
        _value = d;
    }

    public int size()
    {
        return isElementOfArray() ? 4 : 5;
    }

    public Decimal32 getValue()
    {
        return _value;
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.DECIMAL32;
    }

    public int encode(ByteBuffer b)
    {
        int size = size();
        if(b.remaining()>=size)
        {
            if(size == 5)
            {
                b.put(cast(byte)0x74);
            }
            b.putInt(_value.getBits());
            return size;
        }
        else
        {
            return 0;
        }
    }
}
