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

module hunt.proton.codec.impl.ListElement;

import hunt.proton.codec.impl.AbstractElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.Data;
import hunt.collection.List;
import hunt.collection.ByteBuffer;
import hunt.collection.ArrayList;
import std.conv;

import hunt.proton.codec.Data;

class ListElement : AbstractElement!(List!Object)
{
    private IElement _first;

    this(IElement parent, IElement prev)
    {
        super(parent, prev);
    }

    public int count()
    {
        int count = 0;
        IElement elt = _first;
        while(elt !is null)
        {
            count++;
            elt = elt.next();
        }
        return count;
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
            ArrayElement parent = cast(ArrayElement) parent();
            if(parent.constructorType() == ArrayElement.TINY)
            {
                if(count != 0)
                {
                    parent.setConstructorType(ArrayElement.ConstructorType.SMALL);
                    size += 2;
                }
            }
            else if(parent.constructorType() == ArrayElement.SMALL)
            {
                if(count > 255 || size > 254)
                {
                    parent.setConstructorType(ArrayElement.ConstructorType.LARGE);
                    size += 8;
                }
                else
                {
                    size += 2;
                }
            }
            else
            {
                size += 8;
            }

        }
        else
        {
            if(count == 0)
            {
                size = 1;
            }
            else if(count <= 255 && size <= 254)
            {
                size += 3;
            }
            else
            {
                size+=9;
            }
        }

        return size;
    }

    public Object getValue()
    {
        List!Object list = new ArrayList!Object();
        IElement elt = _first;


        while(elt !is null)
        {
            list.add(elt.getValue());
            elt = elt.next();
        }

        return cast(Object)list;
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.LIST;
    }

    public int encode(ByteBuffer b)
    {
        int encodedSize = size();

        int count = 0;
        int size = 0;
        IElement elt = _first;
        while(elt !is null)
        {
            count++;
            size += elt.size();
            elt = elt.next();
        }

        if(encodedSize > b.remaining())
        {
            return 0;
        }
        else
        {
            if(isElementOfArray())
            {
                switch((cast(ArrayElement)parent()).constructorType())
                {
                    case ArrayElement.ConstructorType.TINY:
                        break;
                    case ArrayElement.ConstructorType.SMALL:
                    {
                        b.put(cast(byte)(size+1));
                        b.put(cast(byte)count);
                        break;
                    }

                    case ArrayElement.ConstructorType.LARGE:
                    {
                        b.putInt((size+4));
                        b.putInt(count);
                        break;
                    }
                    default:
                        break;
                }
            }
            else
            {
                if(count == 0)
                {
                    b.put(cast(byte)0x45);
                }
                else if(size <= 254 && count <=255)
                {
                    b.put(cast(byte)0xc0);
                    b.put(cast(byte)(size+1));
                    b.put(cast(byte)count);
                }
                else
                {
                    b.put(cast(byte)0xd0);
                    b.putInt((size+4));
                    b.putInt(count);
                }

            }

            elt = _first;
            while(elt !is null)
            {
                elt.encode(b);
                elt = elt.next();
            }

            return encodedSize;
        }
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
        return element;
    }

    public IElement addChild(IElement element)
    {
        _first = element;
        return element;
    }

    override
    string startSymbol() {
        return "[";
    }

    override
    string stopSymbol() {
        return "]";
    }

}
