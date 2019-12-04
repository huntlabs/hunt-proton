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

module hunt.proton.codec.UnsignedByteType;


import hunt.proton.amqp.UnsignedByte;

import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;

import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.proton.codec.PrimitiveTypeEncoding;

class UnsignedByteType : AbstractPrimitiveType!(UnsignedByte)
{
    private UnsignedByteEncoding _unsignedByteEncoding;

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _unsignedByteEncoding = new UnsignedByteEncoding(encoder, decoder);
        encoder.register(typeid(UnsignedByte), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(UnsignedByte);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        return _unsignedByteEncoding;
    }

    public void fastWrite(EncoderImpl encoder, UnsignedByte value)
    {
        encoder.writeRaw(EncodingCodes.UBYTE);
        encoder.writeRaw(value.byteValue());
    }

    public UnsignedByteEncoding getCanonicalEncoding()
    {
        return _unsignedByteEncoding;
    }

    public Collection!(TypeEncoding!(UnsignedByte)) getAllEncodings()
    {
        return Collections.singleton!(TypeEncoding!(UnsignedByte))(_unsignedByteEncoding);
    }

    //public  Collection!(PrimitiveTypeEncoding!(UnsignedByte)) getAllEncodings()
    //{
    //    return super.getAllEncodings();
    //}


    class UnsignedByteEncoding : FixedSizePrimitiveTypeEncoding!(UnsignedByte)
    {

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected int getFixedSize()
        {
            return 1;
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.UBYTE;
        }

        public UnsignedByteType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw((cast(UnsignedByte)val).byteValue());
        }

        public bool encodesSuperset(TypeEncoding!(UnsignedByte) encoding)
        {
            return (getType() == encoding.getType());
        }

        public UnsignedByte readValue()
        {
            return UnsignedByte.valueOf(getDecoder().readRawByte());
        }
    }
}
