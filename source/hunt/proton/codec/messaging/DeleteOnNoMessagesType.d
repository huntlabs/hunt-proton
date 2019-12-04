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


module hunt.proton.codec.messaging.DeleteOnNoMessagesType;

import hunt.Object;
import hunt.collection.Collections;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.DeleteOnNoMessages;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import std.concurrency : initOnce;
import hunt.Exceptions;

class DeleteOnNoMessagesType : AbstractDescribedType!(DeleteOnNoMessages,List!Object) , DescribedTypeConstructor!(DeleteOnNoMessages)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x000000000000002dL), Symbol.valueOf("amqp:delete-on-no-messages:list"),
    //};

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x000000000000002dL);

    static Object[] DESCRIPTORS() {
        __gshared Object[] inst;
        return initOnce!inst([UnsignedLong.valueOf(0x000000000000002dL), Symbol.valueOf("amqp:delete-on-no-messages:list")]);
    }

    static UnsignedLong DESCRIPTOR() {
        __gshared UnsignedLong inst;
        return initOnce!inst(UnsignedLong.valueOf(0x000000000000002dL));
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
    protected List!Object wrap(DeleteOnNoMessages val)
    {
        return new ArrayList!Object();
    }

    override
    public DeleteOnNoMessages newInstance(Object described)
    {
        return DeleteOnNoMessages.getInstance();
    }

    override
    public TypeInfo getTypeClass()
    {
        return typeid(DeleteOnNoMessages);
    }

    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        DeleteOnNoMessagesType type = new DeleteOnNoMessagesType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
  