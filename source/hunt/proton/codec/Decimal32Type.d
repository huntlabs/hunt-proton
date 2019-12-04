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

module hunt.proton.codec.Decimal32Type;

/*
import hunt.proton.amqp.Decimal32;

import hunt.collection.Collection;
import hunt.collection.Collections;

class Decimal32Type : AbstractPrimitiveType!(Decimal32)
{
    private Decimal32Encoding _decimal32Encoder;

    Decimal32Type(EncoderImpl encoder, DecoderImpl decoder)
    {
        _decimal32Encoder = new Decimal32Encoding(encoder, decoder);
        encoder.register(Decimal32.class, this);
        decoder.register(this);
    }

    public Class!(Decimal32) getTypeClass()
    {
        return Decimal32.class;
    }

    public Decimal32Encoding getEncoding(Decimal32 val)
    {
        return _decimal32Encoder;
    }


    public Decimal32Encoding getCanonicalEncoding()
    {
        return _decimal32Encoder;
    }

    public Collection!(Decimal32Encoding) getAllEncodings()
    {
        return Collections.singleton(_decimal32Encoder);
    }

    private class Decimal32Encoding : FixedSizePrimitiveTypeEncoding!(Decimal32)
    {

        public Decimal32Encoding(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected int getFixedSize()
        {
            return 4;
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.DECIMAL32;
        }

        public Decimal32Type getType()
        {
            return Decimal32Type.this;
        }

        public void writeValue(Decimal32 val)
        {
            getEncoder().writeRaw(val.getBits());
        }

        public bool encodesSuperset(TypeEncoding!(Decimal32) encoding)
        {
            return (getType() == encoding.getType());
        }

        public Decimal32 readValue()
        {
            return new Decimal32(getDecoder().readRawInt());
        }
    }
}
*/