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

module hunt.proton.codec.UnsignedShortType;

import hunt.proton.amqp.UnsignedShort;

import hunt.collection.Collection;
import hunt.collection.Collections;

import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.PrimitiveTypeEncoding;

class UnsignedShortType : AbstractPrimitiveType!(UnsignedShort)
{
    private UnsignedShortEncoding _unsignedShortEncoder;

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _unsignedShortEncoder = new UnsignedShortEncoding(encoder, decoder);
        encoder.register(typeid(UnsignedShort), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(UnsignedShort);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        return _unsignedShortEncoder;
    }

    public void fastWrite(EncoderImpl encoder, UnsignedShort value)
    {
        encoder.writeRaw(EncodingCodes.USHORT);
        encoder.writeRaw(value.shortValue());
    }

    public UnsignedShortEncoding getCanonicalEncoding()
    {
        return _unsignedShortEncoder;
    }

    public Collection!(TypeEncoding!(UnsignedShort))  getAllEncodings()
    {
        return Collections.singleton!(TypeEncoding!(UnsignedShort)) (_unsignedShortEncoder);
    }

    //Collection!(PrimitiveTypeEncoding!(UnsignedShort)) getAllEncodings()
    //{
    //    return super.getAllEncodings();
    //}


    class UnsignedShortEncoding : FixedSizePrimitiveTypeEncoding!(UnsignedShort)
    {

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected int getFixedSize()
        {
            return 2;
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.USHORT;
        }

        public UnsignedShortType getType()
        {
            return this.outer;
           // return UnsignedShortType.this;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw((cast(UnsignedShort)val).shortValue());
        }

        public bool encodesSuperset(TypeEncoding!(UnsignedShort) encoding)
        {
            return (getType() == encoding.getType());
        }

        public UnsignedShort readValue()
        {
            return UnsignedShort.valueOf(getDecoder().readRawShort());
        }
    }
}
