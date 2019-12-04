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

module hunt.proton.codec.Encoder;

import hunt.proton.codec.AMQPType;
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

import hunt.collection.List;
import hunt.collection.Map;

import hunt.time.LocalDateTime;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.Boolean;
import hunt.Byte;
import hunt.Short;
import hunt.Integer;
import hunt.Long;
import hunt.Char;
import hunt.Double;
import hunt.Float;
import hunt.String;
import std.uuid;


alias Date = hunt.time.LocalDateTime.LocalDateTime;

interface Encoder
{
    void writeNull();

    void writeBoolean(bool b);

    void writeBoolean(Boolean b);

    void writeUnsignedByte(UnsignedByte ub);

    void writeUnsignedShort(UnsignedShort us);

    void writeUnsignedInteger(UnsignedInteger us);

    void writeUnsignedLong(UnsignedLong ul);

    void writeByte(byte b);

    void writeByte(Byte b);

    void writeShort(short s);

    void writeShort(Short s);

    void writeInteger(int i);

    void writeInteger(Integer i);

    void writeLong(long l);

    void writeLong(Long l);

    void writeFloat(float f);

    void writeFloat(Float f);

    void writeDouble(double d);

    void writeDouble(Double d);

    void writeDecimal32(Decimal32 d);

    void writeDecimal64(Decimal64 d);

    void writeDecimal128(Decimal128 d);

    void writeCharacter(char c);

    void writeCharacter(Char c);

    void writeTimestamp(long d);

    void writeTimestamp(Date d);

    void writeUUID(UUID uuid);

    void writeBinary(Binary b);

    void writeString(String s);

    void writeSymbol(Symbol s);

    void writeList(Object l);

    void writeMap(Object m);

    void writeDescribedType(DescribedType d);

    //void writeArray(bool[] a);
    //void writeArray(byte[] a);
    //void writeArray(short[] a);
    void writeArray(int[] a);
    void writeArray(long[] a);
    void writeArray(float[] a);
    void writeArray(double[] a);
    void writeArray(char[] a);
    void writeArray(Object[] a);

    void writeObject(Object o);

   // void register(V)(AMQPType!(V) type);

   // AMQPType getType(Object element);
}
