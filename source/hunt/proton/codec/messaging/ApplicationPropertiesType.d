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


module hunt.proton.codec.messaging.ApplicationPropertiesType;

import hunt.Object;
import hunt.collection.Map;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.ApplicationProperties;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Exceptions;
import std.concurrency : initOnce;
import hunt.String;

class ApplicationPropertiesType  : AbstractDescribedType!(ApplicationProperties,Map!(String, Object)) , DescribedTypeConstructor!(ApplicationProperties)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000074L), Symbol.valueOf("amqp:application-properties:map"),
    //};

    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000074L);


    static  Object[] DESCRIPTORS() {
        __gshared  Object[] inst;
        return initOnce!inst([ UnsignedLong.valueOf(0x0000000000000074L), Symbol.valueOf("amqp:application-properties:map")]);
    }

    static UnsignedLong DESCRIPTOR() {
        __gshared UnsignedLong inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000074L));
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
    protected  Map!(String, Object) wrap(ApplicationProperties val)
    {
        return val.getValue();
    }


    public ApplicationProperties newInstance(Object described)
    {
        return new ApplicationProperties( cast( Map!(String, Object)) described );
    }

    public TypeInfo getTypeClass()
    {
        return typeid(ApplicationProperties);
    }

      

    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        ApplicationPropertiesType type = new ApplicationPropertiesType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register!ApplicationProperties(type);
    }
}
  