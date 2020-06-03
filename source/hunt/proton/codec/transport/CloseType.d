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


module hunt.proton.codec.transport.CloseType;

import hunt.collection.Collections;
import hunt.collection.List;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.Close;
import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.logging;
import hunt.collection.ArrayList;
import hunt.collection.Collections;
import std.concurrency : initOnce;

class CloseType : AbstractDescribedType!(Close,List!Object) , DescribedTypeConstructor!(Close)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000018L), Symbol.valueOf("amqp:close:list"),
    //};
    //
    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000018L);


          static Object[]  DESCRIPTORS() {
              __gshared Object[]  inst;
              return initOnce!inst([UnsignedLong.valueOf(0x0000000000000018L), Symbol.valueOf("amqp:close:list")]);
          }

         static UnsignedLong  DESCRIPTOR() {
             __gshared UnsignedLong  inst;
             return initOnce!inst(UnsignedLong.valueOf(0x0000000000000018L));
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
    protected List!Object wrap(Close val)
    {
        ErrorCondition errorCondition = val.getError();
        if (errorCondition is null) {
            return Collections.emptyList!Object();
        } else {
            List!Object rt =  new ArrayList!Object;
            rt.add(errorCondition);
            return rt;
        }
    }

    public Close newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        Close o = new Close();

        if(!l.isEmpty())
        {
            o.setError( cast(ErrorCondition) l.get( 0 ) );
        }

        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Close);
    }

    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        CloseType type = new CloseType(encoder);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }

}
  