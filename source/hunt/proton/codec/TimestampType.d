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

module hunt.proton.codec.TimestampType;

import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.time.LocalDateTime;

import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.logging;

alias Date = LocalDateTime;

class TimestampType : AbstractPrimitiveType!(Date)
{
    private TimestampEncoding _timestampEncoding;

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _timestampEncoding = new TimestampEncoding(encoder, decoder);
        encoder.register(typeid(Date), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Date);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        return _timestampEncoding;
    }

    public void fastWrite(EncoderImpl encoder, long timestamp)
    {
        encoder.writeRaw(EncodingCodes.TIMESTAMP);
        encoder.writeRaw(timestamp);
    }

    public TimestampEncoding getCanonicalEncoding()
    {
        return _timestampEncoding;
    }

    public Collection!(TypeEncoding!(LocalDateTime)) getAllEncodings()
    {
        return Collections.singleton!(TypeEncoding!(LocalDateTime))(_timestampEncoding);
    }

    //public Collection!(PrimitiveTypeEncoding!(LocalDateTime)) getAllEncodings()
    //{
    //    return super.getAllEncodings();
    //}

    public void write(long l)
    {
        _timestampEncoding.write(l);
    }

    class TimestampEncoding : FixedSizePrimitiveTypeEncoding!(Date)
    {

        this(EncoderImpl encoder, DecoderImpl decoder)
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
            return EncodingCodes.TIMESTAMP;
        }

        public TimestampType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw((cast(Date)val).toEpochMilli());
        }

        public void write(long l)
        {
            writeConstructor();
            getEncoder().writeRaw(l);

        }

        public bool encodesSuperset(TypeEncoding!(Date) encoding)
        {
            return (getType() == encoding.getType());
        }

        public Date readValue()
        {
            return Date.ofEpochMilli(getDecoder().readRawLong());
        }
    }
}
