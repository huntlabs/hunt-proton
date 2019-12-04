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


module hunt.proton.amqp.transaction.TransactionErrors;

import hunt.proton.amqp.Symbol;
import std.concurrency : initOnce;

interface TransactionErrors
{

    static Symbol UNKNOWN_ID() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:transaction:unknown-id"));
    }


    static Symbol TRANSACTION_ROLLBACK() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:transaction:rollback"));
    }


    static Symbol TRANSACTION_TIMEOUT() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:transaction:timeout"));
    }

}
