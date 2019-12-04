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


module hunt.proton.codec.security.SaslOutcomeType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedByte;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.security.SaslCode;
import hunt.proton.amqp.security.SaslOutcome;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Exceptions;
import hunt.Object;
import std.concurrency : initOnce;
import std.conv:to;
import hunt.logging;

class SaslOutcomeWrapper : AbstractList!Object
{
    private SaslOutcome _impl;

    this(SaslOutcome impl)
    {
        _impl = impl;
    }


    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _impl.getCode().getValue();
            case 1:
            return _impl.getAdditionalData();
            default:
            return null;
        }

        //   throw new IllegalStateException("Unknown index " ~ to!string(index));

    }

    override
    public int size()
    {
        return _impl.getAdditionalData() !is null
        ? 2
        : 1;
    }
}

class SaslOutcomeType  : AbstractDescribedType!(SaslOutcome,List!Object) , DescribedTypeConstructor!(SaslOutcome)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000044L), Symbol.valueOf("amqp:sasl-outcome:list"),
    //};

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000044L), Symbol.valueOf("amqp:sasl-outcome:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000044L));
    }

    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000044L);

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
    protected List!Object wrap(SaslOutcome val)
    {
        return new SaslOutcomeWrapper(val);
    }




    public SaslOutcome newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        SaslOutcome o = new SaslOutcome();

        if(l.isEmpty())
        {
            logError("The code field cannot be omitted");
          //  throw new DecodeException("The code field cannot be omitted");
        }

        switch(2 - l.size())
        {

            case 0:
                o.setAdditionalData( cast(Binary) l.get( 1 ) );
                goto case;
            case 1:
                o.setCode(SaslCode.valueOf(cast(UnsignedByte) l.get(0)));
                break;
            default:
                break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(SaslOutcome);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        SaslOutcomeType type = new SaslOutcomeType(encoder);
       // implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
