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

module hunt.proton.codec.messaging.AcceptedType;

import hunt.Object;
import hunt.collection.List;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Accepted;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.collection.ArrayList;
import hunt.Exceptions;

import std.concurrency : initOnce;

class AcceptedType : AbstractDescribedType!(Accepted, List!Object) , DescribedTypeConstructor!(Accepted)
{

    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000024L), Symbol.valueOf("amqp:accepted:list"),
    //};

  //  private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000024L);



    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000024L), Symbol.valueOf("amqp:accepted:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000024L));
    }

    this(EncoderImpl encoder)
    {
        super(encoder);
    }

    override
    protected UnsignedLong getDescriptor()
    {
        return DESCRIPTOR;
    }

    override
    protected List!Object wrap(Accepted val)
    {
        return new ArrayList!Object();
    }

    override
    public TypeInfo getTypeClass()
    {
        return typeid(Accepted);
    }

    public Accepted newInstance(Object described)
    {
        return Accepted.getInstance();
    }

    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        AcceptedType type = new AcceptedType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
