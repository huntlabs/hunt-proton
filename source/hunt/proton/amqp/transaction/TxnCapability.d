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


module hunt.proton.amqp.transaction.TxnCapability;

import hunt.proton.amqp.Symbol;
import std.concurrency : initOnce;

interface TxnCapability
{
    static Symbol LOCAL_TXN() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:local-transactions"));
    }


    static Symbol DISTRIBUTED_TXN() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:distributed-transactions"));
    }

    static Symbol PROMOTABLE_TXN() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:promotable-transactions"));
    }


    static Symbol MULTI_TXNS_PER_SSN() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:multi-txns-per-ssn"));
    }

    static Symbol MULTI_SSNS_PER_TXN() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:multi-ssns-per-txn"));
    }

}
