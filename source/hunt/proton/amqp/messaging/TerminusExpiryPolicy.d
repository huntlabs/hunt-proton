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


module hunt.proton.amqp.messaging.TerminusExpiryPolicy;

import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.collection.HashMap;
import hunt.proton.amqp.Symbol;
import hunt.logging;

class TerminusExpiryPolicy
{
    __gshared TerminusExpiryPolicy LINK_DETACH ;
    __gshared TerminusExpiryPolicy SESSION_END ;
    __gshared TerminusExpiryPolicy CONNECTION_CLOSE ;
    __gshared TerminusExpiryPolicy NEVER ;

    private Symbol _policy;
    __gshared HashMap!(Symbol, TerminusExpiryPolicy) _map ;

    this(string policy)
    {
        _policy = Symbol.valueOf(policy);
    }

    public Symbol getPolicy()
    {
        return _policy;
    }

    shared static  this()
    {
        LINK_DETACH = new TerminusExpiryPolicy("link-detach");
        SESSION_END = new TerminusExpiryPolicy("session-end");
        CONNECTION_CLOSE = new TerminusExpiryPolicy("connection-close");
        NEVER = new TerminusExpiryPolicy("never");
        _map = new HashMap!(Symbol, TerminusExpiryPolicy)();
        _map.put(LINK_DETACH.getPolicy(), LINK_DETACH);
        _map.put(SESSION_END.getPolicy(), SESSION_END);
        _map.put(CONNECTION_CLOSE.getPolicy(), CONNECTION_CLOSE);
        _map.put(NEVER.getPolicy(), NEVER);
    }

    public static TerminusExpiryPolicy valueOf(Symbol policy)
    {
        TerminusExpiryPolicy expiryPolicy = _map.get(policy);
        if(expiryPolicy is null)
        {
            //throw new IllegalArgumentException("Unknown TerminusExpiryPolicy: " ~ policy);
            logError("Unknown TerminusExpiryPolicy");
        }
        return expiryPolicy;
    }
}
