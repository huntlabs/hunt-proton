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


module hunt.proton.codec.security.SaslInitType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.security.SaslInit;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.String;
import hunt.Exceptions;
import hunt.Object;

import hunt.Exceptions;

import std.concurrency : initOnce;
import hunt.logging;
import std.conv : to;

class SaslInitWrapper : AbstractList!Object
{

    private SaslInit _saslInit;

    this(SaslInit saslInit)
    {
        _saslInit = saslInit;
    }

    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _saslInit.getMechanism();
            case 1:
            return _saslInit.getInitialResponse();
            case 2:
            return _saslInit.getHostname();
            default:
            return null;
        }

        //    throw new IllegalStateException("Unknown index " ~ to!string(index));

    }
    override
    public int size()
    {
        return _saslInit.getHostname() !is null
        ? 3
        : _saslInit.getInitialResponse() !is null
        ? 2
        : 1;

    }
}


class SaslInitType : AbstractDescribedType!(SaslInit,List!Object) , DescribedTypeConstructor!(SaslInit)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000041L), Symbol.valueOf("amqp:sasl-init:list"),
    //};

    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000041L);

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000041L));
    }

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000041L), Symbol.valueOf("amqp:sasl-init:list")]);
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
    protected List!Object wrap(SaslInit val)
    {
        return new SaslInitWrapper(val);
    }




    public SaslInit newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        SaslInit o = new SaslInit();

        if(l.size() <= 0)
        {
            logError("The mechanism field cannot be omitted");
           // throw new DecodeException("The mechanism field cannot be omitted");
        }

        switch(3 - l.size())
        {

            case 0:
                o.setHostname( cast(String) l.get( 2 ) );
                goto case;
            case 1:
                o.setInitialResponse( cast(Binary) l.get( 1 ) );
                goto case;
            case 2:
                o.setMechanism( cast(Symbol) l.get( 0 ) );
                break;
            default:
                break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        //return typeid(SaslInitWrapper);
        return typeid(SaslInit);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        SaslInitType type = new SaslInitType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
