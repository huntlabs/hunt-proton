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

module hunt.proton.codec.impl.UnsignedByteElement;

import hunt.io.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;

import hunt.proton.amqp.UnsignedByte;
import hunt.proton.codec.Data;

class UnsignedByteElement : AtomicElement!UnsignedByte
{

    private UnsignedByte _value;

    this(IElement parent, IElement prev, UnsignedByte ub)
    {
        super(parent, prev);
        _value = ub;
    }

    public int size()
    {
        return isElementOfArray() ? 1 : 2;
    }

    public Object getValue()
    {
        return _value;
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.UBYTE;
    }

    public int encode(ByteBuffer b)
    {
        if(isElementOfArray())
        {
            if(b.hasRemaining())
            {
                b.put(_value.byteValue());
                return 1;
            }
        }
        else
        {
            if(b.remaining()>=2)
            {
                b.put(cast(byte)0x50);
                b.put(_value.byteValue());
                return 2;
            }
        }
        return 0;
    }
}
