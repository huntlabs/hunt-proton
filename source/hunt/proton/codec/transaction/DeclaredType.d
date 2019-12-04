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


module hunt.proton.codec.transaction.DeclaredType;

import hunt.collection.Collections;
import hunt.collection.List;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transaction.Declared;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Object;
import hunt.logging;

import std.concurrency : initOnce;
import hunt.Exceptions;

class DeclaredType : AbstractDescribedType!(Declared,List!Binary) , DescribedTypeConstructor!(Declared)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000033L), Symbol.valueOf("amqp:declared:list"),
    //};
    //
    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000033L);

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000033L), Symbol.valueOf("amqp:declared:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000033L));
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
    protected List!Binary wrap(Declared val)
    {
        return Collections.singletonList!Binary(val.getTxnId());
    }

    public Declared newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        Declared o = new Declared();

        if(l.isEmpty())
        {
            logError("The txn-id field cannot be omitted");
          //  throw new DecodeException("The txn-id field cannot be omitted");
        }

        o.setTxnId( cast(Binary) l.get( 0 ) );



        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Declared);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        DeclaredType type = new DeclaredType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
  