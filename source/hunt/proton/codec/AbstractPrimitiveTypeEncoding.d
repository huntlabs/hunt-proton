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

module hunt.proton.codec.AbstractPrimitiveTypeEncoding;

import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.TypeEncoding;
import hunt.logging;

abstract class AbstractPrimitiveTypeEncoding(T) : PrimitiveTypeEncoding!(T)
{
    private EncoderImpl _encoder;
    private DecoderImpl _decoder;

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _encoder = encoder;
        _decoder = decoder;
    }

    public void writeConstructor()
    {
        _encoder.writeRaw(getEncodingCode());
    }

    public int getConstructorSize()
    {
        return 1;
    }

    public abstract byte getEncodingCode();

    protected EncoderImpl getEncoder()
    {
        return _encoder;
    }

    public TypeInfo getTypeClass()
    {
        return getType().getTypeClass();
    }

    protected DecoderImpl getDecoder()
    {
        return _decoder;
    }


    public bool encodesJavaPrimitive()
    {
        return false;
    }

    override
    int opCmp(ITypeEncoding o)
    {
        return 1;
    }

}
