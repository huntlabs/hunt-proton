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

module hunt.proton.codec.UnsignedLongType;

import hunt.proton.amqp.UnsignedLong;

import hunt.collection.Collection;

import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.collection.ArrayList;
import hunt.collection.List;

interface UnsignedLongEncoding : PrimitiveTypeEncoding!(UnsignedLong)
{

}


class UnsignedLongType : AbstractPrimitiveType!(UnsignedLong)
{

    private UnsignedLongEncoding _unsignedLongEncoding;
    private UnsignedLongEncoding _smallUnsignedLongEncoding;
    private UnsignedLongEncoding _zeroUnsignedLongEncoding;


    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _unsignedLongEncoding = new AllUnsignedLongEncoding(encoder, decoder);
        _smallUnsignedLongEncoding = new SmallUnsignedLongEncoding(encoder, decoder);
        _zeroUnsignedLongEncoding = new ZeroUnsignedLongEncoding(encoder, decoder);
        encoder.register(typeid(UnsignedLong), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(UnsignedLong);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        long l = (cast(UnsignedLong)val).longValue();
        return l == 0L
            ? _zeroUnsignedLongEncoding
            : (l >= 0 && l <= 255L) ? _smallUnsignedLongEncoding : _unsignedLongEncoding;
    }

    public void fastWrite(EncoderImpl encoder, UnsignedLong value)
    {
        long longValue = value.longValue();
        if (longValue == 0)
        {
            encoder.writeRaw(EncodingCodes.ULONG0);
        }
        else if (longValue > 0 && longValue <= 255)
        {
            encoder.writeRaw(EncodingCodes.SMALLULONG);
            encoder.writeRaw(cast(byte)longValue);
        }
        else
        {
            encoder.writeRaw(EncodingCodes.ULONG);
            encoder.writeRaw(longValue);
        }
    }

    public UnsignedLongEncoding getCanonicalEncoding()
    {
        return _unsignedLongEncoding;
    }

    public Collection!(TypeEncoding!(UnsignedLong)) getAllEncodings()
    {
        List!(TypeEncoding!(UnsignedLong)) lst = new ArrayList!(TypeEncoding!(UnsignedLong))();
        lst.add(_zeroUnsignedLongEncoding);
        lst.add(_smallUnsignedLongEncoding);
        lst.add(_unsignedLongEncoding);
        return lst;
       // return Arrays.asList(_zeroUnsignedLongEncoding, _smallUnsignedLongEncoding, _unsignedLongEncoding);
    }

     //Collection!(PrimitiveTypeEncoding!(UnsignedLong)) getAllEncodings()
     //{
     //    return super.getAllEncodings();
     //}

    class AllUnsignedLongEncoding
            : FixedSizePrimitiveTypeEncoding!(UnsignedLong)
            , UnsignedLongEncoding
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
            return EncodingCodes.ULONG;
        }

        public UnsignedLongType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw((cast(UnsignedLong)val).longValue());
        }

        override
        public void skipValue()
        {
            super.skipValue();
        }

        override public  bool encodesJavaPrimitive()
        {
            return super.encodesJavaPrimitive();
        }

        override public  TypeInfo getTypeClass()
        {
            return super.getTypeClass();
        }

        public bool encodesSuperset(TypeEncoding!(UnsignedLong) encoding)
        {
            return (getType() == encoding.getType());
        }

        public UnsignedLong readValue()
        {
            return UnsignedLong.valueOf(getDecoder().readRawLong());
        }

        override void writeConstructor()
        {
            return super.writeConstructor();
        }

        override  int getConstructorSize()
        {
            return super.getConstructorSize();
        }
    }

    class SmallUnsignedLongEncoding
            : FixedSizePrimitiveTypeEncoding!(UnsignedLong)
            , UnsignedLongEncoding
    {
        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.SMALLULONG;
        }

        override
        protected int getFixedSize()
        {
            return 1;
        }

        override
        public void skipValue()
        {
            super.skipValue();
        }

        override public  bool encodesJavaPrimitive()
        {
            return super.encodesJavaPrimitive();
        }

        override public  TypeInfo getTypeClass()
        {
            return super.getTypeClass();
        }


        public UnsignedLongType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw(cast(byte)(cast(UnsignedLong)val).longValue());
        }

        public bool encodesSuperset(TypeEncoding!(UnsignedLong) encoder)
        {
            return encoder is this ;// || typeof(encoder).stringof == typeof(ZeroUnsignedLongEncoding).stringof;
        }

        public UnsignedLong readValue()
        {
            return UnsignedLong.valueOf((cast(long)getDecoder().readRawByte())&0xff);
        }

        override void writeConstructor()
        {
            return super.writeConstructor();
        }

        override  int getConstructorSize()
        {
            return super.getConstructorSize();
        }
    }


    class ZeroUnsignedLongEncoding
            : FixedSizePrimitiveTypeEncoding!(UnsignedLong)
            , UnsignedLongEncoding
    {
        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.ULONG0;
        }

        override
        protected int getFixedSize()
        {
            return 0;
        }


        public UnsignedLongType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
        }

        override
        public void skipValue()
        {
            super.skipValue();
        }

        override public  bool encodesJavaPrimitive()
        {
            return super.encodesJavaPrimitive();
        }

        override public  TypeInfo getTypeClass()
        {
            return super.getTypeClass();
        }

        public bool encodesSuperset(TypeEncoding!(UnsignedLong) encoder)
        {
            return encoder == this;
        }

        public UnsignedLong readValue()
        {
            return UnsignedLong.ZERO;
        }


        override void writeConstructor()
        {
            return super.writeConstructor();
        }

        override  int getConstructorSize()
        {
            return super.getConstructorSize();
        }
    }
}
