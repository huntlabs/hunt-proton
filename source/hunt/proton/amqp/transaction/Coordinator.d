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


module hunt.proton.amqp.transaction.Coordinator;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.transport.Target;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.String;

class Coordinator : Target
{
    private List!Symbol _capabilities;

    public List!Symbol getCapabilities()
    {
        return _capabilities;
    }

    public void setCapabilities(List!Symbol capabilities)
    {
        _capabilities = capabilities;
    }


    public String getAddress()
    {
        return null;
    }

    override
    public Target copy() {
        return null;
    }

    override string toString()
    {
        return "";
    }
}

