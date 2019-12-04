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

module hunt.proton.codec.impl.UnsignedIntegerElement;

import hunt.collection.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;

import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.codec.Data;

class UnsignedIntegerElement : AtomicElement!(UnsignedInteger)
{

    private UnsignedInteger _value;

    this(IElement parent, IElement prev, UnsignedInteger i)
    {
        super(parent, prev);
        _value = i;
    }

    public int size()
    {
        if(isElementOfArray())
        {
            ArrayElement parent = cast(ArrayElement) parent();
            if(parent.constructorType() == ArrayElement.TINY)
            {
                if(_value.intValue() == 0)
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
                if(0 <= _value.intValue() && _value.intValue() <= 255)
                {
                    return 1;
                }
                else
                {
                    parent.setConstructorType(ArrayElement.LARGE);
                }
            }

            return 4;

        }
        else
        {
            return 0 == _value.intValue() ? 1 : (1 <= _value.intValue() && _value.intValue() <= 255) ? 2 : 5;
        }

    }

    public Object getValue()
    {
        return _value;
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.UINT;
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
                    b.put(cast(byte)_value.intValue());
                }
                else
                {
                    b.put(cast(byte)0x43);
                }
                break;
            case 2:
                b.put(cast(byte)0x52);
                b.put(cast(byte)_value.intValue());
                break;
            case 5:
                b.put(cast(byte)0x70);
                goto case;
            case 4:
                b.putInt(_value.intValue());
                break;
            default:
                break;

        }

        return size;
    }
}
