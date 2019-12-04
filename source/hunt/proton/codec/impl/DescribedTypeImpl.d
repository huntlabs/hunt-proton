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

module hunt.proton.codec.impl.DescribedTypeImpl;

import hunt.proton.amqp.DescribedType;

class DescribedTypeImpl : DescribedType
{
    private Object _descriptor;
    private Object _described;

    this(Object descriptor, Object described)
    {
        _descriptor = descriptor;
        _described = described;
    }

    override
    public Object getDescriptor()
    {
        return _descriptor;
    }

    override
    public Object getDescribed()
    {
        return _described;
    }

    override bool opEquals(Object o) {
        {
            if (this is o)
            {
                return true;
            }
            if (o is null || cast(DescribedTypeImpl)o is null)
            {
                return false;
            }

            DescribedType that = cast(DescribedType) o;

            if (_described !is null ? _described != ( that.getDescribed()) : that.getDescribed() !is null)
            {
                return false;
            }
            if (_descriptor !is null ? _descriptor !=( that.getDescriptor()) : that.getDescriptor() !is null)
            {
                return false;
            }

            return true;
        }

        //override
        //public int hashCode()
        //{
        //    int result = _descriptor != null ? _descriptor.hashCode() : 0;
        //    result = 31 * result + (_described != null ? _described.hashCode() : 0);
        //    return result;
        //}
        //
        //override
        //public String toString()
        //{
        //    return "{"  + _descriptor +
        //           ": " ~ _described +
        //           '}';
        //}
    }
}