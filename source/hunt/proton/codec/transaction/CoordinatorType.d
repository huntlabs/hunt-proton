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


module hunt.proton.codec.transaction.CoordinatorType;

import hunt.collection.Collections;
import hunt.collection.List;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transaction.Coordinator;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Object;
import hunt.Exceptions;
import hunt.logging;

import std.concurrency : initOnce;

class CoordinatorType : AbstractDescribedType!(Coordinator,List!(List!Symbol)) , DescribedTypeConstructor!(Coordinator)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000030L), Symbol.valueOf("amqp:coordinator:list"),
    //};
    //
    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000030L);

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000030L), Symbol.valueOf("amqp:coordinator:list")]);
    }

    static UnsignedLong DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000030L));
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
    protected List!(List!Symbol) wrap(Coordinator val)
    {
        auto capabilities = val.getCapabilities();
        return capabilities is null || capabilities.size() == 0
                ? null
                : Collections.singletonList!(List!Symbol)(capabilities);
    }


    public Coordinator newInstance(Object described)
    {
        List!(List!Symbol) l = cast(List!(List!Symbol)) described;

        Coordinator o = new Coordinator();


        switch(1 - l.size())
        {

            case 0:
                 List!Symbol val0 = l.get( 0 );
                //if( val0 is null || val0.getClass().isArray() )
                //{
                    o.setCapabilities( val0 );
                //}
                //else
                //{
                //    o.setCapabilities( (Symbol) val0 );
                //}
                 break;
            default:
                break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Coordinator);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        CoordinatorType type = new CoordinatorType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
  