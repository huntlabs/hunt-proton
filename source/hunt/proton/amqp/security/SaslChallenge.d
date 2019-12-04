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


module hunt.proton.amqp.security.SaslChallenge;


import hunt.proton.amqp.Binary;
import hunt.proton.amqp.security.SaslFrameBody;
import hunt.logging;

class SaslChallenge : SaslFrameBody
{
    private Binary _challenge;

    public Binary getChallenge()
    {
        return _challenge;
    }

    public void setChallenge(Binary challenge)
    {
        if( challenge is null )
        {
            logError("the challenge field is mandatory");
        }

        _challenge = challenge;
    }

    public Object get(int index)
    {

        switch(index)
        {
            case 0:
                return _challenge;
            default:
                return null;
        }
    }

    public int size()
    {
        return 1;

    }

    public void invoke(E)(SaslFrameBodyHandler!E handler, Binary payload, E context)
    {
        handler.handleChallenge(this, payload, context);
    }

}
