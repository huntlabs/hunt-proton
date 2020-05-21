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

module hunt.proton.codec.impl.UnsignedLongElement;

import hunt.io.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;

import hunt.proton.amqp.UnsignedLong;
import hunt.proton.codec.Data;

class UnsignedLongElement : AtomicElement!UnsignedLong
{

    private UnsignedLong _value;

    this(IElement parent, IElement prev, UnsignedLong ul)
    {
        super(parent, prev);
        _value = ul;
    }

    public int size()
    {
        if(isElementOfArray())
        {
            ArrayElement parent = cast(ArrayElement) parent();
            if(parent.constructorType() == ArrayElement.TINY)
            {
                if(_value.longValue() == 0)
                {
                    return 0;
                }
                else
                {
                    parent.setConstructorType(ArrayElement.SMALL);
                }
            }

            if(parent.constructorType() == ArrayElement.SMALL)
            {
                if(0 <= _value.longValue() && _value.longValue() <= 255)
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
            return 0 == _value.longValue() ? 1 : (1 <= _value.longValue() && _value.longValue() <= 255) ? 2 : 9;
        }

    }

    public Object getValue()
    {
        return _value;
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.ULONG;
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
            case 1:
                if(isElementOfArray())
                {
                    b.put(cast(byte)_value.longValue());
                }
                else
                {
                    b.put(cast(byte)0x44);
                }
                break;
            case 2:
                b.put(cast(byte)0x53);
                b.put(cast(byte)_value.longValue());
                break;
            case 9:
                b.put(cast(byte)0x80);
                goto case;
            case 8:
                b.putLong(_value.longValue());
                break;
            default:
                break;
        }

        return size;
    }
}
