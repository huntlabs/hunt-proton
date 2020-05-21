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

module hunt.proton.codec.impl.UnsignedShortElement;

import hunt.io.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;

import hunt.proton.amqp.UnsignedShort;
import hunt.proton.codec.Data;

class UnsignedShortElement : AtomicElement!(UnsignedShort)
{

    private UnsignedShort _value;

    this(IElement parent, IElement prev, UnsignedShort ub)
    {
        super(parent, prev);
        _value = ub;
    }

    public int size()
    {
        return isElementOfArray() ? 2 : 3;
    }

    public Object getValue()
    {
        return _value;
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.USHORT;
    }

    public int encode(ByteBuffer b)
    {
        if(isElementOfArray())
        {
            if(b.remaining()>=2)
            {
                b.putShort(_value.shortValue());
                return 2;
            }
        }
        else
        {
            if(b.remaining()>=3)
            {
                b.put(cast(byte)0x60);
                b.putShort(_value.shortValue());
                return 3;
            }
        }
        return 0;
    }
}
