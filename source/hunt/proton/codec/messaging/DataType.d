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


module hunt.proton.codec.messaging.DataType;


import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Data;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;

import hunt.Exceptions;
import std.concurrency : initOnce;

class DataType : AbstractDescribedType!(Data,Binary) , DescribedTypeConstructor!(Data)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000075L), Symbol.valueOf("amqp:data:binary"),
    //};

    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000075L);

    static Object[] DESCRIPTORS() {
        __gshared Object[] inst;
        return initOnce!inst([ UnsignedLong.valueOf(0x0000000000000075L), Symbol.valueOf("amqp:data:binary")]);
    }


    static UnsignedLong DESCRIPTOR() {
        __gshared UnsignedLong inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000075L));
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
    protected Binary wrap(Data val)
    {
        return val.getValue();
    }

    public Data newInstance(Object described)
    {
        return new Data( cast(Binary) described );
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Data);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        DataType type = new DataType(encoder);
       // implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
