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

module hunt.proton.codec.impl.DescribedTypeElement;

import hunt.proton.codec.impl.DescribedTypeImpl;
import hunt.proton.codec.impl.AbstractElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.Data;
import hunt.collection.Map;
import hunt.io.ByteBuffer;
import hunt.proton.amqp.DescribedType;
import hunt.proton.codec.Data;
import hunt.Exceptions;

class DescribedTypeElement : AbstractElement!(DescribedType)
{
    private IElement _first;

    this(IElement parent, IElement prev)
    {
        super(parent, prev);
    }




    public int size()
    {
        int count = 0;
        int size = 0;
        IElement elt = _first;
        while(elt !is null)
        {
            count++;
            size += elt.size();
            elt = elt.next();
        }

        if(isElementOfArray())
        {
            throw new IllegalArgumentException("Cannot add described type members to an array");
        }
        else if(count > 2)
        {
            throw new IllegalArgumentException("Too many elements in described type");
        }
        else if(count == 0)
        {
            size = 3;
        }
        else if(count == 1)
        {
            size += 2;
        }
        else
        {
            size+=1;
        }

        return size;
    }

    public Object getValue()
    {
        Object descriptor = _first is null ? null :_first.getValue();
        IElement second = _first is null ? null : _first.next();
        Object described = second is null ? null : second.getValue();
        return new DescribedTypeImpl(descriptor,described);
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.DESCRIBED;
    }

    public int encode(ByteBuffer b)
    {
        int encodedSize = size();

        if(encodedSize > b.remaining())
        {
            return 0;
        }
        else
        {
            b.put(cast(byte) 0);
            if(_first is null)
            {
                b.put(cast(byte)0x40);
                b.put(cast(byte)0x40);
            }
            else
            {
                _first.encode(b);
                if(_first.next() is null)
                {
                    b.put(cast(byte)0x40);
                }
                else
                {
                    _first.next().encode(b);
                }
            }
        }
        return encodedSize;
    }

    public bool canEnter()
    {
        return true;
    }

    public IElement child()
    {
        return _first;
    }

    public void setChild(IElement elt)
    {
        _first = elt;
    }

    public IElement checkChild(IElement element)
    {
        if(element.prev() != _first)
        {
            throw new IllegalArgumentException("Described Type may only have two elements");
        }
        return element;

    }

    public IElement addChild(IElement element)
    {
        _first = element;
        return element;
    }

    override
    string startSymbol() {
        return "(";
    }

    override
    string stopSymbol() {
        return ")";
    }

}
