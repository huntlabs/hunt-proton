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

module hunt.proton.amqp.UnsignedByte;

import hunt.math;
import hunt.Number;
import std.algorithm.comparison;
import std.conv : to;
import hunt.logging;


import std.concurrency : initOnce;

class UnsignedByte : Number
{
    private byte _underlying;
    //private static UnsignedByte[] cachedValues = new UnsignedByte[256];


    static UnsignedByte[]  cachedValues() {
        __gshared UnsignedByte[]  inst;
        return initOnce!inst(initCachedVal());
    }


    static UnsignedByte[] initCachedVal ()
    {
        UnsignedByte[] uByteArray = new  UnsignedByte[256];
        for(int i = 0; i<256; i++)
        {
            uByteArray[i] = new UnsignedByte(cast(byte)i);
        }
        return uByteArray;
    }

    this(byte underlying)
    {
        _underlying = underlying;
    }

    override
    public byte byteValue()
    {
        return _underlying;
    }

    override
    public short shortValue()
    {
        return to!short(intValue());
    }

    override
    public int intValue()
    {
        return (to!int(_underlying)) & 0xFF;
    }

    override
    public long longValue()
    {
        return (to!long (_underlying)) & 0xFF;
    }

    override
    public float floatValue()
    {
        return (to!float(longValue()));
    }

    override
    public double doubleValue()
    {
        return  to!double(longValue());
    }

    override bool opEquals(Object o)
    {
        if (this is o)
        {
            return true;
        }
        if (o is null || cast(UnsignedByte)o is null)
        {
            return false;
        }

        UnsignedByte that = cast(UnsignedByte)o;

        if (_underlying != that._underlying)
        {
            return false;
        }

        return true;
    }


    override int opCmp(Object o)
    {
        UnsignedByte that = cast(UnsignedByte)o;
        return intValue() - that.intValue();
    }

    override
    public  size_t toHash() @trusted nothrow
    {
        return cast(size_t)_underlying;
    }

    override
    public string toString()
    {
        return "";
    }

    public static UnsignedByte valueOf(byte underlying)
    {
        int index = (to!int (underlying)) & 0xFF;
        return cachedValues[index];
    }

    public static UnsignedByte valueOf(string value)
           // throws NumberFormatException
    {
        int intVal = to!int(value);
        if(intVal < 0 || intVal >= (1<<8))
        {
            logError("Value %s lies outside the range",value);
        }
        return valueOf(to!byte(intVal));
    }

}