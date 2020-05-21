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

module hunt.proton.codec.Data;

import hunt.io.ByteBuffer;
import hunt.time.LocalDateTime;
import hunt.collection.List;
import hunt.collection.Map;
import std.uuid;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Decimal128;
import hunt.proton.amqp.Decimal32;
import hunt.proton.amqp.Decimal64;
import hunt.proton.amqp.DescribedType;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedByte;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.UnsignedShort;

import hunt.proton.codec.impl.DataImpl;
import hunt.Long;
import hunt.String;
import hunt.Byte;
import hunt.Short;
import hunt.Double;
import hunt.Integer;
import hunt.Float;
import hunt.Boolean;

interface Data
{

    class Factory {

        static Data create() {
            return new DataImpl();
        }

    }


    enum DataType
    {
        NULL,
        BOOL,
        UBYTE,
        BYTE,
        USHORT,
        SHORT,
        UINT,
        INT,
        CHAR,
        ULONG,
        LONG,
        TIMESTAMP,
        FLOAT,
        DOUBLE,
        DECIMAL32,
        DECIMAL64,
        DECIMAL128,
        UUID,
        BINARY,
        STRING,
        SYMBOL,
        DESCRIBED,
        ARRAY,
        LIST,
        MAP
    }

    void free();

    void clear();
    long size();
    void rewind();
    DataType next();
    DataType prev();
    bool enter();
    bool exit();

    DataType type();

    Binary encode();
    long encodedSize();
    long encode(ByteBuffer buf);
    long decode(ByteBuffer buf);

    void putList();
    void putMap();
    void putArray(bool described, DataType type);
    void putDescribed();
    void putNull();
    void putBoolean(bool b);
    void putUnsignedByte(UnsignedByte ub);
    void putByte(byte b);
    void putUnsignedShort(UnsignedShort us);
    void putShort(short s);
    void putUnsignedInteger(UnsignedInteger ui);
    void putInt(int i);
    void putChar(int c);
    void putUnsignedLong(UnsignedLong ul);
    void putLong(long l);
    void putTimestamp(hunt.time.LocalDateTime.LocalDateTime t);
    void putFloat(float f);
    void putDouble(double d);
    void putDecimal32(Decimal32 d);
    void putDecimal64(Decimal64 d);
    void putDecimal128(Decimal128 d);
    void putUUID(UUID u);
    void putBinary(Binary bytes);
    void putBinary(byte[] bytes);
    void putString(string str);
    void putSymbol(Symbol symbol);
    void putObject(Object o);
    void putJavaMap(Map!(Object, Object) map);
    void putJavaList(List!(Object) list);
    void putDescribedType(DescribedType dt);

    long getList();
    long getMap();
    long getArray();
    bool isArrayDescribed();
    DataType getArrayType();
    bool isDescribed();
    bool isNull();
    Boolean getBoolean();
    UnsignedByte getUnsignedByte();
    Byte getByte();
    UnsignedShort getUnsignedShort();
    Short getShort();
    UnsignedInteger getUnsignedInteger();
    Integer getInt();
    Integer getChar();
    UnsignedLong getUnsignedLong();
    Long getLong();
    hunt.time.LocalDateTime.LocalDateTime getTimestamp();
    Float getFloat();
    Double getDouble();
    Decimal32 getDecimal32();
    Decimal64 getDecimal64();
    Decimal128 getDecimal128();
    UUID getUUID();
    Binary getBinary();
    String getString();
    Symbol getSymbol();
    Object getObject();
    Map!(Object, Object) getJavaMap();
    List!(Object) getJavaList();
    List!(Object) getJavaArray();
    DescribedType getDescribedType();

    string format();
}
