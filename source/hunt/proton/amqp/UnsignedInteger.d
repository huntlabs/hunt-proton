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

module hunt.proton.amqp.UnsignedInteger;


import hunt.math;
import hunt.Number;
import std.algorithm.comparison;
import std.conv : to;
import hunt.logging;

import std.concurrency : initOnce;


class UnsignedInteger : Number
{
    private int _underlying;
    //__gshared UnsignedInteger[] cachedValues ;


    //static UnsignedInteger ZERO() {
    //    return cachedValues[0];
    //}
    //static UnsignedInteger ONE ()  {return cachedValues[1];}

    static UnsignedInteger ZERO()
    {
        __gshared UnsignedInteger inst;
        return initOnce!inst(cachedValues[0]);
    }

    static UnsignedInteger ONE()
    {
        __gshared UnsignedInteger inst;
        return initOnce!inst(cachedValues[1]);
    }

    static UnsignedInteger[] cachedValues()
    {
        __gshared UnsignedInteger[] inst;
        return initOnce!inst(initCachedValues());
    }

    static UnsignedInteger MAX_VALUE()
    {
        __gshared UnsignedInteger inst;
        return initOnce!inst(new UnsignedInteger(0xffffffff));
    }

    private static UnsignedInteger[] initCachedValues()
    {
        UnsignedInteger[] cached = new UnsignedInteger[256];
        for(int i = 0; i < 256; i++)
        {
            cached[i] = new UnsignedInteger(i);
        }

        return cached;

    }

    //static this()
    //{
    //
    //    cachedValues  = new UnsignedInteger[256];
    //    for(int i = 0; i < 256; i++)
    //    {
    //        cachedValues[i] = new UnsignedInteger(i);
    //    }
    //
    //    static UnsignedInteger ZERO = cachedValues[0];
    //    static UnsignedInteger ONE = cachedValues[1];
    //    static UnsignedInteger MAX_VALUE = new UnsignedInteger(0xffffffff);
    //}


    this(int underlying)
    {
        _underlying = underlying;
    }

    override
    public int intValue()
    {
        return _underlying;
    }

    override
    public long longValue()
    {
        return (_underlying) & 0xFFFFFFFF;
    }

    override
    public float floatValue()
    {
        return cast(float) (longValue());
    }

    override
    public double doubleValue()
    {
        return cast(double) (longValue());
    }

    override bool opEquals(Object o)
    {
        if (this is o)
        {
            return true;
        }
        if (o is null || cast(UnsignedInteger)o is null)
        {
            return false;
        }

        UnsignedInteger that =  cast(UnsignedInteger)o;

        if (_underlying != that.intValue())
        {
            return false;
        }

        return true;
    }

     override int opCmp(Object o)
    {
        return cast(int)(longValue()  - (cast(UnsignedInteger)o).longValue());
    }

    override
    public  size_t toHash() @trusted nothrow
    {
        return  cast(size_t)_underlying;
    }
    //
    //override
    //public string toString()
    //{
    //    return to!string(longValue());
    //}

    public static UnsignedInteger valueOf(int underlying)
    {
        if((underlying & 0xFFFFFF00) == 0)
        {
            return cachedValues[underlying];
        }
        else
        {
            return new UnsignedInteger(underlying);
        }
    }

    public UnsignedInteger add(UnsignedInteger i)
    {
        int val = _underlying + i.intValue();
        return UnsignedInteger.valueOf(val);
    }

    public UnsignedInteger subtract(UnsignedInteger i)
    {
        int val = _underlying - i.intValue();
        return UnsignedInteger.valueOf(val);
    }

    public static UnsignedInteger valueOf(string value)
    {
        long longVal = to!long(value);
        return valueOf(longVal);
    }

    public static UnsignedInteger valueOf(long longVal)
    {
        if(longVal < 0L || longVal >= (1L<<32))
        {
            logError("lies outside the range");
        }
        return valueOf(cast (int)(longVal));
    }


    override
    byte byteValue()
    {
        return 1;
    }

    override short shortValue()
    {
        return 1;
    }

    override string toString()
    {
        return "";
    }
}
