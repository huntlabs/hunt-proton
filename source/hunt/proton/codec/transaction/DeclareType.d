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


module hunt.proton.codec.transaction.DeclareType;

import hunt.collection.Collections;
import hunt.collection.List;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transaction.Declare;
import hunt.proton.amqp.transaction.GlobalTxId;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Object;
import hunt.logging;
import std.concurrency : initOnce;
import hunt.Exceptions;

class DeclareType : AbstractDescribedType!(Declare,List!GlobalTxId) , DescribedTypeConstructor!(Declare)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000031L), Symbol.valueOf("amqp:declare:list"),
    //};
    //
    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000031L);

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000031L), Symbol.valueOf("amqp:declare:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000031L));
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
    protected List!GlobalTxId wrap(Declare val)
    {
        GlobalTxId globalId = val.getGlobalId();
        return globalId is null ? null : Collections.singletonList!GlobalTxId(globalId);
    }

    public Declare newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        Declare o = new Declare();

        if(!l.isEmpty())
        {
            o.setGlobalId( cast(GlobalTxId) l.get( 0 ) );
        }

        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Declare);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        DeclareType type = new DeclareType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
  