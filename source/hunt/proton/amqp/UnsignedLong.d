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

module hunt.proton.amqp.UnsignedLong;

import hunt.math;
import hunt.Number;
import std.algorithm.comparison;
import std.conv : to;
import hunt.logging;

import std.concurrency : initOnce;


class UnsignedLong : Number
{
    static UnsignedLong[] cachedValues ;
    static BigInteger TWO_TO_THE_SIXTY_FOUR;
    static BigInteger LONG_MAX_VALUE;
    static UnsignedLong ZERO;

    static UnsignedLong[] initCachedValues()
    {
        UnsignedLong[] cachedVal = new UnsignedLong[256];
        for(int i = 0; i<256; i++)
        {
            cachedValues[i] = new UnsignedLong(i);
        }
        return cachedVal;
    }

    //static UnsignedLong[]  cachedValues() {
    //    __gshared UnsignedLong[]  inst;
    //    return initOnce!inst(initCachedValues);
    //}



    static this()
    {
        cachedValues = new UnsignedLong[256];
        for(int i = 0; i<256; i++)
        {
            cachedValues[i] = new UnsignedLong(i);
        }
        UnsignedLong.TWO_TO_THE_SIXTY_FOUR = new BigInteger([1,0,0,0,0,0,0,0,0]);
        UnsignedLong.LONG_MAX_VALUE = BigInteger.valueOf(0x7FFFFFFFFFFFFFFF);
        UnsignedLong.ZERO = cachedValues[0];
    }



    private long _underlying;


    this(long underlying)
    {
        _underlying = underlying;
    }

    override
    public int intValue()
    {
        return cast(int) _underlying;
    }

    override
    public long longValue()
    {
        return _underlying;
    }

    public BigInteger bigIntegerValue()
    {
        if(_underlying >= 0L)
        {
            return BigInteger.valueOf(_underlying);
        }
        else
        {
            return TWO_TO_THE_SIXTY_FOUR.add(BigInteger.valueOf(_underlying));
        }
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
        if (o is null || (cast(UnsignedLong)o is null))
        {
            return false;
        }

        UnsignedLong that = cast(UnsignedLong)o;

        if (_underlying != that._underlying)
        {
            return false;
        }

        return true;
    }

     override int opCmp(Object o)
    {
        UnsignedLong that = cast(UnsignedLong)(o);
        return cast(int)(longValue() - that.longValue());
    }

    //override size_t toHash() @trusted nothrow {
    //    size_t hashcode = 0;
    //    hashcode = price * 20;
    //    hashcode += hashOf(item);
    //    return hashcode;
    //}

    override
    public  size_t toHash() @trusted nothrow
    {
        return cast(size_t)(_underlying ^ (_underlying >>> 32));
    }
    //
    //public string toString()
    //{
    //    return String.valueOf(bigIntegerValue());
    //}

    public static UnsignedLong valueOf(long underlying)
    {
        if((underlying & 0xFFL) == underlying)
        {
            return cachedValues[cast(int)(underlying)];
        }
        else
        {
            return new UnsignedLong(underlying);
        }
    }

    public static UnsignedLong valueOf(string value)
    {
        BigInteger bigInt = new BigInteger(value);

        return valueOf(bigInt);
    }

    public static UnsignedLong valueOf(BigInteger bigInt)
    {
        if(bigInt.signum() == -1 || bigInt.bitLength() > 64)
        {
           // throw new NumberFormatException("Value \""+bigInt+"\" lies outside the range [0 - 2^64).");
            logError("Value lies outside the range [0 - 2^64).");
            return null;
        }
        else if(bigInt.compareTo(LONG_MAX_VALUE)>=0)
        {
            return UnsignedLong.valueOf(bigInt.longValue());
        }
        else
        {
            return UnsignedLong.valueOf(TWO_TO_THE_SIXTY_FOUR.subtract(bigInt).negate().longValue());
        }
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