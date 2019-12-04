module hunt.proton.engine.impl.EndpointImplQuery;
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


import hunt.collection.Set;
import hunt.proton.engine.EndpointState;
import hunt.proton.engine.impl.EndpointImpl;
import hunt.proton.engine.impl.LinkNode;

class EndpointImplQuery(T)   : Query!T
{
    private Set!EndpointState _local;
    private Set!EndpointState _remote;

    this(Set!EndpointState local, Set!EndpointState remote)
    {
        _local = local;
        _remote = remote;
    }

    public bool matches(LinkNode!T node)
    {
        return (_local is null || _local.contains(node.getValue().getLocalState()))
                && (_remote is null || _remote.contains(node.getValue().getRemoteState()));
    }
}
