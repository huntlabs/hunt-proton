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


module hunt.proton.codec.messaging.MessageAnnotationsType;
import hunt.collection.Map;

import hunt.Object;
import hunt.collection.Map;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.MessageAnnotations;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Exceptions;



import std.concurrency : initOnce;
class MessageAnnotationsType : AbstractDescribedType!(MessageAnnotations, Map!(Symbol, Object)) , DescribedTypeConstructor!(MessageAnnotations)

{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000072L), Symbol.valueOf("amqp:message-annotations:map"),
    //};

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000072L);


    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000072L), Symbol.valueOf("amqp:message-annotations:map")]);
    }

    static UnsignedLong DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000072L));
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
    protected Map!(Symbol, Object) wrap(MessageAnnotations val)
    {
        return val.getValue();
    }


    public MessageAnnotations newInstance(Object described)
    {
        return new MessageAnnotations( cast(Map!(Symbol, Object)) described );
    }

    public TypeInfo getTypeClass()
    {
        return typeid(MessageAnnotations);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        MessageAnnotationsType constructor = new MessageAnnotationsType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, constructor);
        }
        encoder.register(constructor);
    }
}
  