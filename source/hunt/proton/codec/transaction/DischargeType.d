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


module hunt.proton.codec.transaction.DischargeType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transaction.Discharge;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Object;
import hunt.logging;
import hunt.Boolean;
import hunt.Exceptions;
import std.concurrency : initOnce;
import std.conv : to;

class DischargeWrapper : AbstractList!Object
{

    private Discharge _discharge;

    this(Discharge discharge)
    {
        _discharge = discharge;
    }

    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _discharge.getTxnId();
            case 1:
            return _discharge.getFail();
            default:
            return null;
        }

        //            throw new IllegalStateException("Unknown index " ~ to!string(index));

    }

    override
    public int size()
    {
        return _discharge.getFail() !is null
        ? 2
        : 1;

    }

}

class DischargeType : AbstractDescribedType!(Discharge,IObject) , DescribedTypeConstructor!(Discharge)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000032L), Symbol.valueOf("amqp:discharge:list"),
    //};
    //
    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000032L);

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000032L), Symbol.valueOf("amqp:discharge:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000032L));
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
    protected List!Object wrap(Discharge val)
    {
        return new DischargeWrapper(val);
    }




    public Discharge newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        Discharge o = new Discharge();

        if(l.isEmpty())
        {
            logError("The txn-id field cannot be omitted");
            //throw new DecodeException("The txn-id field cannot be omitted");
        }

        switch(2 - l.size())
        {

            case 0:
                o.setFail( cast(Boolean) l.get( 1 ) );
                goto case;
            case 1:
                o.setTxnId( cast(Binary) l.get( 0 ) );
                break;
            default:
                break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Discharge);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        DischargeType type = new DischargeType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
  