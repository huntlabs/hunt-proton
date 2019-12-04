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

module hunt.proton.amqp.security.SaslFrameBody;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.security.SaslMechanisms;
import hunt.proton.amqp.security.SaslInit;
import hunt.proton.amqp.security.SaslOutcome;
import hunt.proton.amqp.security.SaslChallenge;
import hunt.proton.amqp.security.SaslResponse;

interface SaslFrameBodyHandler(E) : SaslFrameBody
{
    void handleMechanisms(SaslMechanisms saslMechanisms, Binary payload, E context);
    void handleInit(SaslInit saslInit, Binary payload, E context);
    void handleChallenge(SaslChallenge saslChallenge, Binary payload, E context);
    void handleResponse(SaslResponse saslResponse, Binary payload, E context);
    void handleOutcome(SaslOutcome saslOutcome, Binary payload, E context);
    void invoke(SaslFrameBodyHandler!E handler, Binary payload, E context);
}

interface SaslFrameBody
{


  //  void invoke(SaslFrameBodyHandler!E handler, Binary payload, E context);
}
