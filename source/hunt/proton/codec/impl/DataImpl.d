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

module hunt.proton.codec.impl.DataImpl;

import hunt.Exceptions;
import hunt.collection.ByteBuffer;
import std.datetime.date;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.Data;
import hunt.proton.amqp.Binary;
import hunt.collection.BufferUtils;
import hunt.proton.codec.impl.DataDecoder;
import hunt.proton.codec.impl.ListElement;
import hunt.proton.codec.impl.MapElement;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.NullElement;
import hunt.proton.codec.impl.BooleanElement;
import hunt.proton.codec.impl.IntegerElement;
import hunt.proton.codec.impl.UnsignedShortElement;
import hunt.proton.codec.impl.UnsignedIntegerElement;
import hunt.proton.codec.impl.DescribedTypeElement;
import hunt.proton.codec.impl.UnsignedByteElement;
import hunt.proton.codec.impl.ByteElement;
import hunt.proton.codec.impl.ShortElement;
import hunt.proton.codec.impl.CharElement;
import hunt.proton.codec.impl.UnsignedLongElement;
import hunt.proton.codec.impl.TimestampElement;
import hunt.proton.codec.impl.LongElement;
import hunt.proton.codec.impl.DoubleElement;
import hunt.proton.codec.impl.FloatElement;
import hunt.proton.codec.impl.Decimal32Element;
import hunt.proton.codec.impl.Decimal64Element;
import hunt.proton.codec.impl.Decimal128Element;
import hunt.proton.codec.impl.UUIDElement;
import hunt.proton.codec.impl.BinaryElement;
import hunt.proton.codec.impl.StringElement;
import hunt.proton.codec.impl.SymbolElement;

import std.uuid;

import hunt.proton.amqp.DescribedType;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.Decimal32;
import hunt.proton.amqp.Decimal64;
import hunt.proton.amqp.Decimal128;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.UnsignedByte;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedShort;

import std.conv : to;
import hunt.Integer;
import hunt.Long;
import hunt.Short;
import hunt.Long;
import hunt.Boolean;
import hunt.Byte;
import hunt.Float;
import hunt.Double;
import hunt.String;
import hunt.Char;

import hunt.time.LocalDateTime;
import hunt.logging;

alias Date = LocalDateTime;

class DataImpl : Data
{

    private IElement _first;
    private IElement _current;
    private IElement _parent;


    this()
    {
    }

    override
    public void free()
    {
        _first = null;
        _current = null;
    }

    override
    public void clear()
    {
        _first=null;
        _current=null;
        _parent=null;
    }

    override
    public long size()
    {
        return _first is null ? 0 : _first.size();
    }

    override
    public void rewind()
    {
        _current = null;
        _parent = null;
    }

    override
    public DataType next()
    {
        IElement next = _current is null ? (_parent is null ? _first : _parent.child()) : _current.next();

        if(next !is null)
        {
            _current = next;
        }
        return next is null ? Data.DataType.NULL : next.getDataType();
    }

    override
    public DataType prev()
    {
        IElement prev = _current is null ? null : _current.prev();

        _current = prev;
        return prev is null ? Data.DataType.NULL : prev.getDataType();
    }

    override
    public bool enter()
    {
        if(_current !is null && _current.canEnter())
        {

            _parent = _current;
            _current = null;
            return true;
        }
        return false;
    }

    override
    public bool exit()
    {
        if(_parent !is null)
        {
            IElement parent = _parent;
            _current = parent;
            _parent = _current.parent();
            return true;

        }
        return false;
    }

    override
    public DataType type()
    {
        return _current is null ? Data.DataType.NULL : _current.getDataType();
    }

    override
    public long encodedSize()
    {
        int size = 0;
        IElement elt = _first;
        while(elt !is null)
        {
            size += elt.size();
            elt = elt.next();
        }
        return size;
    }

    override
    public Binary encode()
    {
        logInfo("%d",encodedSize());
        byte[] data = new byte[cast(int)(encodedSize())];
        ByteBuffer buf = BufferUtils.toBuffer(data);
        encode(buf);
        return new Binary(data);
    }

    override
    public long encode(ByteBuffer buf)
    {
        IElement elt = _first;
        int size = 0;
        while(elt !is null )
        {
            int eltSize = elt.size();
            if(eltSize <= buf.remaining())
            {
                size += elt.encode(buf);
            }
            else
            {
                size+= eltSize;
            }
            elt = elt.next();
        }
        return size;
    }

    override
    public long decode(ByteBuffer buf)
    {
        return DataDecoder.decode(buf, this);
    }


    private void putElement(IElement element)
    {
        if(_first is null)
        {
            _first = element;
        }
        else
        {
            if(_current is null)
            {
                if (_parent is null) {
                    _first = _first.replaceWith(element);
                    element = _first;
                } else {
                    element = _parent.addChild(element);
                }
            }
            else
            {
                if(_parent !is null)
                {
                    element = _parent.checkChild(element);
                }
                _current.setNext(element);
            }
        }

        _current = element;
    }

    override
    public void putList()
    {
        putElement(cast(IElement)(new ListElement(_parent, _current)));
    }

    override
    public void putMap()
    {
        putElement(cast(IElement)(new MapElement(_parent, _current)));
    }

    override
    public void putArray(bool described, DataType type)
    {
        putElement(cast(IElement)(new ArrayElement(_parent,_current, described, type)));

    }

    override
    public void putDescribed()
    {
        putElement(cast(IElement)(new DescribedTypeElement(cast(Element!(DescribedType))_parent, cast(Element!(DescribedType))_current)));
    }

    override
    public void putNull()
    {
        putElement(cast(IElement)(new NullElement(_parent, _current)));

    }

    override
    public void putBoolean(bool b)
    {
        putElement(cast(IElement)(new BooleanElement(_parent,_current, b)));
    }

    override
    public void putUnsignedByte(UnsignedByte ub)
    {
        putElement(cast(IElement)(new UnsignedByteElement(_parent, _current, ub)));

    }

    override
    public void putByte(byte b)
    {
        putElement(cast(IElement)(new ByteElement(_parent, _current, b)));
    }

    override
    public void putUnsignedShort(UnsignedShort us)
    {
        putElement(cast(IElement)(new UnsignedShortElement(_parent, _current, us)));

    }

    override
    public void putShort(short s)
    {
        putElement(cast(IElement)(new ShortElement(cast(Element!Short)_parent, cast(Element!Short)_current, s)));
    }

    override
    public void putUnsignedInteger(UnsignedInteger ui)
    {
        putElement(cast(IElement)(new UnsignedIntegerElement(_parent, _current, ui)));
    }

    override
    public void putInt(int i)
    {
        putElement(cast(IElement)(new IntegerElement(_parent, _current, i)));
    }

    override
    public void putChar(int c)
    {
        putElement(cast(IElement)(new CharElement(_parent, _current, c)));
    }

    override
    public void putUnsignedLong(UnsignedLong ul)
    {
        putElement(cast(IElement)(new UnsignedLongElement(_parent, _current, ul)));
    }

    override
    public void putLong(long l)
    {
        putElement(cast(IElement)(new LongElement(_parent, _current, l)));
    }

    override
    public void putTimestamp(Date t)
    {
        putElement(cast(IElement)(new TimestampElement(_parent,_current,t)));
    }

    override
    public void putFloat(float f)
    {
        putElement(cast(IElement)(new FloatElement(_parent,_current,f)));
    }

    override
    public void putDouble(double d)
    {
        putElement(cast(IElement)(new DoubleElement(_parent,_current,d)));
    }

    override
    public void putDecimal32(Decimal32 d)
    {
        putElement(cast(IElement)(new Decimal32Element(cast(Element!Decimal32)_parent,cast(Element!Decimal32)_current,d)));
    }

    override
    public void putDecimal64(Decimal64 d)
    {
        putElement(cast(IElement)(new Decimal64Element(cast(Element!Decimal64)_parent,cast(Element!Decimal64)_current,d)));
    }

    override
    public void putDecimal128(Decimal128 d)
    {
       // putElement(cast(IElement)(new Decimal128Element(_parent,_current,d)));
    }

    override
    public void putUUID(UUID u)
    {
        //putElement(new UUIDElement(_parent,_current,u));
    }

    override
    public void putBinary(Binary bytes)
    {
        putElement(cast(IElement)(new BinaryElement(_parent, _current, bytes)));
    }

    override
    public void putBinary(byte[] bytes)
    {
        putBinary(new Binary(bytes));
    }

    override
    public void putString(string str)
    {
        putElement(cast(IElement)(new StringElement(_parent,_current,str)));
    }

    override
    public void putSymbol(Symbol symbol)
    {
        putElement(cast(IElement)(new SymbolElement(_parent,_current,symbol)));
    }

    override
    public void putObject(Object o)
    {
        if(o is null)
        {
            putNull();
            return;
        }

        Boolean toBool = cast(Boolean)o;
        if (toBool !is null)
        {
            putBoolean(toBool.booleanValue);
            return;
        }

        UnsignedByte toUbyte = cast(UnsignedByte)o;
        if (toUbyte !is null)
        {
            putUnsignedByte(toUbyte);
            return;
        }

        Byte toByte = cast(Byte)o;
        if (toByte !is null)
        {
            putByte(toByte.byteValue);
            return;
        }

        UnsignedShort toUshort = cast(UnsignedShort)o;
        if (toUshort !is null)
        {
            putUnsignedShort(toUshort);
            return;
        }

        Short toShort = cast(Short)o;
        if (toShort !is null)
        {
            putShort(toShort.shortValue);
            return;
        }

        UnsignedInteger toUint = cast(UnsignedInteger)o;
        if (toUint !is null)
        {
            putUnsignedInteger(toUint);
            return;
        }

        Integer toInt = cast(Integer)o;
        if (toInt !is null)
        {
            putInt(toInt.intValue);
            return;
        }

        Char toChar = cast(Char)o;
        if (toChar !is null)
        {
            putChar(toChar.charValue);
            return;
        }

        UnsignedLong toUlong= cast(UnsignedLong)o;
        if (toUlong !is null)
        {
            putUnsignedLong(toUlong);
            return;
        }

        Long toLong = cast(Long)o;
        if (toLong !is null)
        {
            putLong(toLong.longValue);
            return;
        }

        Date toDate = cast(Date)o;
        if (toDate !is null)
        {
            putTimestamp(toDate);
            return;
        }

        Float toFloat = cast(Float)o;
        if (toFloat !is null)
        {
            putFloat(toFloat.floatValue);
            return;
        }

        Double toDouble = cast(Double)o;
        if (toDouble !is null)
        {
            putDouble(toDouble.longValue);
            return;
        }

        Decimal32 toDem32 = cast(Decimal32)o;
        if (toDem32 !is null)
        {
            putDecimal32(toDem32);
            return;
        }

        Decimal64 toDem64 = cast(Decimal64)o;
        if (toDem64 !is null)
        {
            putDecimal64(toDem64);
            return;
        }

        Decimal128 toDem128 = cast(Decimal128)o;
        if (toDem128 !is null)
        {
            putDecimal128(toDem128);
            return;
        }

        //UUID toUuid = cast(UUID)o;
        //if (toUuid !is null)
        //{
        //    putUUID(toUuid);
        //    return;
        //}

        Binary toBinary = cast(Binary)o;
        if (toBinary !is null)
        {
            putBinary(toBinary);
            return;
        }

        String toString = cast(String)o;
        if (toString !is null)
        {
            putString(cast(string)toString.getBytes);
            return;
        }

        Symbol toSymbol = cast(Symbol)o;
        if(toSymbol !is null)
        {
            putSymbol(toSymbol);
            return;
        }


        DescribedType toDescr = cast(DescribedType)o;
        if (toDescr !is null)
        {
            putDescribedType(toDescr);
            return;
        }

        //Symbol[] toSymbolArry = cast(Symbol[])o;
        //if (toSymbolArry !is null)
        //{
        //    putArray(false, Data.DataType.SYMBOL);
        //    enter();
        //    foreach(sym ; toSymbolArry)
        //    {
        //        putSymbol(sym);
        //    }
        //    exit();
        //    return;
        //}

        List!Object toList = cast(List!Object)o;
        if(toList !is null)
        {
            putJavaList(toList);
            return;
        }

        Map!(Object,Object) toMap= cast(Map!(Object,Object))o;
        if(toMap !is null)
        {
            putJavaMap(toMap);
            return;
        }



        //else if(o instanceof Object[])
        //{
        //    throw new IllegalArgumentException("Unsupported array type");
        //}
        //else if(o instanceof List)
        //{
        //    putJavaList((List)o);
        //}
        //else if(o instanceof Map)
        //{
        //    putJavaMap((Map)o);
        //}
        //else
        throw new IllegalArgumentException("Unknown type " ~ typeid(o).stringof);

    }

    override
    public void putJavaMap(Map!(Object, Object) map)
    {
        putMap();
        enter();
        foreach(MapEntry!(Object, Object) entry ; map)
        {
            putObject(entry.getKey());
            putObject(entry.getValue());
        }
        exit();
    }

    override
    public void putJavaList(List!(Object) list)
    {
        putList();
        enter();
        foreach(Object o ; list)
        {
            putObject(o);
        }
        exit();
    }

    override
    public void putDescribedType(DescribedType dt)
    {
        putElement(cast(IElement)(new DescribedTypeElement(_parent,_current)));
        enter();
        putObject(dt.getDescriptor());
        putObject(dt.getDescribed());
        exit();
    }

    override
    public long getList()
    {
        ListElement toListEle = cast(ListElement)_current;
        if( toListEle !is null)
        {
            return toListEle.count();
        }
        throw new IllegalStateException("Current value not list");
    }

    override
    public long getMap()
    {
        MapElement toMapEle = cast(MapElement)_current;
        if(toMapEle !is null)
        {
            return toMapEle.count();
        }
        throw new IllegalStateException("Current value not map");
    }

    override
    public long getArray()
    {
        ArrayElement toArrayEle = cast(ArrayElement)_current;
        if(toArrayEle !is null)
        {
            return toArrayEle.count();
        }
        throw new IllegalStateException("Current value not array");
    }

    override
    public bool isArrayDescribed()
    {
        ArrayElement toArrayEle = cast(ArrayElement)_current;
        if(toArrayEle !is null)
        {
            return toArrayEle.isDescribed();
        }
        throw new IllegalStateException("Current value not array");
    }

    override
    public DataType getArrayType()
    {
        ArrayElement toArrayEle = cast(ArrayElement)_current;
        if(toArrayEle !is null)
        {
            return toArrayEle.getArrayDataType();
        }
        throw new IllegalStateException("Current value not array");
    }

    override
    public bool isDescribed()
    {
        return _current !is null && _current.getDataType() == DataType.DESCRIBED;
    }

    override
    public bool isNull()
    {
        return _current !is null && _current.getDataType() == DataType.NULL;
    }

    override
    public Boolean getBoolean()
    {
        BooleanElement toBoolEle = cast(BooleanElement)_current;
        if(toBoolEle !is null)
        {
            return cast(Boolean)toBoolEle.getValue();
        }
        throw new IllegalStateException("Current value not bool");
    }

    override
    public UnsignedByte getUnsignedByte()
    {
        UnsignedByteElement toUbyte = cast(UnsignedByteElement)_current;
        if(toUbyte !is null)
        {
            return cast(UnsignedByte)toUbyte.getValue();
        }
        throw new IllegalStateException("Current value not unsigned byte");
    }

    override
    public Byte getByte()
    {
        ByteElement toByteEle = cast(ByteElement)_current;
        if(toByteEle !is null)
        {
            return cast(Byte)toByteEle.getValue();
        }
        throw new IllegalStateException("Current value not byte");
    }

    override
    public UnsignedShort getUnsignedShort()
    {
        UnsignedShortElement toUShortEle = cast(UnsignedShortElement)_current;
        if(toUShortEle !is null)
        {
            return cast(UnsignedShort)toUShortEle.getValue();
        }
        throw new IllegalStateException("Current value not unsigned short");
    }

    override
    public Short getShort()
    {
        ShortElement toShortEle = cast(ShortElement)_current;
        if(toShortEle !is null)
        {
            return cast(Short)toShortEle.getValue();
        }
        throw new IllegalStateException("Current value not short");
    }

    override
    public UnsignedInteger getUnsignedInteger()
    {
        UnsignedIntegerElement toUIntEle = cast(UnsignedIntegerElement)_current;
        if(toUIntEle !is null)
        {
            return cast(UnsignedInteger)toUIntEle.getValue();
        }
        throw new IllegalStateException("Current value not unsigned integer");
    }

    override
    public Integer getInt()
    {
        IntegerElement toIntEle = cast (IntegerElement)_current;
        if(toIntEle !is null)
        {
            return cast(Integer)toIntEle.getValue();
        }
        throw new IllegalStateException("Current value not integer");
    }

    override
    public Integer getChar()
    {
        CharElement toCharEle = cast(CharElement)_current;
        if(toCharEle !is null)
        {
            return cast(Integer)toCharEle.getValue();
        }
        throw new IllegalStateException("Current value not char");
    }

    override
    public UnsignedLong getUnsignedLong()
    {
        UnsignedLongElement toUnLongEle = cast(UnsignedLongElement)_current;
        if(toUnLongEle !is null)
        {
            return cast(UnsignedLong)toUnLongEle.getValue();
        }
        throw new IllegalStateException("Current value not unsigned long");
    }

    override
    public Long getLong()
    {
        LongElement toLongEle = cast(LongElement)_current;
        if(toLongEle !is null)
        {
            return cast(Long)toLongEle.getValue();
        }
        throw new IllegalStateException("Current value not long");
    }

    override
    public Date getTimestamp()
    {
        TimestampElement toTimeEle = cast(TimestampElement)_current;
        if(toTimeEle !is null)
        {
            return cast(Date)toTimeEle.getValue();
        }
        throw new IllegalStateException("Current value not timestamp");
    }

    override
    public Float getFloat()
    {
        FloatElement toFloatEle = cast(FloatElement)_current;
        if(toFloatEle !is null)
        {
            return cast(Float)toFloatEle.getValue();
        }
        throw new IllegalStateException("Current value not float");
    }

    override
    public Double getDouble()
    {
        DoubleElement toDoubelEle = cast(DoubleElement)_current;
        if(toDoubelEle !is null)
        {
            return cast(Double)toDoubelEle.getValue();
        }
        throw new IllegalStateException("Current value not double");
    }

    override
    public Decimal32 getDecimal32()
    {
        Decimal32Element toDec32 = cast(Decimal32Element)_current;
        if(toDec32 !is null)
        {
            return toDec32.getValue();
        }
        throw new IllegalStateException("Current value not decimal32");
    }

    override
    public Decimal64 getDecimal64()
    {
        Decimal64Element toDec64 = cast(Decimal64Element)_current;
        if(toDec64 !is null)
        {
            return toDec64.getValue();
        }
        throw new IllegalStateException("Current value not decimal32");
    }

    override
    public Decimal128 getDecimal128()
    {
        //Decimal128Element toDec128 = cast(Decimal128Element)_current;
        //if(toDec128 !is null)
        //{
        //    return toDec128.getValue();
        //}
        //throw new IllegalStateException("Current value not decimal32");
        return null;
    }

    override
    public UUID getUUID()
    {
        implementationMissing(false);
        UUID tmp;
        return tmp;
        //UUIDElement toUuidEle = cast(UUIDElement)_current;
        //if(toUuidEle !is null)
        //{
        //    return toUuidEle.getValue();
        //}
        //throw new IllegalStateException("Current value not uuid");
    }

    override
    public Binary getBinary()
    {
        BinaryElement toBinary = cast(BinaryElement)_current;
        if(toBinary !is null)
        {
            return cast(Binary)(toBinary.getValue());
        }
        throw new IllegalStateException("Current value not binary");
    }

    override
    public String getString()
    {
        StringElement toStringEle = cast(StringElement)_current;
        if (toStringEle !is null)
        {
            return cast(String)(toStringEle.getValue());
        }
        throw new IllegalStateException("Current value not string");
    }

    override
    public Symbol getSymbol()
    {
        SymbolElement toSymbolEle = cast(SymbolElement)_current;
        if(toSymbolEle !is null)
        {
            return cast(Symbol)(toSymbolEle.getValue());
        }
        throw new IllegalStateException("Current value not symbol");
    }

    override
    public Object getObject()
    {
      //  return _current is null ? null : _current.getValue();
        return _current is null ? null : cast(Object)_current;
    }

    override
    public Map!(Object, Object) getJavaMap()
    {
        MapElement toMapEle = cast(MapElement)_current;
        if(toMapEle !is null)
        {
            return cast(Map!(Object, Object))(toMapEle.getValue());
        }
        throw new IllegalStateException("Current value not map");
    }

    override
    public List!Object getJavaList()
    {
        ListElement toListEle = cast(ListElement)_current;
        if(toListEle !is null)
        {
            return cast(List!Object)(toListEle.getValue());
        }
        throw new IllegalStateException("Current value not list");
    }

    override
    public List!Object getJavaArray()
    {
        ArrayElement toArrayEle = cast(ArrayElement)_current;
        if(toArrayEle !is null)
        {
            return cast(List!Object)(toArrayEle.getValue());
        }
        throw new IllegalStateException("Current value not array");
    }

    override
    public DescribedType getDescribedType()
    {
        DescribedTypeElement toDescEle = cast(DescribedTypeElement)_current;
        if(toDescEle !is null)
        {
            return cast(DescribedType)(toDescEle.getValue());
        }
        throw new IllegalStateException("Current value not described type");
    }

    override
    public string format()
    {
        //string sb;
        //Element el = _first;
        //bool first = true;
        //while (el != null) {
        //    if (first) {
        //        first = false;
        //    } else {
        //        sb ~= ", ";
        //    }
        //    el.render(sb);
        //    el = el.next();
        //}

        return "";
    }

    //private void render(string sb, Element el)
    //{
    //    if (el is null) return;
    //    sb.append("    ").append(el).append("\n");
    //    sb = sb ~ "    " ~ "\n";
    //    if (el.canEnter()) {
    //        render(sb, el.child());
    //    }
    //    render(sb, el.next());
    //}

    //override
    //public String toString()
    //{
    //    StringBuilder sb = new StringBuilder();
    //    render(sb, _first);
    //    return String.format("Data[current=%h, parent=%h]{%n%s}",
    //                         System.identityHashCode(_current),
    //                         System.identityHashCode(_parent),
    //                         sb);
    //}
}
