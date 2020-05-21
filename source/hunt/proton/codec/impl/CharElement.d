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

module hunt.proton.codec.impl.CharElement;

import hunt.collection.Map;
import hunt.io.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;

import hunt.Integer;
import hunt.proton.codec.Data;

class CharElement : AtomicElement!Integer
{

    private int _value;

    this(IElement parent, IElement prev, int i)
    {
        super(parent, prev);
        _value = i;
    }

    public int size()
    {
        return isElementOfArray() ? 4 : 5;
    }

    public Object getValue()
    {
        return  new Integer( _value);
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.CHAR;
    }

    public int encode(ByteBuffer b)
    {
        int size = size();
        if(size <= b.remaining())
        {
            if(size == 5)
            {
                b.put(cast(byte)0x73);
            }
            b.putInt(_value);
        }
        return 0;
    }
}
