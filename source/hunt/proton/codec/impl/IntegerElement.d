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

module hunt.proton.codec.impl.IntegerElement;

import hunt.io.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;
import hunt.Integer;

import hunt.proton.codec.Data;

class IntegerElement : AtomicElement!Integer
{

    private int _value;

    this(IElement parent,IElement prev, int i)
    {
        super(parent, prev);
        _value = i;
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
                    return 4;
                }
            }
            else
            {
                return 4;
            }
        }
        else
        {
            return (-128 <= _value && _value <= 127) ? 2 : 5;
        }

    }

    public Object getValue()
    {
        return new Integer( _value);
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.INT;
    }

    public int encode(ByteBuffer b)
    {
        int size = size();
        if(size <= b.remaining())
        {
            switch(size)
            {
                case 2:
                {
                    b.put(cast(byte)0x54);
                    goto case;
                }
                case 1:
                {
                    b.put(cast(byte)_value);
                    break;
                }

                case 5:
                {
                    b.put(cast(byte)0x71);
                    goto case;
                }

                case 4:
                {
                    b.putInt(_value);
                    break;
                }

                default:
                    break;
            }

            return size;
        }
        return 0;
    }
}
