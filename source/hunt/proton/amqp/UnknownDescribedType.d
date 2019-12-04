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

module hunt.proton.amqp.UnknownDescribedType;


import hunt.proton.amqp.DescribedType;

class UnknownDescribedType : DescribedType
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

    override bool opEquals(Object o)
    {
        if (this is o)
        {
            return true;
        }
        if (o is null || cast(UnknownDescribedType)o is null)
        {
            return false;
        }

        UnknownDescribedType that = cast(UnknownDescribedType)o;

        if (_described !is null ? _described != (that.getDescribed()) : that.getDescribed() !is null)
        {
            return false;
        }
        if (_descriptor !is null ? _descriptor != (that.getDescriptor()) : that.getDescriptor() !is null)
        {
            return false;
        }

        return true;
    }

    override
    public  size_t toHash() @trusted nothrow
    {
        int result = _descriptor !is null ? cast(int)_descriptor.hashOf : 0;
        result = 31 * result + (_described !is null ? cast(int)_described.hashOf : 0);
        return cast(size_t)result;
    }
    //
    //override
    //public String toString()
    //{
    //    return "UnknownDescribedType{" ~
    //           "descriptor=" ~ _descriptor +
    //           ", described=" ~ _described +
    //           '}';
    //}
}
