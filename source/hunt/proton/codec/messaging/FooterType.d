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


module hunt.proton.codec.messaging.FooterType;

import hunt.Object;
import hunt.collection.Map;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Footer;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import std.concurrency : initOnce;
import hunt.Exceptions;
import hunt.String;

class FooterType : AbstractDescribedType!(Footer,Map!(String,Object)) , DescribedTypeConstructor!(Footer)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000078L), Symbol.valueOf("amqp:footer:map"),
    //};

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000078L), Symbol.valueOf("amqp:footer:map")]);
    }

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000078L);


    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000078L));
    }


    public this(EncoderImpl encoder)
    {
        super(encoder);
    }

    override
    public UnsignedLong getDescriptor()
    {
        return DESCRIPTOR;
    }

    override
    protected Map!(String,Object) wrap(Footer val)
    {
        return val.getValue();
    }

    public Footer newInstance(Object described)
    {
        return new Footer( cast(Map!(String,Object)) described );
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Footer);
    }
      

    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        FooterType type = new FooterType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
  