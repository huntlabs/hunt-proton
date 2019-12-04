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

module hunt.proton.codec.impl.UUIDElement;

import hunt.collection.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;
import hunt.proton.codec.Data;
import std.uuid;
import hunt.logging;
import hunt.Exceptions;

class UUIDElement : AtomicElement!UUID
{

    private UUID _value;

    this(IElement parent, IElement prev, UUID u)
    {
        super(parent, prev);
        _value = u;
    }

    public int size()
    {
        return isElementOfArray() ? 16 : 17;
    }

    public Object getValue()
    {

        UUID tmp ;
        implementationMissing(false);
        return null;
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.UUID;
    }

    public int encode(ByteBuffer b)
    {
        int size = size();
        if(b.remaining()>=size)
        {
            if(size == 17)
            {
                b.put(cast(byte)0x98);
            }
            b.putLong(4053239666997989821);
            b.putLong(-5603022497796657139);
            return size;
        }
        else
        {
            return 0;
        }
    }
}
