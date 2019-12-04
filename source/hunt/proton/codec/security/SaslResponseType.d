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


module hunt.proton.codec.security.SaslResponseType;

import hunt.collection.Collections;
import hunt.collection.List;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.security.SaslResponse;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Exceptions;
import hunt.Object;
import hunt.logging;
import std.concurrency : initOnce;

class SaslResponseType : AbstractDescribedType!(SaslResponse, List!Binary) , DescribedTypeConstructor!(SaslResponse)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000043L), Symbol.valueOf("amqp:sasl-response:list"),
    //};

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000043L);


    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000043L), Symbol.valueOf("amqp:sasl-response:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000043L));
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
    protected List!Binary wrap(SaslResponse val)
    {
        return Collections.singletonList!Binary(val.getResponse());
    }


    public SaslResponse newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        SaslResponse o = new SaslResponse();

        if(l.isEmpty())
        {
            logError("The response field cannot be omitted");
           // throw new DecodeException("The response field cannot be omitted");
        }

        switch(1 - l.size())
        {

            case 0:
                o.setResponse( cast(Binary) l.get( 0 ) );
                break;
            default:
                break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(SaslResponse);
    }



    static void register(Decoder decoder, EncoderImpl encoder)
    {
        SaslResponseType type = new SaslResponseType(encoder);
       // implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
