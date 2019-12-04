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

module hunt.proton.codec.impl.ByteElement;


import hunt.proton.codec.Data;
import hunt.proton.codec.Data;
import hunt.collection.Map;
import hunt.collection.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;
import hunt.Byte;

class ByteElement : AtomicElement!Byte
{

    private byte _value;

    this(IElement parent, IElement prev, byte b)
    {
        super(parent, prev);
        _value = b;
    }

    public int size()
    {
        return isElementOfArray() ? 1 : 2;
    }

    public Object getValue()
    {
        return  new Byte( _value);
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.BYTE;
    }

    public int encode(ByteBuffer b)
    {
        if(isElementOfArray())
        {
            if(b.hasRemaining())
            {
                b.put(_value);
                return 1;
            }
        }
        else
        {
            if(b.remaining()>=2)
            {
                b.put(cast(byte)0x51);
                b.put(_value);
                return 2;
            }
        }
        return 0;
    }
}
