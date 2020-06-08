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

module hunt.proton.amqp.UnsignedShort;

import hunt.math;
import hunt.Number;
import std.algorithm.comparison;
import std.conv : to;
import hunt.logging;

import std.concurrency : initOnce;

class UnsignedShort : AbstractNumber!short
{
    // private short _underlying;
   // private static UnsignedShort[] cachedValues = new UnsignedShort[256];
   // static UnsignedShort MAX_VALUE;

    static UnsignedShort[] cachedValues() {
        __gshared UnsignedShort[]  inst;
        return initOnce!inst(initCachedVal());
    }

    static UnsignedShort MAX_VALUE() {
        __gshared UnsignedShort  inst;
        return initOnce!inst(new UnsignedShort(cast(short)-1));
    }


    static  UnsignedShort[]  initCachedVal()
    {
        UnsignedShort[] rt = new UnsignedShort[256];
        for(short i = 0; i < 256; i++)
        {
            rt[i] = new UnsignedShort(i);
        }
     //   UnsignedShort.MAX_VALUE = new UnsignedShort(cast(short)-1);
        return rt;
    }

    this(short value)
    {
        super(value);
    }

    // public short shortValue()
    // {
    //     return _underlying;
    // }

    // override
    // public int intValue()
    // {
    //     return _underlying & 0xFFFF;
    // }

    // override
    // public long longValue()
    // {
    //     return (cast(long) (_underlying)) & 0xFFFF;
    // }

    // override
    // public float floatValue()
    // {
    //     return cast(float) (intValue());
    // }

    // override
    // public double doubleValue()
    // {
    //     return cast(double) (intValue());
    // }

    // override bool opEquals(Object o)
    // {
    //     if (this is o)
    //     {
    //         return true;
    //     }
    //     if (o is null || cast(UnsignedShort)o is null)
    //     {
    //         return false;
    //     }

    //     UnsignedShort that = cast(UnsignedShort) o;

    //     if (_underlying != that.shortValue())
    //     {
    //         return false;
    //     }

    //     return true;
    // }

    override int opCmp(Object o)
    {
        return intValue() - (cast(UnsignedShort)o).intValue();
    }

    // override
    // public  size_t toHash() @trusted nothrow
    // {
    //     return cast(size_t)_underlying;
    // }
    //
    //override
    //public String toString()
    //{
    //    return String.valueOf(longValue());
    //}

    public static UnsignedShort valueOf(short underlying)
    {
        if((underlying & 0xFF00) == 0)
        {
            return cachedValues[underlying];
        }
        else
        {
            return new UnsignedShort(underlying);
        }
    }

    public static UnsignedShort valueOf(string value)
    {
        int intVal = to!int(value);
        if(intVal < 0 || intVal >= (1<<16))
        {
            logError("Value %s lies outside the range",value);
        }
        return valueOf(to!short (intVal));

    }


    // override
    // byte byteValue()
    // {
    //     return 1;
    // }


    // override string toString()
    // {
    //     return "";
    // }
}