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

module hunt.proton.codec.impl.DataDecoder;


import hunt.collection.ByteBuffer;
import hunt.proton.codec.Data;
import hunt.Exceptions;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedByte;
import hunt.proton.amqp.UnsignedShort;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.Decimal64;
import std.datetime.date;
import hunt.proton.amqp.Decimal32;
import hunt.proton.amqp.Decimal128;
import hunt.proton.amqp.Symbol;
import hunt.text.Charset;
import hunt.time.LocalDateTime;
import std.concurrency : initOnce;
import std.conv :to ;

interface TypeConstructor
{
    Data.DataType getType();

    int size(ByteBuffer b);

    void parse(ByteBuffer b, Data data);
}


class DataDecoder
{

    //private static Charset ASCII = StandardCharsets.US-ASCII;
    //private static Charset UTF_8 = StandardCharsets.UTF-8;

     //TypeConstructor[] _constructors = new TypeConstructor[256];


    static TypeConstructor[] _constructors()
    {
        __gshared TypeConstructor[] inst;
        return initOnce!inst(initConstructors());
    }
    //
    //private static UnsignedInteger[] initConstructor()
    //{
    //
    //}


    static TypeConstructor[] initConstructors()
    {
        TypeConstructor[] _constructors = new TypeConstructor[256];

        _constructors[0x00] = new DescribedTypeConstructor();

        _constructors[0x40] = new NullConstructor();
        _constructors[0x41] = new TrueConstructor();
        _constructors[0x42] = new FalseConstructor();
        _constructors[0x43] = new UInt0Constructor();
        _constructors[0x44] = new ULong0Constructor();
        _constructors[0x45] = new EmptyListConstructor();

        _constructors[0x50] = new UByteConstructor();
        _constructors[0x51] = new ByteConstructor();
        _constructors[0x52] = new SmallUIntConstructor();
        _constructors[0x53] = new SmallULongConstructor();
        _constructors[0x54] = new SmallIntConstructor();
        _constructors[0x55] = new SmallLongConstructor();
        _constructors[0x56] = new BooleanConstructor();

        _constructors[0x60] = new UShortConstructor();
        _constructors[0x61] = new ShortConstructor();

        _constructors[0x70] = new UIntConstructor();
        _constructors[0x71] = new IntConstructor();
        _constructors[0x72] = new FloatConstructor();
        _constructors[0x73] = new CharConstructor();
        _constructors[0x74] = new Decimal32Constructor();

        _constructors[0x80] = new ULongConstructor();
        _constructors[0x81] = new LongConstructor();
        _constructors[0x82] = new DoubleConstructor();
        _constructors[0x83] = new TimestampConstructor();
        _constructors[0x84] = new Decimal64Constructor();

        _constructors[0x94] = new Decimal128Constructor();
        _constructors[0x98] = new UUIDConstructor();

        _constructors[0xa0] = new SmallBinaryConstructor();
        _constructors[0xa1] = new SmallStringConstructor();
        _constructors[0xa3] = new SmallSymbolConstructor();

        _constructors[0xb0] = new BinaryConstructor();
        _constructors[0xb1] = new StringConstructor();
        _constructors[0xb3] = new SymbolConstructor();

        _constructors[0xc0] = new SmallListConstructor();
        _constructors[0xc1] = new SmallMapConstructor();


        _constructors[0xd0] = new ListConstructor();
        _constructors[0xd1] = new MapConstructor();

        _constructors[0xe0] = new SmallArrayConstructor();
        _constructors[0xf0] = new ArrayConstructor();
        return _constructors;
    }




    static int decode(ByteBuffer b, Data data)
    {
        if(b.hasRemaining())
        {
            int position = b.position();
            TypeConstructor c = readConstructor(b);
            int size = c.size(b);
            if(b.remaining() >= size)
            {
                c.parse(b, data);
                return 1+size;
            }
            else
            {
                b.position(position);
                return -4;
            }
        }
        return 0;
    }

    static TypeConstructor readConstructor(ByteBuffer b)
    {
        int index = b.get() & 0xff;
        TypeConstructor tc = _constructors[index];
        if(tc is null)
        {
            throw new IllegalArgumentException("No constructor for type " ~ to!string(index));
        }
        return tc;
    }





    static void parseChildren(Data data, ByteBuffer buf, int count)
    {
        data.enter();
        for(int i = 0; i < count; i++)
        {
            TypeConstructor c = readConstructor(buf);
            int size = c.size(buf);
            int remaining = buf.remaining();
            if(size <= remaining)
            {
                c.parse(buf, data);
            }
            else
            {
                throw new IllegalArgumentException("Malformed data");
            }

        }
        data.exit();
    }



    private static void parseArray(Data data, ByteBuffer buf, int count)
    {
        byte type = buf.get();
        bool isDescribed = type == cast(byte)0x00;
        int descriptorPosition = buf.position();
        if(isDescribed)
        {
            TypeConstructor descriptorTc = readConstructor(buf);
            buf.position(buf.position()+descriptorTc.size(buf));
            type = buf.get();
            if(type == cast(byte)0x00)
            {
                throw new IllegalArgumentException("Malformed array data");
            }

        }
        TypeConstructor tc = _constructors[type&0xff];

        data.putArray(isDescribed, tc.getType());
        data.enter();
        if(isDescribed)
        {
            int position = buf.position();
            buf.position(descriptorPosition);
            TypeConstructor descriptorTc = readConstructor(buf);
            descriptorTc.parse(buf,data);
            buf.position(position);
        }
        for(int i = 0; i<count; i++)
        {
            tc.parse(buf,data);
        }

        data.exit();
    }

}

class NullConstructor : TypeConstructor
{
    override
    public Data.DataType getType()
    {
        return Data.DataType.NULL;
    }

    override
    public int size(ByteBuffer b)
    {
        return 0;
    }

    override
    public void parse(ByteBuffer b, Data data)
    {
        data.putNull();
    }
}

class TrueConstructor : TypeConstructor
{
    override
    public Data.DataType getType()
    {
        return Data.DataType.BOOL;
    }

    override
    public int size(ByteBuffer b)
    {
        return 0;
    }

    override
    public void parse(ByteBuffer b, Data data)
    {
        data.putBoolean(true);
    }
}


class FalseConstructor : TypeConstructor
{

    override
    public Data.DataType getType()
    {
        return Data.DataType.BOOL;
    }

    override
    public int size(ByteBuffer b)
    {
        return 0;
    }

    override
    public void parse(ByteBuffer b, Data data)
    {
        data.putBoolean(false);
    }
}

class UInt0Constructor : TypeConstructor
{

    override
    public Data.DataType getType()
    {
        return Data.DataType.UINT;
    }

    override
    public int size(ByteBuffer b)
    {
        return 0;
    }

    override
    public void parse(ByteBuffer b, Data data)
    {
        data.putUnsignedInteger(UnsignedInteger.ZERO);
    }
}

class ULong0Constructor : TypeConstructor
{

    override
    public Data.DataType getType()
    {
        return Data.DataType.ULONG;
    }

    override
    public int size(ByteBuffer b)
    {
        return 0;
    }

    override
    public void parse(ByteBuffer b, Data data)
    {
        data.putUnsignedLong(UnsignedLong.ZERO);
    }
}


class EmptyListConstructor : TypeConstructor
{

    override
    public Data.DataType getType()
    {
        return Data.DataType.LIST;
    }

    override
    public int size(ByteBuffer b)
    {
        return 0;
    }

    override
    public void parse(ByteBuffer b, Data data)
    {
        data.putList();
    }
}


abstract class Fixed0SizeConstructor : TypeConstructor
{
    override
    public int size(ByteBuffer b)
    {
        return 0;
    }
}

abstract class Fixed1SizeConstructor : TypeConstructor
{
    override
    public int size(ByteBuffer b)
    {
        return 1;
    }
}

abstract class Fixed2SizeConstructor : TypeConstructor
{
    override
    public int size(ByteBuffer b)
    {
        return 2;
    }
}

abstract class Fixed4SizeConstructor : TypeConstructor
{
    override
    public int size(ByteBuffer b)
    {
        return 4;
    }
}

abstract class Fixed8SizeConstructor : TypeConstructor
{
    override
    public int size(ByteBuffer b)
    {
        return 8;
    }
}

abstract class Fixed16SizeConstructor : TypeConstructor
{
    override
    public int size(ByteBuffer b)
    {
        return 16;
    }
}

class UByteConstructor : Fixed1SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.UBYTE;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putUnsignedByte(UnsignedByte.valueOf(b.get()));
    }
}

class ByteConstructor : Fixed1SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.BYTE;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putByte(b.get());
    }
}

class SmallUIntConstructor : Fixed1SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.UINT;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putUnsignedInteger(UnsignedInteger.valueOf((cast(int) b.get()) & 0xff));
    }
}

class SmallIntConstructor : Fixed1SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.INT;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putInt(b.get());
    }
}

class SmallULongConstructor : Fixed1SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.ULONG;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putUnsignedLong(UnsignedLong.valueOf((cast(int) b.get()) & 0xff));
    }
}

class SmallLongConstructor : Fixed1SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.LONG;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putLong(b.get());
    }
}

class BooleanConstructor : Fixed1SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.BOOL;
    }

    public void parse(ByteBuffer b, Data data)
    {
        int i = b.get();
        if(i != 0 && i != 1)
        {
            throw new IllegalArgumentException("Illegal value " ~ to!string(i) ~ " for bool");
        }
        data.putBoolean(i == 1);
    }
}

class UShortConstructor : Fixed2SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.USHORT;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putUnsignedShort(UnsignedShort.valueOf(b.getShort()));
    }
}

class ShortConstructor : Fixed2SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.SHORT;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putShort(b.getShort());
    }
}

class UIntConstructor : Fixed4SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.UINT;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putUnsignedInteger(UnsignedInteger.valueOf(b.getInt()));
    }
}

class IntConstructor : Fixed4SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.INT;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putInt(b.getInt());
    }
}

class FloatConstructor : Fixed4SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.FLOAT;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putFloat(cast(float)b.getInt());
    }
}

class CharConstructor : Fixed4SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.CHAR;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putChar(b.getInt());
    }
}

class Decimal32Constructor : Fixed4SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.DECIMAL32;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putDecimal32(new Decimal32(b.getInt()));
    }
}

class ULongConstructor : Fixed8SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.ULONG;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putUnsignedLong(UnsignedLong.valueOf(b.getLong()));
    }
}

class LongConstructor : Fixed8SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.LONG;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putLong(b.getLong());
    }
}

class DoubleConstructor : Fixed8SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.DOUBLE;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putDouble(cast(double)b.getLong());
    }
}

class TimestampConstructor : Fixed8SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.TIMESTAMP;
    }

    public void parse(ByteBuffer b, Data data)
    {
        implementationMissing(false);
        data.putTimestamp(hunt.time.LocalDateTime.LocalDateTime.ofEpochMilli(b.getLong()));
    }
}

class Decimal64Constructor : Fixed8SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.DECIMAL64;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putDecimal64(new Decimal64(b.getLong()));
    }
}

class Decimal128Constructor : Fixed16SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.DECIMAL128;
    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putDecimal128(new Decimal128(b.getLong(), b.getLong()));
    }
}

class UUIDConstructor : Fixed16SizeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.UUID;
    }

    public void parse(ByteBuffer b, Data data)
    {
       // data.putUUID(new UUID(b.getLong(), b.getLong()));
    }
}

abstract class SmallVariableConstructor : TypeConstructor
{

    public int size(ByteBuffer b)
    {
        int position = b.position();
        if(b.hasRemaining())
        {
            int size = b.get() & 0xff;
            b.position(position);

            return size+1;
        }
        else
        {
            return 1;
        }
    }

}

abstract class VariableConstructor : TypeConstructor
{

    public int size(ByteBuffer b)
    {
        int position = b.position();
        if(b.remaining()>=4)
        {
            int size = b.getInt();
            b.position(position);

            return size+4;
        }
        else
        {
            return 4;
        }
    }

}


class SmallBinaryConstructor : SmallVariableConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.BINARY;
    }

    public void parse(ByteBuffer b, Data data)
    {
        int size = b.get() & 0xff;
        byte[] bytes = new byte[size];
        b.get(bytes);
        data.putBinary(bytes);
    }
}

class SmallSymbolConstructor : SmallVariableConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.SYMBOL;
    }

    public void parse(ByteBuffer b, Data data)
    {
        int size = b.get() & 0xff;
        byte[] bytes = new byte[size];
        b.get(bytes);
        data.putSymbol(Symbol.valueOf(cast(string)bytes));
    }
}


class SmallStringConstructor : SmallVariableConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.STRING;
    }

    public void parse(ByteBuffer b, Data data)
    {
        int size = b.get() & 0xff;
        byte[] bytes = new byte[size];
        b.get(bytes);
        data.putString(cast(string)bytes);
    }
}

class BinaryConstructor : VariableConstructor
{
    public Data.DataType getType()
    {
        return Data.DataType.BINARY;
    }

    public void parse(ByteBuffer b, Data data)
    {
        int size = b.getInt();
        byte[] bytes = new byte[size];
        b.get(bytes);
        data.putBinary(bytes);
    }
}

class SymbolConstructor : VariableConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.SYMBOL;
    }

    public void parse(ByteBuffer b, Data data)
    {
        int size = b.getInt();
        byte[] bytes = new byte[size];
        b.get(bytes);
        data.putSymbol(Symbol.valueOf(cast(string)bytes));
    }
}


class StringConstructor : VariableConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.STRING;
    }

    public void parse(ByteBuffer b, Data data)
    {
        int size = b.getInt();
        byte[] bytes = new byte[size];
        b.get(bytes);
        data.putString(cast(string)bytes);
    }
}


class SmallListConstructor : SmallVariableConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.LIST;
    }

    public void parse(ByteBuffer b, Data data)
    {
        int size = b.get() & 0xff;
        ByteBuffer buf = b.slice();
        buf.limit(size);
        b.position(b.position()+size);
        int count = buf.get() & 0xff;
        data.putList();
        DataDecoder.parseChildren(data, buf, count);
    }
}


class SmallMapConstructor : SmallVariableConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.MAP;
    }

    public void parse(ByteBuffer b, Data data)
    {
        int size = b.get() & 0xff;
        ByteBuffer buf = b.slice();
        buf.limit(size);
        b.position(b.position()+size);
        int count = buf.get() & 0xff;
        data.putMap();
        DataDecoder.parseChildren(data, buf, count);
    }
}


class ListConstructor : VariableConstructor
{
    public Data.DataType getType()
    {
        return Data.DataType.LIST;
    }
    public void parse(ByteBuffer b, Data data)
    {
        int size = b.getInt();
        ByteBuffer buf = b.slice();
        buf.limit(size);
        b.position(b.position()+size);
        int count = buf.getInt();
        data.putList();
        DataDecoder.parseChildren(data, buf, count);
    }
}


class MapConstructor : VariableConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.MAP;
    }

    public void parse(ByteBuffer b, Data data)
    {
        int size = b.getInt();
        ByteBuffer buf = b.slice();
        buf.limit(size);
        b.position(b.position()+size);
        int count = buf.getInt();
        data.putMap();
        DataDecoder.parseChildren(data, buf, count);
    }
}
class DescribedTypeConstructor : TypeConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.DESCRIBED;
    }
    public int size(ByteBuffer b)
    {
        ByteBuffer buf = b.slice();
        if(buf.hasRemaining())
        {
            TypeConstructor c = DataDecoder.readConstructor(buf);
            int size = c.size(buf);
            if(buf.remaining()>size)
            {
                buf.position(size + 1);
                c = DataDecoder.readConstructor(buf);
                return size + 2 + c.size(buf);
            }
            else
            {
                return size + 2;
            }
        }
        else
        {
            return 1;
        }

    }

    public void parse(ByteBuffer b, Data data)
    {
        data.putDescribed();
        data.enter();
        TypeConstructor c = DataDecoder.readConstructor(b);
        c.parse(b, data);
        c = DataDecoder.readConstructor(b);
        c.parse(b, data);
        data.exit();
    }
}

class SmallArrayConstructor : SmallVariableConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.ARRAY;
    }

    public void parse(ByteBuffer b, Data data)
    {

        int size = b.get() & 0xff;
        ByteBuffer buf = b.slice();
        buf.limit(size);
        b.position(b.position()+size);
        int count = buf.get() & 0xff;
        DataDecoder.parseArray(data, buf, count);
    }

}

class ArrayConstructor : VariableConstructor
{

    public Data.DataType getType()
    {
        return Data.DataType.ARRAY;
    }


    public void parse(ByteBuffer b, Data data)
    {

        int size = b.getInt();
        ByteBuffer buf = b.slice();
        buf.limit(size);
        b.position(b.position()+size);
        int count = buf.getInt();
        DataDecoder.parseArray(data, buf, count);
    }
}