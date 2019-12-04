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
module hunt.proton.codec.messaging.ReceivedType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.Object;
import hunt.Exceptions;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Received;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import std.concurrency : initOnce;
import hunt.Exceptions;
import std.conv : to;

class ReceivedWrapper : AbstractList!Object
{
    private Received _impl;

    this(Received impl)
    {
        _impl = impl;
    }

    override
    public Object get(int index)
    {
        switch(index)
        {
            case 0:
            return _impl.getSectionNumber();
            case 1:
            return _impl.getSectionOffset();
            default:
            return null;
        }

        //  throw new IllegalStateException("Unknown index " ~ to!string(index));
    }

    override
    public int size()
    {
        return _impl.getSectionOffset() !is null
        ? 2
        : _impl.getSectionNumber() !is null
        ? 1
        : 0;
    }
}

class ReceivedType : AbstractDescribedType!(Received, List!Object) , DescribedTypeConstructor!(Received)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000023L), Symbol.valueOf("amqp:received:list"),
    //};

    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000023L);


    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000023L), Symbol.valueOf("amqp:received:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000023L));
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
    protected List!Object wrap(Received val)
    {
        return new ReceivedWrapper(val);
    }



    override
    public Received newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        Received o = new Received();

        switch(2 - l.size())
        {
            case 0:
                o.setSectionOffset(cast(UnsignedLong) l.get( 1 ));
                goto case;
            case 1:
                o.setSectionNumber(cast(UnsignedInteger) l.get( 0 ));
                break;
            default:
                break;
        }

        return o;
    }

    override
    public TypeInfo getTypeClass()
    {
        return typeid(Received);
    }

    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        ReceivedType type = new ReceivedType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
