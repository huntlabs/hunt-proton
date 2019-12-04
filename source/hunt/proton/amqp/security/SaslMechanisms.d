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


module hunt.proton.amqp.security.SaslMechanisms;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.security.SaslFrameBody;
import hunt.logging;

import hunt.collection.ArrayList;
import hunt.collection.List;

class SaslMechanisms : SaslFrameBody
{

    private List!Symbol _saslServerMechanisms;

    public List!Symbol getSaslServerMechanisms()
    {
        return _saslServerMechanisms;
    }

    public void setSaslServerMechanisms(List!Symbol saslServerMechanisms)
    {
        if( saslServerMechanisms is null )
        {
            logError("the sasl-server-mechanisms field is mandatory");
        }

        _saslServerMechanisms = saslServerMechanisms;
    }


    public void invoke(E)(SaslFrameBodyHandler!E handler, Binary payload, E context)
    {
        handler.handleMechanisms(this, payload, context);
    }

}
