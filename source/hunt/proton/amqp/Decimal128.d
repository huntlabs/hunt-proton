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

module hunt.proton.amqp.Decimal128;

import hunt.math;
import hunt.Number;
import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;

class Decimal128 : Number
{
    private  BigDecimal _underlying;
    private  long _msb;
    private  long _lsb;

    this(BigDecimal underlying)
    {
        _underlying = underlying;

        _msb = calculateMostSignificantBits(underlying);
        _lsb = calculateLeastSignificantBits(underlying);
    }


    this(long msb,long lsb)
    {
        _msb = msb;
        _lsb = lsb;

        _underlying = calculateBigDecimal(msb, lsb);

    }

    this(byte[] data)
    {
        this(BufferUtils.toBuffer(data));
    }

    this(ByteBuffer buffer)
    {
        this(buffer.getLong(),buffer.getLong());
    }

    private static long calculateMostSignificantBits(BigDecimal underlying)
    {
        return 0;  //TODO.
    }

    private static long calculateLeastSignificantBits(BigDecimal underlying)
    {
        return 0;  //TODO.
    }

    private static BigDecimal calculateBigDecimal(long msb, long lsb)
    {
        return BigDecimal.ZERO;  //TODO.
    }

    override
    public int intValue()
    {
        return _underlying.intValue();
    }

    override
    public long longValue()
    {
        return _underlying.longValue();
    }

    override
    public float floatValue()
    {
        return _underlying.floatValue();
    }

    override
    public double doubleValue()
    {
        return _underlying.doubleValue();
    }

    public long getMostSignificantBits()
    {
        return _msb;
    }

    public long getLeastSignificantBits()
    {
        return _lsb;
    }

    public byte[] asBytes()
    {
        byte[] bytes = new byte[16];
        ByteBuffer buf = BufferUtils.toBuffer(bytes);

        buf.putLong(getMostSignificantBits());
        buf.putLong(getLeastSignificantBits());
        return bytes;
    }

    override bool opEquals(Object o)
    {
        if (this is o)
        {
            return true;
        }
        if (o is null || cast(Decimal128)o is null)
        {
            return false;
        }

        Decimal128 that = cast(Decimal128)o;

        if (_lsb != that._lsb)
        {
            return false;
        }
        if (_msb != that._msb)
        {
            return false;
        }

        return true;
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


    //override
    //public int hashCode()
    //{
    //    int result = (int) (_msb ^ (_msb >>> 32));
    //    result = 31 * result + (int) (_lsb ^ (_lsb >>> 32));
    //    return result;
    //}
}
