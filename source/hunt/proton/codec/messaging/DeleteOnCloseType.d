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


module hunt.proton.codec.messaging.DeleteOnCloseType;

import hunt.Object;
import hunt.collection.Collections;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.DeleteOnClose;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Exceptions;
import std.concurrency : initOnce;

class DeleteOnCloseType : AbstractDescribedType!(DeleteOnClose,List!Object) , DescribedTypeConstructor!(DeleteOnClose)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x000000000000002bL), Symbol.valueOf("amqp:delete-on-close:list"),
    //};

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x000000000000002bL);


    static UnsignedLong DESCRIPTOR() {
        __gshared UnsignedLong inst;
        return initOnce!inst(UnsignedLong.valueOf(0x000000000000002bL));
    }

    static Object[] DESCRIPTORS() {
        __gshared Object[] inst;
        return initOnce!inst([UnsignedLong.valueOf(0x000000000000002bL), Symbol.valueOf("amqp:delete-on-close:list")]);
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
    protected List!Object wrap(DeleteOnClose val)
    {
        return new ArrayList!Object();
    }

    public DeleteOnClose newInstance(Object described)
    {
        return DeleteOnClose.getInstance();
    }

    public TypeInfo getTypeClass()
    {
        return typeid(DeleteOnClose);
    }


    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        DeleteOnCloseType type = new DeleteOnCloseType(encoder);
       // implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
  