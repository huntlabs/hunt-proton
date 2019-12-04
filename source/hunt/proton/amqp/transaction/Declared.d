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


module hunt.proton.amqp.transaction.Declared;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.messaging.Outcome;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.logging;

import std.concurrency : initOnce;

class Declared : DeliveryState, Outcome
{
  //  public static Symbol DESCRIPTOR_SYMBOL = Symbol.valueOf("amqp:declared:list");


    static Symbol DESCRIPTOR_SYMBOL()
    {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:declared:list"));
    }



    private Binary _txnId;

    public Binary getTxnId()
    {
        return _txnId;
    }

    public void setTxnId(Binary txnId)
    {
        if( txnId is null )
        {
            logError("the txn-id field is mandatory");
        }

        _txnId = txnId;
    }


    override
    public DeliveryStateType getType() {
        return DeliveryStateType.Declared;
    }
}
