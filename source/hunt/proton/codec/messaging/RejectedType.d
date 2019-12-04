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


module hunt.proton.codec.messaging.RejectedType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.Object;
import hunt.Exceptions;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Rejected;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.amqp.transport.ErrorCondition;

import std.concurrency : initOnce;
import std.conv:to;
import hunt.Exceptions;

class RejectedWrapper : AbstractList!Object
{
    private Rejected _impl;

    this(Rejected impl)
    {
        _impl = impl;
    }

    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _impl.getError();
            default:
            return null;
        }

        //  throw new IllegalStateException("Unknown index " ~ to!string(index));

    }

    override
    public int size()
    {
        return _impl.getError() !is null
        ? 1
        : 0;

    }
}

class RejectedType  : AbstractDescribedType!(Rejected,List!Object) , DescribedTypeConstructor!(Rejected)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000025L), Symbol.valueOf("amqp:rejected:list"),
    //};

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000025L);


    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000025L), Symbol.valueOf("amqp:rejected:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000025L));
    }

    this(EncoderImpl encoder)
    {
        super(encoder);
    }

    override
    public UnsignedLong getDescriptor()
    {
        return DESCRIPTOR;
    }

    override
    protected List!Object wrap(Rejected val)
    {
        return new RejectedWrapper(val);
    }




    public Rejected newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        Rejected o = new Rejected();

        switch(1 - l.size())
        {
            case 0:
                o.setError( cast(ErrorCondition) l.get( 0 ) );
                break;
            default:
                break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Rejected);
    }


    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        RejectedType type = new RejectedType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
  