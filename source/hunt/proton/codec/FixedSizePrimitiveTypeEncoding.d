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

module hunt.proton.codec.FixedSizePrimitiveTypeEncoding;

import hunt.proton.codec.AbstractPrimitiveTypeEncoding;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;

abstract class FixedSizePrimitiveTypeEncoding(T) : AbstractPrimitiveTypeEncoding!(T)
{

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        super(encoder, decoder);
    }

    public bool isFixedSizeVal()
    {
        return true;
    }

    public int getValueSize(Object val)
    {
        return getFixedSize();
    }

    public void skipValue()
    {
        getDecoder().getBuffer().position(getDecoder().getBuffer().position() + getFixedSize());
    }

    protected abstract int getFixedSize();
}
