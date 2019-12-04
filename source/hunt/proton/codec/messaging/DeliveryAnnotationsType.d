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


module hunt.proton.codec.messaging.DeliveryAnnotationsType;

import hunt.collection.Map;
import hunt.Object;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.DeliveryAnnotations;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Exceptions;
import std.concurrency : initOnce;
class DeliveryAnnotationsType : AbstractDescribedType!(DeliveryAnnotations,Map!(Symbol, Object)) , DescribedTypeConstructor!(DeliveryAnnotations)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000071L), Symbol.valueOf("amqp:delivery-annotations:map"),
    //};

  //  private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000071L);

    static Object[] DESCRIPTORS() {
        __gshared Object[] inst;
        return initOnce!inst( [UnsignedLong.valueOf(0x0000000000000071L), Symbol.valueOf("amqp:delivery-annotations:map")]);
    }

    static UnsignedLong DESCRIPTOR() {
        __gshared UnsignedLong inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000071L));
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
    protected Map!(Symbol, Object) wrap(DeliveryAnnotations val)
    {
        return val.getValue();
    }


    public DeliveryAnnotations newInstance(Object described)
    {
        return new DeliveryAnnotations( cast(Map!(Symbol, Object)) described );
    }

    public TypeInfo getTypeClass()
    {
        return typeid(DeliveryAnnotations);
    }

      

    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        DeliveryAnnotationsType type = new DeliveryAnnotationsType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
  