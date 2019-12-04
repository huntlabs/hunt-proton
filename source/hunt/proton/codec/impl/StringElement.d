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

module hunt.proton.codec.impl.StringElement;

import hunt.collection.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;

import hunt.proton.amqp.Symbol;
import hunt.proton.codec.Data;
import hunt.text.Charset;
import hunt.String;

class StringElement : AtomicElement!String
{

  //  private static Charset UTF_8 = StandardCharsets.UTF-8;
    private string _value;

    this(IElement parent, IElement prev, string s)
    {
        super(parent, prev);
        _value = s;
    }

    public int size()
    {
        int length = cast(int)_value.length;

        return size(length);
    }

    private int size(int length)
    {
        if(isElementOfArray())
        {
            ArrayElement parent = cast(ArrayElement) parent();

            if(parent.constructorType() == ArrayElement.SMALL)
            {
                if(length > 255)
                {
                    parent.setConstructorType(ArrayElement.LARGE);
                    return 4+length;
                }
                else
                {
                    return 1+length;
                }
            }
            else
            {
                return 4+length;
            }
        }
        else
        {
            if(length >255)
            {
                return 5 + length;
            }
            else
            {
                return 2 + length;
            }
        }
    }

    public Object getValue()
    {
        return new String( _value);
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.STRING;
    }

    public int encode(ByteBuffer b)
    {
        byte[] bytes = cast(byte[])_value.dup;
        int length = cast(int)bytes.length;

        int size = size(length);
        if(b.remaining()<size)
        {
            return 0;
        }
        if(isElementOfArray())
        {
            ArrayElement parent = cast(ArrayElement) parent();

            if(parent.constructorType() == ArrayElement.SMALL)
            {
                b.put(cast(byte)length);
            }
            else
            {
                b.putInt(length);
            }
        }
        else if(length<=255)
        {
            b.put(cast(byte)0xa1);
            b.put(cast(byte)length);
        }
        else
        {
            b.put(cast(byte)0xb1);
            b.putInt(length);
        }
        b.put(bytes);
        return size;

    }
}
