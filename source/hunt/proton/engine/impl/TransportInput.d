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

module hunt.proton.engine.impl.TransportInput;

import hunt.collection.ByteBuffer;

import hunt.proton.engine.TransportException;


interface TransportInput
{

    int capacity();

    int position();

    ByteBuffer tail() ;

    void process() ;

    void close_tail();

}
