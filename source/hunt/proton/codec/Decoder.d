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

module hunt.proton.codec.Decoder;

import hunt.proton.amqp.messaging.Section;
import hunt.proton.codec.FastPathDescribedTypeConstructor;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.Encoder;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Decimal128;
import hunt.proton.amqp.Decimal32;
import hunt.proton.amqp.Decimal64;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedByte;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.UnsignedShort;
import hunt.Object;

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

interface Decoder
{
    interface ListProcessor(T)
    {
        T process(int count, Encoder encoder);
    }


    Boolean readBoolean();
    Boolean readBoolean(Boolean defaultVal);
    bool readBoolean(bool defaultVal);

    Byte readByte();
    Byte readByte(Byte defaultVal);
    byte readByte(byte defaultVal);

    Short readShort();
    Short readShort(Short defaultVal);
    short readShort(short defaultVal);

    Integer readInteger();
    Integer readInteger(Integer defaultVal);
    int readInteger(int defaultVal);

    Long readLong();
    Long readLong(Long defaultVal);
    long readLong(long defaultVal);

    UnsignedByte readUnsignedByte();
    UnsignedByte readUnsignedByte(UnsignedByte defaultVal);

    UnsignedShort readUnsignedShort();
    UnsignedShort readUnsignedShort(UnsignedShort defaultVal);

    UnsignedInteger readUnsignedInteger();
    UnsignedInteger readUnsignedInteger(UnsignedInteger defaultVal);

    UnsignedLong readUnsignedLong();
    UnsignedLong readUnsignedLong(UnsignedLong defaultVal);

    Char readCharacter();
    Char readCharacter(Char defaultVal);
    char readCharacter(char defaultVal);

    Float readFloat();
    Float readFloat(Float defaultVal);
    float readFloat(float defaultVal);

    Double readDouble();
    Double readDouble(Double defaultVal);
    double readDouble(double defaultVal);

    UUID readUUID();
    UUID readUUID(UUID defaultValue);

    Decimal32 readDecimal32();
    Decimal32 readDecimal32(Decimal32 defaultValue);

    Decimal64 readDecimal64();
    Decimal64 readDecimal64(Decimal64 defaultValue);

    Decimal128 readDecimal128();
    Decimal128 readDecimal128(Decimal128 defaultValue);

    Date readTimestamp();
    Date readTimestamp(Date defaultValue);

    Binary readBinary();
    Binary readBinary(Binary defaultValue);

    Symbol readSymbol();
    Symbol readSymbol(Symbol defaultValue);

    String readString();
    String readString(String defaultValue);

   // List readList();
    //void readList(T)(ListProcessor!(T) processor);

  //  IObject readMap();

  //  <T> T[] readArray(Class!(T) clazz);

  //  Object[] readArray();

    //bool[] readBooleanArray();
    //byte[] readByteArray();
    //short[] readShortArray();
    //int[] readIntegerArray();
    //long[] readLongArray();
    //float[] readFloatArray();
    //double[] readDoubleArray();
    //char[] readCharacterArray();

   // <T> T[] readMultiple(Class!(T) clazz);

    //Object[] readMultiple();
    //byte[] readByteMultiple();
    //short[] readShortMultiple();
    //int[] readIntegerMultiple();
    //long[] readLongMultiple();
    //float[] readFloatMultiple();
    //double[] readDoubleMultiple();
    //char[] readCharacterMultiple();

    Object readObject();
    Object readObject(Object defaultValue);

    void registerDynamic(Object descriptor, Object dtc);

    void registerFastPath(Object descriptor, Object dtc);

}
