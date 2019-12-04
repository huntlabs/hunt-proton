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


module hunt.proton.amqp.transport.LinkError;

import hunt.proton.amqp.Symbol;

import std.concurrency : initOnce;

interface LinkError
{

    static Symbol DETACH_FORCED() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:link:detach-forced"));
    }

    static Symbol TRANSFER_LIMIT_EXCEEDED() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:link:transfer-limit-exceeded"));
    }

    static Symbol MESSAGE_SIZE_EXCEEDED() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:link:message-size-exceeded"));
    }

    static Symbol REDIRECT() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:link:redirect"));
    }

    static Symbol STOLEN() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:link:stolen"));
    }
}
