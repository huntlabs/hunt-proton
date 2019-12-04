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


module hunt.proton.codec.messaging.AmqpSequenceType;

import hunt.Object;
import hunt.Exceptions;
import hunt.collection.List;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.AmqpSequence;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Exceptions;
import std.concurrency : initOnce;

class AmqpSequenceType : AbstractDescribedType!(AmqpSequence,List!Object) , DescribedTypeConstructor!(AmqpSequence)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000076L), Symbol.valueOf("amqp:amqp-sequence:list"),
    //};

    static Object[] DESCRIPTORS() {
        __gshared Object[] inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000076L), Symbol.valueOf("amqp:amqp-sequence:list")]);
    }

    static UnsignedLong DESCRIPTOR() {
        __gshared UnsignedLong inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000076L));
    }


    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000076L);

    this(EncoderImpl encoder)
    {
        super(encoder);
    }

    override
    public UnsignedLong getDescriptor()
    {
        return DESCRIPTOR;
    }

     //M asUnderlying = wrap(val)

    override
    protected List!Object wrap(AmqpSequence val)
    {
        return cast(List!Object)val.getValue();
    }

    public AmqpSequence newInstance(Object described)
    {
        return new AmqpSequence( cast(List!Object)described );
    }

    public TypeInfo getTypeClass()
    {
        return typeid(AmqpSequence);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        AmqpSequenceType type = new AmqpSequenceType(encoder);
       // implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
