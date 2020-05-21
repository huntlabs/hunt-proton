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

module hunt.proton.codec.impl.ArrayElement;

import hunt.proton.codec.impl.LongElement;
import hunt.proton.codec.impl.ShortElement;
import hunt.proton.codec.impl.IntegerElement;
import hunt.proton.codec.impl.ByteElement;
import hunt.proton.codec.impl.AbstractElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.Data;
import hunt.proton.codec.impl.DescribedTypeImpl;
import hunt.proton.codec.impl.SymbolElement;
import hunt.collection.Map;
import hunt.io.ByteBuffer;
import std.conv;

import hunt.proton.amqp.DescribedType;
import hunt.proton.amqp.Symbol;
import hunt.proton.codec.Data;
import hunt.Exceptions;
import hunt.Integer;
import hunt.Long;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.Byte;
import hunt.Long;
import hunt.Short;
import hunt.Integer;

class ArrayElement : AbstractElement!(List!Object)
{

    private bool _described;
    private Data.DataType _arrayType;
    private ConstructorType _constructorType;
    private IElement _first;


    enum ConstructorType { TINY, SMALL, LARGE }


    enum ConstructorType TINY = ConstructorType.TINY;
    enum ConstructorType SMALL = ConstructorType.SMALL;
    enum ConstructorType LARGE = ConstructorType.LARGE;

    this(IElement parent, IElement prev, bool described, Data.DataType type)
    {
        super(parent, prev);
        _described = described;
        _arrayType = type;
        if(_arrayType == Data.DataType.NULL)
        {
            throw new NullPointerException("Array type cannot be null");
        }
        else if(_arrayType == Data.DataType.DESCRIBED)
        {
            throw new IllegalArgumentException("Array type cannot be DESCRIBED");
        }
        switch(_arrayType)
        {
            case Data.DataType.UINT:
                 goto case;
            case Data.DataType.ULONG:
                 goto case;
            case Data.DataType.LIST:
                setConstructorType(TINY);
                break;
            default:
                setConstructorType(SMALL);
                break;
        }
    }

    ConstructorType constructorType()
    {
        return _constructorType;
    }

    void setConstructorType(ConstructorType type)
    {
        _constructorType = type;
    }

    public int size()
    {
        ConstructorType oldConstructorType;
        int bodySize;
        int count = 0;
        do
        {
            bodySize = 1; // data type constructor
            oldConstructorType = _constructorType;
            IElement element = _first;
            while(element !is null)
            {
                count++;
                bodySize += element.size();
                element = element.next();
            }
        }
        while (oldConstructorType != constructorType());

        if(isDescribed())
        {
            bodySize++; // 00 instruction
            if(count != 0)
            {
                count--;
            }
        }

        if(isElementOfArray())
        {
            ArrayElement parent = cast(ArrayElement)parent();
            if(parent.constructorType()==SMALL)
            {
                if(count<=255 && bodySize<=254)
                {
                    bodySize+=2;
                }
                else
                {
                    parent.setConstructorType(LARGE);
                    bodySize+=8;
                }
            }
            else
            {
                bodySize+=8;
            }
        }
        else
        {

            if(count<=255 && bodySize<=254)
            {
                bodySize+=3;
            }
            else
            {
                bodySize+=9;
            }

        }


        return bodySize;
    }

    public Object getValue()
    {
        //implementationMissing(false);
        //return null;
        if(isDescribed())
        {
           // DescribedType[] rVal = new DescribedType[cast(int) count()];
            List!Object rVal = new ArrayList!Object;
            Object descriptor = _first is null ? null : _first.getValue();
            IElement element = _first is null ? null : _first.next();
            int i = 0;
            while(element !is null)
            {
                rVal.add(new DescribedTypeImpl(descriptor, element.getValue()));
                element = element.next();
            }
            return cast(Object)rVal;
        }
        else if(_arrayType == Data.DataType.SYMBOL)
        {
            List!Object rVal = new ArrayList!Object;
            SymbolElement element = cast(SymbolElement) _first;
            int i = 0;
            while (element !is null)
            {
                rVal.add (element.getValue());
                element = cast(SymbolElement) element.next();
            }
            return cast(Object)rVal;
        }
        else
        {
            List!Object rVal = new ArrayList!Object;
            IElement element = _first;
            int i = 0;
            while (element !is null)
            {
                rVal.add(element.getValue());
                element = element.next();
            }
            return cast(Object)rVal;
        }
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.ARRAY;
    }

    public int encode(ByteBuffer b)
    {
        int size = size();

        int count = cast(int) count();

        if(b.remaining()>=size)
        {
            if(!isElementOfArray())
            {
                if(size>257 || count >255)
                {
                    b.put(cast(byte)0xf0);
                    b.putInt(size-5);
                    b.putInt(count);
                }
                else
                {
                    b.put(cast(byte)0xe0);
                    b.put(cast(byte)(size-2));
                    b.put(cast(byte)count);
                }
            }
            else
            {
                ArrayElement parent = cast(ArrayElement)parent();
                if(parent.constructorType()==SMALL)
                {
                    b.put(cast(byte)(size-1));
                    b.put(cast(byte)count);
                }
                else
                {
                    b.putInt(size-4);
                    b.putInt(count);
                }
            }
            IElement element = _first;
            if(isDescribed())
            {
                b.put(cast(byte)0);
                if(element is null)
                {
                    b.put(cast(byte)0x40);
                }
                else
                {
                    element.encode(b);
                    element = element.next();
                }
            }
            switch(_arrayType)
            {
                case Data.DataType.NULL:
                    b.put(cast(byte)0x40);
                    break;
                case Data.DataType.BOOL:
                    b.put(cast(byte)0x56);
                    break;
                case Data.DataType.UBYTE:
                    b.put(cast(byte)0x50);
                    break;
                case Data.DataType.BYTE:
                    b.put(cast(byte)0x51);
                    break;
                case Data.DataType.USHORT:
                    b.put(cast(byte)0x60);
                    break;
                case Data.DataType.SHORT:
                    b.put(cast(byte)0x61);
                    break;
                case Data.DataType.UINT:
                    switch (constructorType())
                    {
                        case TINY:
                            b.put(cast(byte)0x43);
                            break;
                        case SMALL:
                            b.put(cast(byte)0x52);
                            break;
                        case LARGE:
                            b.put(cast(byte)0x70);
                            break;
                        default:
                            break;
                    }
                    break;
                case Data.DataType.INT:
                    b.put(_constructorType == SMALL ? cast(byte)0x54 : cast(byte)0x71);
                    break;
                case Data.DataType.CHAR:
                    b.put(cast(byte)0x73);
                    break;
                case Data.DataType.ULONG:
                    switch (constructorType())
                    {
                        case TINY:
                            b.put(cast(byte)0x44);
                            break;
                        case SMALL:
                            b.put(cast(byte)0x53);
                            break;
                        case LARGE:
                            b.put(cast(byte)0x80);
                            break;
                        default:
                            break;
                    }
                    break;
                case Data.DataType.LONG:
                    b.put(_constructorType == SMALL ? cast(byte)0x55 : cast(byte)0x81);
                    break;
                case Data.DataType.TIMESTAMP:
                    b.put(cast(byte)0x83);
                    break;
                case Data.DataType.FLOAT:
                    b.put(cast(byte)0x72);
                    break;
                case Data.DataType.DOUBLE:
                    b.put(cast(byte)0x82);
                    break;
                case Data.DataType.DECIMAL32:
                    b.put(cast(byte)0x74);
                    break;
                case Data.DataType.DECIMAL64:
                    b.put(cast(byte)0x84);
                    break;
                case Data.DataType.DECIMAL128:
                    b.put(cast(byte)0x94);
                    break;
                case Data.DataType.UUID:
                    b.put(cast(byte)0x98);
                    break;
                case Data.DataType.BINARY:
                    b.put(_constructorType == SMALL ? cast(byte)0xa0 : cast(byte)0xb0);
                    break;
                case Data.DataType.STRING:
                    b.put(_constructorType == SMALL ? cast(byte)0xa1 : cast(byte)0xb1);
                    break;
                case Data.DataType.SYMBOL:
                    b.put(_constructorType == SMALL ? cast(byte)0xa3 : cast(byte)0xb3);
                    break;
                case Data.DataType.ARRAY:
                    b.put(_constructorType == SMALL ? cast(byte)0xe0 : cast(byte)0xf0);
                    break;
                case Data.DataType.LIST:
                    b.put(_constructorType == TINY ? cast(byte)0x45 :_constructorType == SMALL ? cast(byte)0xc0 : cast(byte)0xd0);
                    break;
                case Data.DataType.MAP:
                    b.put(_constructorType == SMALL ? cast(byte)0xc1 : cast(byte)0xd1);
                    break;
                default:
                    break;
            }
            while(element !is null)
            {
                element.encode(b);
                element = element.next();
            }
            return size;
        }
        else
        {
            return 0;
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

    public IElement  addChild(IElement  element)
    {
        if(isDescribed() || element.getDataType() == _arrayType)
        {
            _first =  element;
            return element;
        }
        else
        {
            IElement replacement = coerce(element);
            if(replacement !is null)
            {
                _first = replacement;
                return replacement;
            }
            throw new IllegalArgumentException("Attempting to add instance of " ~ to!string(element.getDataType()) ~ " to array of " ~ to!string(_arrayType));
        }
    }

    private IElement coerce(IElement element)
    {
        //implementationMissing(false);
        //return null;
        switch (_arrayType)
        {
        case Data.DataType.INT:
            int i;
            switch (element.getDataType())
            {
            case Data.DataType.BYTE:
                i = (cast(Byte)(element.getValue())).intValue();
                break;
            case Data.DataType.SHORT:
                i = (cast(Short)element.getValue()).intValue();
                break;
            case Data.DataType.LONG:
                i = (cast(Long)element.getValue()).intValue();
                break;
            default:
                return null;
            }
            return new IntegerElement(cast(Element!Integer)element.parent(),cast(Element!Integer)element.prev(),i);

        case Data.DataType.LONG:
            long l;
            switch (element.getDataType())
            {
            case Data.DataType.BYTE:
                l = (cast(Byte)element.getValue()).longValue();
                break;
            case Data.DataType.SHORT:
                l = (cast(Short)element.getValue()).longValue();
                break;
            case Data.DataType.INT:
                l = (cast(Integer)element.getValue()).longValue();
                break;
            default:
                return null;
            }
           // return new LongElement(element.parent(),element.prev(),l);
            return new LongElement(element.parent(),element.prev(),l);
        default:
            return null;
        }
    }

    public IElement checkChild(IElement element)
    {
        //implementationMissing(false);
        //return null;
        if(element.getDataType() != _arrayType)
        {
            IElement replacement = coerce(element);
            if(replacement !is null)
            {
                return replacement;
            }
            throw new IllegalArgumentException("Attempting to add instance of " ~ to!string(element.getDataType()) ~ " to array of " ~ to!string(_arrayType));
        }
        return element;
    }


    public long count()
    {
        int count = 0;
        IElement elt = _first;
        while(elt !is null)
        {
            count++;
            elt = elt.next();
        }
        if(isDescribed() && count != 0)
        {
            count--;
        }
        return count;
        //implementationMissing(false);
        //return 0;
    }

    public bool isDescribed()
    {
        return _described;
    }


    public Data.DataType getArrayDataType()
    {
        return _arrayType;
    }

    override
    string startSymbol() {
        //return String.format("%s%s[", isDescribed() ? "D" : "", getArrayDataType());
        return "";
    }

    override
    string stopSymbol() {
        return "]";
    }

}
