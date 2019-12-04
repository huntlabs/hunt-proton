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

module hunt.proton.codec.impl.BooleanElement;

import hunt.collection.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;

import hunt.proton.codec.Data;
import hunt.Boolean;

class BooleanElement : AtomicElement!Boolean
{
    private bool _value;

    this(IElement parent, IElement current, bool b)
    {
        super(parent, current);
        _value = b;
    }

    public int size()
    {
        // in non-array parent then there is a single byte encoding, in an array there is a 1-byte encoding but no
        // constructor
        return 1;
    }

    public Object getValue()
    {
        return new Boolean( _value);
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.BOOL;
    }

    public int encode(ByteBuffer b)
    {
        if(b.hasRemaining())
        {
            if(isElementOfArray())
            {
                b.put(_value ? cast(byte) 1 : cast(byte) 0);
            }
            else
            {
                b.put(_value ? cast(byte) 0x41 : cast(byte) 0x42);
            }
            return 1;
        }
        return 0;
    }

}
