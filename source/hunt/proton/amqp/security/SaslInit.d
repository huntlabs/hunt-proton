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


module hunt.proton.amqp.security.SaslInit;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.security.SaslFrameBody;
import hunt.logging;
import hunt.String;


class SaslInit : SaslFrameBody
{

    private Symbol _mechanism;
    private Binary _initialResponse;
    private String _hostname;

    public Symbol getMechanism()
    {
        return _mechanism;
    }

    public void setMechanism(Symbol mechanism)
    {
        if( mechanism is null )
        {
            logError("the mechanism field is mandatory");
        }

        _mechanism = mechanism;
    }

    public Binary getInitialResponse()
    {
        return _initialResponse;
    }

    public void setInitialResponse(Binary initialResponse)
    {
        _initialResponse = initialResponse;
    }

    public String getHostname()
    {
        return _hostname;
    }

    public void setHostname(String hostname)
    {
        _hostname = hostname;
    }


    public void invoke(E)(SaslFrameBodyHandler!E handler, Binary payload, E context)
    {
        handler.handleInit(this, payload, context);
    }

}
