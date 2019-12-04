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

module hunt.proton.codec.Decimal128Type;

/*
import hunt.proton.amqp.Decimal128;

import hunt.collection.Collection;
import hunt.collection.Collections;

class Decimal128Type : AbstractPrimitiveType!(Decimal128)
{
    private Decimal128Encoding _decimal128Encoder;

    Decimal128Type(EncoderImpl encoder, DecoderImpl decoder)
    {
        _decimal128Encoder = new Decimal128Encoding(encoder, decoder);
        encoder.register(Decimal128.class, this);
        decoder.register(this);
    }

    public Class!(Decimal128) getTypeClass()
    {
        return Decimal128.class;
    }

    public Decimal128Encoding getEncoding(Decimal128 val)
    {
        return _decimal128Encoder;
    }


    public Decimal128Encoding getCanonicalEncoding()
    {
        return _decimal128Encoder;
    }

    public Collection!(Decimal128Encoding) getAllEncodings()
    {
        return Collections.singleton(_decimal128Encoder);
    }

    private class Decimal128Encoding : FixedSizePrimitiveTypeEncoding!(Decimal128)
    {

        public Decimal128Encoding(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected int getFixedSize()
        {
            return 16;
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.DECIMAL128;
        }

        public Decimal128Type getType()
        {
            return Decimal128Type.this;
        }

        public void writeValue(Decimal128 val)
        {
            getEncoder().writeRaw(val.getMostSignificantBits());
            getEncoder().writeRaw(val.getLeastSignificantBits());
        }

        public bool encodesSuperset(TypeEncoding!(Decimal128) encoding)
        {
            return (getType() == encoding.getType());
        }

        public Decimal128 readValue()
        {
            long msb = getDecoder().readRawLong();
            long lsb = getDecoder().readRawLong();
            return new Decimal128(msb, lsb);
        }
    }
}
*/