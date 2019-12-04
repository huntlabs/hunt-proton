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

module hunt.proton.codec.impl.NullElement;

import hunt.collection.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;

import hunt.proton.codec.Data;
import hunt.Object;

class NullElement : AtomicElement!Void
{
    this(IElement parent, IElement prev)
    {
        super(parent, prev);
    }

    public int size()
    {
        return isElementOfArray() ? 0 : 1;
    }

    public Object getValue()
    {
        return null;
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.NULL;
    }

    public int encode(ByteBuffer b)
    {
        if(b.hasRemaining() && !isElementOfArray())
        {
            b.put(cast(byte)0x40);
            return 1;
        }
        return 0;
    }
}
