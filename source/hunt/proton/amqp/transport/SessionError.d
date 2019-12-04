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


module hunt.proton.amqp.transport.SessionError;

import hunt.proton.amqp.Symbol;

import std.concurrency : initOnce;

interface SessionError
{

    static Symbol WINDOW_VIOLATION() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:session:window-violation"));
    }

    static Symbol ERRANT_LINK() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:session:errant-link"));
    }

    static Symbol HANDLE_IN_USE() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:session:handle-in-use"));
    }

    static Symbol UNATTACHED_HANDLE() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:session:unattached-handle"));
    }

}
