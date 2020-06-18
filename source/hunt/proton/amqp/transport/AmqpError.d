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


module hunt.proton.amqp.transport.AmqpError;

import hunt.proton.amqp.Symbol;

import std.concurrency : initOnce;

interface AmqpError
{

    static Symbol INTERNAL_ERROR() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:internal-error"));
    }

    static Symbol NOT_FOUND() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:not-found"));
    }

    static Symbol UNAUTHORIZED_ACCESS() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:unauthorized-access"));
    }

    static Symbol DECODE_ERROR() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:decode-error"));
    }

    static Symbol RESOURCE_LIMIT_EXCEEDED() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:resource-limit-exceeded"));
    }

    static Symbol NOT_ALLOWED() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:not-allowed"));
    }

    static Symbol INVALID_FIELD() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:invalid-field"));
    }

    static Symbol NOT_IMPLEMENTED() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:not-implemented"));
    }

    static Symbol RESOURCE_LOCKED() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:resource-locked"));
    }

    static Symbol PRECONDITION_FAILED() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:precondition-failed"));
    }

    static Symbol RESOURCE_DELETED() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:resource-deleted"));
    }

    static Symbol ILLEGAL_STATE() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:illegal-state"));
    }

    static Symbol FRAME_SIZE_TOO_SMALL() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:frame-size-too-small"));
    }

    // static Symbol FRAME_SIZE_TOO_SMALL()
    // {
    //     __gshared Symbol inst;
    //     return initOnce!inst(Symbol.valueOf("amqp:frame-size-too-small"));
    // }

}
