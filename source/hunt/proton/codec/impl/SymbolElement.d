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

module hunt.proton.codec.impl.SymbolElement;

import hunt.io.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;
import hunt.text.Charset;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.codec.Data;

class SymbolElement : AtomicElement!Symbol
{
    private static Charset ASCII = StandardCharsets.US_ASCII;
    private Symbol _value;

    this(IElement parent, IElement prev, Symbol s)
    {
        super(parent, prev);
        _value = s;
    }

    public int size()
    {
        int length = _value.length();

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
        return _value;
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.SYMBOL;
    }

    public int encode(ByteBuffer b)
    {
        int size = size();
        if(b.remaining()<size)
        {
            return 0;
        }
        if(isElementOfArray())
        {
            ArrayElement parent = cast(ArrayElement) parent();

            if(parent.constructorType() == ArrayElement.SMALL)
            {
                b.put(cast(byte)_value.length());
            }
            else
            {
                b.putInt(_value.length());
            }
        }
        else if(_value.length()<=255)
        {
            b.put(cast(byte)0xa3);
            b.put(cast(byte)_value.length());
        }
        else
        {
            b.put(cast(byte)0xb3);
            b.put(cast(byte)_value.length());
        }
        b.put(_value.toString().dup);
        return size;
    }
}
