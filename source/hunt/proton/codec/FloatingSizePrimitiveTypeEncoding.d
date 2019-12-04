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

module hunt.proton.codec.FloatingSizePrimitiveTypeEncoding;

import hunt.proton.codec.AbstractPrimitiveTypeEncoding;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;

abstract class FloatingSizePrimitiveTypeEncoding(T) : AbstractPrimitiveTypeEncoding!(T)
{

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        super(encoder, decoder);
    }

    public bool isFixedSizeVal()
    {
        return false;
    }

    abstract int getSizeBytes();

    public void writeValue(Object val)
    {
        writeSize(cast(T)val);
        writeEncodedValue(cast(T)val);
    }

    protected abstract void writeEncodedValue(T val);

    protected abstract void writeSize(T val);

    public int getValueSize(Object val)
    {
        return getSizeBytes() + getEncodedValueSize(cast(T)val);
    }

    protected abstract int getEncodedValueSize(T val);
}
