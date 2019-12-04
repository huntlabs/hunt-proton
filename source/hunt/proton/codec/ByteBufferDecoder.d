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

module hunt.proton.codec.ByteBufferDecoder;

import hunt.proton.codec.Decoder;
import hunt.collection.ByteBuffer;


interface ByteBufferDecoder : Decoder
{
    public void setByteBuffer(ByteBuffer buffer);

    public int getByteBufferRemaining();
}
