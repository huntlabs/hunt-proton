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

module hunt.proton.amqp.Decimal64;

import hunt.math;
import hunt.Number;

class Decimal64 : Number
{
    private  BigDecimal _underlying;
    private  long _bits;

    this(BigDecimal underlying)
    {
        _underlying = underlying;
        _bits = calculateBits(underlying);

    }


    this(long bits)
    {
        _bits = bits;
        _underlying = calculateBigDecimal(bits);
    }

    static BigDecimal calculateBigDecimal(long bits)
    {
        return BigDecimal.ZERO;
    }

    static long calculateBits(BigDecimal underlying)
    {
        return 0; // TODO
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

    public long getBits()
    {
        return _bits;
    }

    override bool opEquals(Object o)
    {
        if (this is o)
        {
            return true;
        }
        if (o is null ||  cast(Decimal64)o is null)
        {
            return false;
        }

        Decimal64 decimal64 =  cast(Decimal64)o;

        if (_bits != decimal64._bits)
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
}
