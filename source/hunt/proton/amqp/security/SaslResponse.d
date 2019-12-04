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


module hunt.proton.amqp.security.SaslResponse;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.security.SaslFrameBody;
import hunt.logging;

class SaslResponse : SaslFrameBody
{

    private Binary _response;

    public Binary getResponse()
    {
        return _response;
    }

    public void setResponse(Binary response)
    {
        if( response is null )
        {
            logError("the response field is mandatory");
        }

        _response = response;
    }


    public void invoke(E)(SaslFrameBodyHandler!E handler, Binary payload, E context)
    {
        handler.handleResponse(this, payload, context);
    }


    }
