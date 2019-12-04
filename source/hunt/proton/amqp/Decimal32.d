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

module hunt.proton.amqp.Decimal32;

import hunt.math;
import hunt.Number;

class Decimal32 : Number
{
    private  BigDecimal _underlying;
    private  int _bits;

    this(BigDecimal underlying)
    {
        _underlying = underlying;
        _bits = calculateBits( underlying );
    }

    this( int bits)
    {
        _bits = bits;
        _underlying = calculateBigDecimal(bits);
    }

    static int calculateBits(BigDecimal underlying)
    {
        return 0;  //TODO.
    }

    static BigDecimal calculateBigDecimal(int bits)
    {
        return BigDecimal.ZERO; // TODO
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

    public int getBits()
    {
        return _bits;
    }

   override bool opEquals(Object o)
    {
        if (this is o)
        {
            return true;
        }
        if (o is null || cast(Decimal32)o is null)
        {
            return false;
        }

        Decimal32 decimal32 =  cast(Decimal32)o;

        if (_bits != decimal32.getBits())
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
