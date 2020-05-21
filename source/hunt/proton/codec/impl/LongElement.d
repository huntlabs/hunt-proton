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

module hunt.proton.codec.impl.LongElement;

import hunt.collection.Map;
import hunt.io.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;

import hunt.proton.codec.Data;
import hunt.Long;

class LongElement : AtomicElement!Long
{

    private long _value;

    this(IElement parent, IElement prev, long l)
    {
        super(parent, prev);
        _value = l;
    }

    public int size()
    {
        if(isElementOfArray())
        {
            ArrayElement parent = cast(ArrayElement) parent();

            if(parent.constructorType() == ArrayElement.SMALL)
            {
                if(-128 <= _value && _value <= 127)
                {
                    return 1;
                }
                else
                {
                    parent.setConstructorType(ArrayElement.LARGE);
                }
            }

            return 8;

        }
        else
        {
            return (-128 <= _value && _value <= 127) ? 2 : 9;
        }

    }

    public Object getValue()
    {
        return new Long (_value);
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.LONG;
    }

    public int encode(ByteBuffer b)
    {
        int size = size();
        if(size > b.remaining())
        {
            return 0;
        }
        switch(size)
        {
            case 2:
                b.put(cast(byte)0x55);
                goto case;
            case 1:
                b.put(cast(byte)_value);
                break;
            case 9:
                b.put(cast(byte)0x81);
                goto case;
            case 8:
                b.putLong(_value);
                break;
            default:
                break;

        }
        return size;
    }
}
