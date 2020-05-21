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

module hunt.proton.codec.impl.Decimal64Element;

import hunt.io.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;

import hunt.proton.amqp.Decimal64;
import hunt.proton.codec.Data;

class Decimal64Element : AtomicElement!Decimal64
{

    private Decimal64 _value;

    this(Element!Decimal64 parent, Element!Decimal64 prev, Decimal64 d)
    {
        super(parent, prev);
        _value = d;
    }

    public int size()
    {
        return isElementOfArray() ? 8 : 9;
    }

    public Decimal64 getValue()
    {
        return _value;
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.DECIMAL64;
    }

    public int encode(ByteBuffer b)
    {
        int size = size();
        if(b.remaining()>=size)
        {
            if(size == 9)
            {
                b.put(cast(byte)0x84);
            }
            b.putLong(_value.getBits());
            return size;
        }
        else
        {
            return 0;
        }
    }
}
