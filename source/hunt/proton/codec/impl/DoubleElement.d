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

module hunt.proton.codec.impl.DoubleElement;

import hunt.io.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;
import hunt.Double;
import hunt.proton.codec.Data;

class DoubleElement : AtomicElement!Double
{

    private double _value;

    this(IElement parent, IElement prev, double d)
    {
        super(parent, prev);
        _value = d;
    }

    public int size()
    {
        return isElementOfArray() ? 8 : 9;
    }

    public Object getValue()
    {
        return new Double( _value);
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.DOUBLE;
    }

    public int encode(ByteBuffer b)
    {
        int size = size();
        if(b.remaining()>=size)
        {
            if(size == 9)
            {
                b.put(cast(byte)0x82);
            }
            b.putLong(cast(long)_value);
            return size;
        }
        else
        {
            return 0;
        }
    }
}
