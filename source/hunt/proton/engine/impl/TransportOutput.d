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

module hunt.proton.engine.impl.TransportOutput;

import hunt.collection.ByteBuffer;

import hunt.proton.engine.Transport;

interface TransportOutput
{

    int pending();

    ByteBuffer head();

    void pop(int bytes);

    void close_head();

}
