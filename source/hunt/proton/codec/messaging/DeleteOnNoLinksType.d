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


module hunt.proton.codec.messaging.DeleteOnNoLinksType;

import hunt.Object;
import hunt.collection.Collections;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.DeleteOnNoLinks;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import std.concurrency : initOnce;
import hunt.Exceptions;

class DeleteOnNoLinksType : AbstractDescribedType!(DeleteOnNoLinks,List!Object) , DescribedTypeConstructor!(DeleteOnNoLinks)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x000000000000002cL), Symbol.valueOf("amqp:delete-on-no-links:list"),
    //};

    static Object[] DESCRIPTORS() {
        __gshared Object[] inst;
        return initOnce!inst([UnsignedLong.valueOf(0x000000000000002cL),Symbol.valueOf("amqp:delete-on-no-links:list")]);
    }

    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x000000000000002cL);


    static UnsignedLong DESCRIPTOR() {
        __gshared UnsignedLong inst;
        return initOnce!inst(UnsignedLong.valueOf(0x000000000000002cL));
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
    protected List!Object wrap(DeleteOnNoLinks val)
    {
        return  new ArrayList!Object();
    }

    override
    public DeleteOnNoLinks newInstance(Object described)
    {
        return DeleteOnNoLinks.getInstance();
    }

    override
    public TypeInfo getTypeClass()
    {
        return typeid(DeleteOnNoLinks);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        DeleteOnNoLinksType type = new DeleteOnNoLinksType(encoder);
       // implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
  