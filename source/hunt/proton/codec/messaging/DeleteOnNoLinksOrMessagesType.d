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


module hunt.proton.codec.messaging.DeleteOnNoLinksOrMessagesType;

import hunt.Object;
import hunt.collection.Collections;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.DeleteOnNoLinksOrMessages;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Exceptions;
import std.concurrency : initOnce;

class DeleteOnNoLinksOrMessagesType : AbstractDescribedType!(DeleteOnNoLinksOrMessages,List!Object) , DescribedTypeConstructor!(DeleteOnNoLinksOrMessages)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x000000000000002eL), Symbol.valueOf("amqp:delete-on-no-links-or-messages:list"),
    //};

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x000000000000002eL);


    static UnsignedLong DESCRIPTOR() {
        __gshared UnsignedLong inst;
        return initOnce!inst(UnsignedLong.valueOf(0x000000000000002eL));
    }

    static Object[] DESCRIPTORS() {
        __gshared Object[] inst;
        return initOnce!inst([UnsignedLong.valueOf(0x000000000000002eL), Symbol.valueOf("amqp:delete-on-no-links-or-messages:list")]);
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
    protected List!Object wrap(DeleteOnNoLinksOrMessages val)
    {
        return new ArrayList!Object();
    }

    public DeleteOnNoLinksOrMessages newInstance(Object described)
    {
        return DeleteOnNoLinksOrMessages.getInstance();
    }

    public TypeInfo getTypeClass()
    {
        return typeid(DeleteOnNoLinksOrMessages);
    }


    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        DeleteOnNoLinksOrMessagesType type = new DeleteOnNoLinksOrMessagesType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
  