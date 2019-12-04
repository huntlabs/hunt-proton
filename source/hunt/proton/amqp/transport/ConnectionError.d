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


module hunt.proton.amqp.transport.ConnectionError;

import hunt.proton.amqp.Symbol;


import std.concurrency : initOnce;

interface ConnectionError
{

    static Symbol CONNECTION_FORCED() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:connection:forced"));
    }

    static Symbol FRAMING_ERROR() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:connection:framing-error"));
    }

    static Symbol REDIRECT() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:connection:redirect"));
    }

}
