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

module hunt.proton.codec.impl.FloatElement;

import hunt.collection.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;

import hunt.proton.codec.Data;
import hunt.Float;

class FloatElement : AtomicElement!Float
{

    private float _value;

    this(IElement parent, IElement prev, float f)
    {
        super(parent, prev);
        _value = f;
    }

    public int size()
    {
        return isElementOfArray() ? 4 : 5;
    }

    public Object getValue()
    {
        return  new Float( _value);
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.FLOAT;
    }

    public int encode(ByteBuffer b)
    {
        int size = size();
        if(b.remaining()>=size)
        {
            if(size == 5)
            {
                b.put(cast(byte)0x72);
            }
            b.putInt(cast(int)_value);
            return size;
        }
        else
        {
            return 0;
        }
    }
}
