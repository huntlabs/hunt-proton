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


module hunt.proton.amqp.security.SaslOutcome;



import hunt.proton.amqp.Binary;
import hunt.proton.amqp.security.SaslFrameBody;
import hunt.proton.amqp.security.SaslCode;
import hunt.logging;

class SaslOutcome : SaslFrameBody
{

    private SaslCode _code;
    private Binary _additionalData;

    public SaslCode getCode()
    {
        return _code;
    }

    public void setCode(SaslCode code)
    {
        if( code is null )
        {
            logError("the code field is mandatory");
        }

        _code = code;
    }

    public Binary getAdditionalData()
    {
        return _additionalData;
    }

    public void setAdditionalData(Binary additionalData)
    {
        _additionalData = additionalData;
    }


    public void invoke(E)(SaslFrameBodyHandler!E handler, Binary payload, E context)
    {
        handler.handleOutcome(this, payload, context);
    }



}
