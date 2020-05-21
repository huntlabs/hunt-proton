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
module hunt.proton.engine.impl.TransportOutputWriter;

import hunt.io.ByteBuffer;

import hunt.proton.engine.TransportException;

interface TransportOutputWriter
{
    /**
     * Writes my pending output bytes into outputBuffer. Does not
     * subsequently flip it. Returns true on end of stream.
     */
    bool writeInto(ByteBuffer outputBuffer);

    void closed(TransportException error);

}
