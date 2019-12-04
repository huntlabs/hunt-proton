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

module hunt.proton.codec.SmallFloatingSizePrimitiveTypeEncoding;

import hunt.proton.codec.FloatingSizePrimitiveTypeEncoding;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;

abstract class SmallFloatingSizePrimitiveTypeEncoding(T) : FloatingSizePrimitiveTypeEncoding!(T)
{

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        super(encoder, decoder);
    }

    override
    public int getSizeBytes()
    {
        return 1;
    }

    override
    protected void writeSize(T val)
    {
        getEncoder().writeRaw(cast(byte)getEncodedValueSize(val));
    }
}
