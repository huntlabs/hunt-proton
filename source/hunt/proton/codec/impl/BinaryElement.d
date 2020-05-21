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

module hunt.proton.codec.impl.BinaryElement;

import hunt.io.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;

import hunt.proton.amqp.Binary;
import hunt.proton.codec.Data;

class BinaryElement : AtomicElement!Binary
{

    private Binary _value;

    this(IElement parent, IElement prev, Binary b)
    {
        super(parent, prev);
        byte[] data  = new byte[b.getLength()];
      //  System.arraycopy(b.getArray(),b.getArrayOffset(),data,0,b.getLength());
       // data ~= b.getArray()[b.getArrayOffset() .. $];
        data [0 .. b.getLength()] = b.getArray()[b.getArrayOffset() .. b.getArrayOffset()+b.getLength()];
        _value = new Binary(data);
    }

    public int size()
    {
        int length = _value.getLength();

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
        return Data.DataType.BINARY;
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
                b.put(cast(byte)_value.getLength());
            }
            else
            {
                b.putInt(_value.getLength());
            }
        }
        else if(_value.getLength()<=255)
        {
            b.put(cast(byte)0xa0);
            b.put(cast(byte)_value.getLength());
        }
        else
        {
            b.put(cast(byte)0xb0);
            b.putInt(_value.getLength());
        }
        b.put(_value.getArray(),_value.getArrayOffset(),_value.getLength());
        return size;

    }

    override
    IElement addChild(IElement element)
    {
            return super.addChild(element);
    }


    override
    IElement checkChild(IElement element)
    {
        return super.checkChild(element);
    }

    override
    void setChild(IElement elt)
    {
        super.setChild(elt);
    }

}
