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


module hunt.proton.codec.transport.EndType;

import hunt.collection.Collections;
import hunt.collection.List;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.End;
import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import std.concurrency : initOnce;
import hunt.collection.ArrayList;

class EndType : AbstractDescribedType!(End,List!Object) , DescribedTypeConstructor!(End)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000017L), Symbol.valueOf("amqp:end:list"),
    //};
    //
    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000017L);



   static Object[]  DESCRIPTORS() {
       __gshared Object[]  inst;
       return initOnce!inst([UnsignedLong.valueOf(0x0000000000000017L), Symbol.valueOf("amqp:end:list")]);
   }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000017L));
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
    protected List!Object wrap(End val)
    {
        ErrorCondition errorCondition = val.getError();
        if (errorCondition !is null)
        {
            List!Object rt =  new ArrayList!Object;
            rt.add(errorCondition);
            return rt;
        }
        return null;
        //return errorCondition is null ? null : Collections.singletonList(errorCondition);
    }


    public End newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        End o = new End();

        if(l !is null && !l.isEmpty())
        {
            o.setError( cast(ErrorCondition) l.get( 0 ) );
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(End);
    }


    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        EndType type = new EndType(encoder);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }

}
