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


module hunt.proton.codec.transaction.TransactionalStateType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Outcome;
import hunt.proton.amqp.transaction.TransactionalState;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Object;
import hunt.logging;
import hunt.Exceptions;
import std.conv : to;

import std.concurrency : initOnce;


class TransactionalStateWrapper : AbstractList!Object
{

    private TransactionalState _transactionalState;

    this(TransactionalState transactionalState)
    {
        _transactionalState = transactionalState;
    }

    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _transactionalState.getTxnId();
            case 1:
            return cast(Object)(_transactionalState.getOutcome());
            default:
            return null;

        }


        //  throw new IllegalStateException("Unknown index " ~ to!string(index));

    }

    override
    public int size()
    {
        return _transactionalState.getOutcome() !is null
        ? 2
        : 1;

    }


}

class TransactionalStateType : AbstractDescribedType!(TransactionalState,IObject) , DescribedTypeConstructor!(TransactionalState)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000034L), Symbol.valueOf("amqp:transactional-state:list"),
    //};
    //
    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000034L);

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000034L), Symbol.valueOf("amqp:transactional-state:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000034L));
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
    protected List!Object wrap(TransactionalState val)
    {
        return new TransactionalStateWrapper(val);
    }



    public TransactionalState newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        TransactionalState o = new TransactionalState();

        if(l.isEmpty())
        {
            logError("The txn-id field cannot be omitted");
            //throw new DecodeException("The txn-id field cannot be omitted");
        }

        switch(2 - l.size())
        {

            case 0:
                o.setOutcome( cast(Outcome) l.get( 1 ) );
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
        return typeid(TransactionalState);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        TransactionalStateType type = new TransactionalStateType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
  