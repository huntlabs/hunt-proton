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


module hunt.proton.codec.messaging.AmqpValueType;


import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.AmqpValue;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Exceptions;
import std.concurrency : initOnce;
import hunt.String;

class AmqpValueType : AbstractDescribedType!(AmqpValue,String) , DescribedTypeConstructor!(AmqpValue)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000077L), Symbol.valueOf("amqp:amqp-value:*"),
    //};

    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000077L);

    static Object[] DESCRIPTORS() {
        __gshared Object[] inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000077L), Symbol.valueOf("amqp:amqp-value:*")]);
    }

    static UnsignedLong DESCRIPTOR() {
        __gshared UnsignedLong inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000077L));
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
    protected String wrap(AmqpValue val)
    {
        return val.getValue();
    }

    public AmqpValue newInstance(Object described)
    {
        return new AmqpValue( described);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(AmqpValue);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        AmqpValueType type = new AmqpValueType(encoder);
       // implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register!AmqpValue(type);
    }
}
