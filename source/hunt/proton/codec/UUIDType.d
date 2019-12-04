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

module hunt.proton.codec.UUIDType;

/*
import hunt.collection.Collection;
import hunt.collection.Collections;
import java.util.UUID;

class UUIDType : AbstractPrimitiveType!(UUID)
{
    private UUIDEncoding _uuidEncoding;

    UUIDType(EncoderImpl encoder, DecoderImpl decoder)
    {
        _uuidEncoding = new UUIDEncoding(encoder, decoder);
        encoder.register(UUID.class, this);
        decoder.register(this);
    }

    public Class!(UUID) getTypeClass()
    {
        return UUID.class;
    }

    public UUIDEncoding getEncoding(UUID val)
    {
        return _uuidEncoding;
    }

    public void fastWrite(EncoderImpl encoder, UUID value)
    {
        encoder.writeRaw(EncodingCodes.UUID);
        encoder.writeRaw(value.getMostSignificantBits());
        encoder.writeRaw(value.getLeastSignificantBits());
    }

    public UUIDEncoding getCanonicalEncoding()
    {
        return _uuidEncoding;
    }

    public Collection!(UUIDEncoding) getAllEncodings()
    {
        return Collections.singleton(_uuidEncoding);
    }

    private class UUIDEncoding : FixedSizePrimitiveTypeEncoding!(UUID)
    {

        public UUIDEncoding(EncoderImpl encoder, DecoderImpl decoder)
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
            return EncodingCodes.UUID;
        }

        public UUIDType getType()
        {
            return UUIDType.this;
        }

        public void writeValue(UUID val)
        {
            getEncoder().writeRaw(val.getMostSignificantBits());
            getEncoder().writeRaw(val.getLeastSignificantBits());
        }

        public bool encodesSuperset(TypeEncoding!(UUID) encoding)
        {
            return (getType() == encoding.getType());
        }

        public UUID readValue()
        {
            long msb = getDecoder().readRawLong();
            long lsb = getDecoder().readRawLong();

            return new UUID(msb, lsb);
        }
    }
}
*/