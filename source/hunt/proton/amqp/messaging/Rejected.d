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


module hunt.proton.amqp.messaging.Rejected;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.amqp.messaging.Outcome;

import std.concurrency : initOnce;

class Rejected : DeliveryState, Outcome
{
    //public static Symbol DESCRIPTOR_SYMBOL = Symbol.valueOf("amqp:rejected:list");


    static Symbol DESCRIPTOR_SYMBOL()
    {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:rejected:list"));
    }


    private ErrorCondition _error;

    public ErrorCondition getError()
    {
        return _error;
    }

    public void setError(ErrorCondition error)
    {
        _error = error;
    }

    public int size()
    {
        return _error !is null
                  ? 1
                  : 0;
    }


    override
    public DeliveryStateType getType() {
        return DeliveryStateType.Rejected;
    }
}
