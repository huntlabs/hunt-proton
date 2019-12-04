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


module hunt.proton.codec.messaging.ReleasedType;

import hunt.collection.List;
import hunt.Object;
import hunt.Exceptions;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Released;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.collection.ArrayList;

import std.concurrency : initOnce;
import hunt.Exceptions;

class ReleasedType : AbstractDescribedType!(Released,List!Object) , DescribedTypeConstructor!(Released)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000026L), Symbol.valueOf("amqp:released:list"),
    //};

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000026L);

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000026L), Symbol.valueOf("amqp:released:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000026L));
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
    protected List!Object wrap(Released val)
    {

        return new ArrayList!(Object) ();
    }


    public Released newInstance(Object described)
    {
        return Released.getInstance();
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Released);
    }

    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        ReleasedType type = new ReleasedType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
  