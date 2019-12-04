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


module hunt.proton.amqp.messaging.Accepted;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.amqp.messaging.Outcome;


import std.concurrency : initOnce;

class Accepted : DeliveryState, Outcome
{
   // __gshared Symbol DESCRIPTOR_SYMBOL = Symbol.valueOf("amqp:accepted:list");

   // private static Accepted INSTANCE = new Accepted();


    static Symbol DESCRIPTOR_SYMBOL()
    {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:accepted:list"));
    }


    __gshared Accepted INSTANCE = null;

    /**
     *  TODO should this (and other DeliveryStates) have a private constructor??
     */
    this()
    {
    }


    public static Accepted getInstance()
    {
        if (INSTANCE is null)
            INSTANCE = new Accepted();
        return INSTANCE;
    }

    override
    public DeliveryStateType getType() {
        return DeliveryStateType.Accepted;
    }
}
