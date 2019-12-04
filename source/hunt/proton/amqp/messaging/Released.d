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


module hunt.proton.amqp.messaging.Released;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.amqp.messaging.Outcome;

import std.concurrency : initOnce;

class Released : DeliveryState, Outcome
{
   // public static Symbol DESCRIPTOR_SYMBOL = Symbol.valueOf("amqp:released:list");


    static Symbol DESCRIPTOR_SYMBOL()
    {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:released:list"));
    }


    __gshared Released INSTANCE = null;

    public static Released getInstance()
    {
        if (INSTANCE is null)
        {
            INSTANCE = new Released;
        }
        return INSTANCE;
    }

    override
    public DeliveryStateType getType() {
        return DeliveryStateType.Released;
    }
}
