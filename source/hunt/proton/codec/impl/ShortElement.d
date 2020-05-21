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

module hunt.proton.codec.impl.ShortElement;

import hunt.io.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;
import hunt.Short;

import hunt.proton.codec.Data;

class ShortElement : AtomicElement!Short
{

    private short _value;

    this(IElement parent, IElement prev, short s)
    {
        super(parent, prev);
        _value = s;
    }

    public int size()
    {
        return isElementOfArray() ? 2 : 3;
    }

    public Object getValue()
    {
        return new Short (_value);
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.SHORT;
    }

    public int encode(ByteBuffer b)
    {
        if(isElementOfArray())
        {
            if(b.remaining() >= 2)
            {
                b.putShort(_value);
                return 2;
            }
        }
        else
        {
            if(b.remaining()>=3)
            {
                b.put(cast(byte)0x61);
                b.putShort(_value);
                return 3;
            }
        }
        return 0;
    }
}
