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

module hunt.proton.codec.ByteBufferEncoder;

import hunt.collection.ByteBuffer;
import hunt.proton.codec.Encoder;

interface ByteBufferEncoder : Encoder
{
    public void setByteBuffer(ByteBuffer buf);
}
