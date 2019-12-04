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
module hunt.proton.engine.impl.SaslFrameHandler;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.security.SaslFrameBody;

/**
 * Used by {@link SaslFrameParser} to handle the frames it parses
 */
interface SaslFrameHandler
{
    void handle(SaslFrameBody frameBody, Binary payload);

    bool isDone();
}
