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

module hunt.proton.codec.impl.MapElement;

import hunt.proton.codec.impl.AbstractElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.Data;
import hunt.collection.Map;
import hunt.io.ByteBuffer;
import std.conv;
import hunt.collection.HashMap;

class MapElement : AbstractElement!(Map!(Object,Object))
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

            if(parent.constructorType() == ArrayElement.SMALL)
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
            if(count <= 255 && size <= 254)
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
        Map!(Object,Object) map = new HashMap!(Object,Object);
        IElement elt = _first;
        while(elt !is null)
        {
            Object key = cast(Object)elt.getValue();
            Object value;
            elt = elt.next();
            if(elt !is null)
            {
                value = elt.getValue();
                elt =  elt.next();
            }
            else
            {
                value = null;
            }
            map.put(key,value);
        }

        return cast(Object)map;
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.MAP;
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
            elt =  elt.next();
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
                    case ArrayElement.ConstructorType.SMALL:
                        b.put(cast(byte)(size+1));
                        b.put(cast(byte)count);
                        break;
                    case ArrayElement.ConstructorType.LARGE:
                        b.putInt((size+4));
                        b.putInt(count);
                        break;
                    default:
                        break;
                }
            }
            else
            {
                if(size <= 254 && count <=255)
                {
                    b.put(cast(byte)0xc1);
                    b.put(cast(byte)(size+1));
                    b.put(cast(byte)count);
                }
                else
                {
                    b.put(cast(byte)0xd1);
                    b.putInt((size+4));
                    b.putInt(count);
                }

            }

            elt = _first;
            while(elt !is null)
            {
                elt.encode(b);
                elt =  elt.next();
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
        return "{";
    }

    override
    string stopSymbol() {
        return "}";
    }

}
