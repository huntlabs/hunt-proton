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

module hunt.proton.codec.Decimal64Type;

/*
import hunt.proton.amqp.Decimal64;

import hunt.collection.Collection;
import hunt.collection.Collections;

class Decimal64Type : AbstractPrimitiveType!(Decimal64)
{
    private Decimal64Encoding _decimal64Encoder;

    Decimal64Type(EncoderImpl encoder, DecoderImpl decoder)
    {
        _decimal64Encoder = new Decimal64Encoding(encoder, decoder);
        encoder.register(Decimal64.class, this);
        decoder.register(this);
    }

    public Class!(Decimal64) getTypeClass()
    {
        return Decimal64.class;
    }

    public Decimal64Encoding getEncoding(Decimal64 val)
    {
        return _decimal64Encoder;
    }


    public Decimal64Encoding getCanonicalEncoding()
    {
        return _decimal64Encoder;
    }

    public Collection!(Decimal64Encoding) getAllEncodings()
    {
        return Collections.singleton(_decimal64Encoder);
    }

    private class Decimal64Encoding : FixedSizePrimitiveTypeEncoding!(Decimal64)
    {

        public Decimal64Encoding(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected int getFixedSize()
        {
            return 8;
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.DECIMAL64;
        }

        public Decimal64Type getType()
        {
            return Decimal64Type.this;
        }

        public void writeValue(Decimal64 val)
        {
            getEncoder().writeRaw(val.getBits());
        }

        public bool encodesSuperset(TypeEncoding!(Decimal64) encoding)
        {
            return (getType() == encoding.getType());
        }

        public Decimal64 readValue()
        {
            return new Decimal64(getDecoder().readRawLong());
        }
    }
}
*/