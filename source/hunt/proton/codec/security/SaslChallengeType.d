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


module hunt.proton.codec.security.SaslChallengeType;

import hunt.collection.Collections;
import hunt.collection.List;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.security.SaslChallenge;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.logging;
import hunt.Object;
import std.concurrency : initOnce;

import hunt.Exceptions;


class SaslChallengeType : AbstractDescribedType!(SaslChallenge,List!Binary) , DescribedTypeConstructor!(SaslChallenge)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000042L), Symbol.valueOf("amqp:sasl-challenge:list"),
    //};

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000042L);


    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000042L), Symbol.valueOf("amqp:sasl-challenge:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000042L));
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
    protected List!Binary wrap(SaslChallenge val)
    {
        return Collections.singletonList!Binary(val.getChallenge());
    }



    public SaslChallenge newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        SaslChallenge o = new SaslChallenge();

        if(l.isEmpty())
        {
            logError("The challenge field cannot be omitted");
           // throw new DecodeException("The challenge field cannot be omitted");
        }

        o.setChallenge( cast(Binary) l.get( 0 ) );



        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(SaslChallenge);
    }



    static void register(Decoder decoder, EncoderImpl encoder)
    {
        SaslChallengeType type = new SaslChallengeType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }


}
