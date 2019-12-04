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

module hunt.proton.codec.UnsignedIntegerType;

import hunt.proton.amqp.UnsignedInteger;

import hunt.proton.codec.TypeEncoding;
import hunt.collection.Collection;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.collection.ArrayList;
import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;

interface UnsignedIntegerEncoding : PrimitiveTypeEncoding!(UnsignedInteger)
{

}


class UnsignedIntegerType : AbstractPrimitiveType!(UnsignedInteger)
{

    private UnsignedIntegerEncoding _unsignedIntegerEncoding;
    private UnsignedIntegerEncoding _smallUnsignedIntegerEncoding;
    private UnsignedIntegerEncoding _zeroUnsignedIntegerEncoding;


    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _unsignedIntegerEncoding = new AllUnsignedIntegerEncoding(encoder, decoder);
        _smallUnsignedIntegerEncoding = new SmallUnsignedIntegerEncoding(encoder, decoder);
        _zeroUnsignedIntegerEncoding = new ZeroUnsignedIntegerEncoding(encoder, decoder);
        encoder.register(typeid(UnsignedInteger), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(UnsignedInteger);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        int i = (cast(UnsignedInteger)val).intValue();
        return i == 0
            ? _zeroUnsignedIntegerEncoding
            : (i >= 0 && i <= 255) ? _smallUnsignedIntegerEncoding : _unsignedIntegerEncoding;
    }

    public void fastWrite(EncoderImpl encoder, UnsignedInteger value)
    {
        int intValue = value.intValue();
        if (intValue == 0)
        {
            encoder.writeRaw(EncodingCodes.UINT0);
        }
        else if (intValue > 0 && intValue <= 255)
        {
            encoder.writeRaw(EncodingCodes.SMALLUINT);
            encoder.writeRaw(cast(byte)intValue);
        }
        else
        {
            encoder.writeRaw(EncodingCodes.UINT);
            encoder.writeRaw(intValue);
        }
    }

    public UnsignedIntegerEncoding getCanonicalEncoding()
    {
        return _unsignedIntegerEncoding;
    }

    public Collection!(TypeEncoding!(UnsignedInteger)) getAllEncodings()
    {
        ArrayList!(TypeEncoding!(UnsignedInteger)) lst = new ArrayList!(TypeEncoding!(UnsignedInteger))();
        lst.add(_unsignedIntegerEncoding);
        lst.add(_smallUnsignedIntegerEncoding);
        lst.add(_zeroUnsignedIntegerEncoding);
        return lst;
       // return Arrays.asList(_unsignedIntegerEncoding, _smallUnsignedIntegerEncoding, _zeroUnsignedIntegerEncoding);
    }

    //Collection!(PrimitiveTypeEncoding!(UnsignedInteger)) getAllEncodings()
    //{
    //    return super.getAllEncodings();
    //}

    class AllUnsignedIntegerEncoding
            : FixedSizePrimitiveTypeEncoding!(UnsignedInteger)
            , UnsignedIntegerEncoding
    {

        this(EncoderImpl encoder, DecoderImpl decoder)
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
            return EncodingCodes.UINT;
        }

        public UnsignedIntegerType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw((cast(UnsignedInteger)val).intValue());
        }

        public void write(int i)
        {
            writeConstructor();
            getEncoder().writeRaw(i);

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

        public bool encodesSuperset(TypeEncoding!(UnsignedInteger) encoding)
        {
            return (getType() == encoding.getType());
        }

        public UnsignedInteger readValue()
        {
            return UnsignedInteger.valueOf(getDecoder().readRawInt());
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

    class SmallUnsignedIntegerEncoding
            : FixedSizePrimitiveTypeEncoding!(UnsignedInteger)
            , UnsignedIntegerEncoding
    {
        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.SMALLUINT;
        }

        override
        protected int getFixedSize()
        {
            return 1;
        }


        public UnsignedIntegerType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw(cast(byte)(cast(UnsignedInteger)val).intValue());
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

        public bool encodesSuperset(TypeEncoding!(UnsignedInteger) encoder)
        {
            return encoder is this ; // ||  typeof(encoder).stringof ==  typeof(ZeroUnsignedIntegerEncoding).stringof;
        }

        public UnsignedInteger readValue()
        {
            return UnsignedInteger.valueOf((cast(int)getDecoder().readRawByte()) & 0xff);
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


    class ZeroUnsignedIntegerEncoding
            : FixedSizePrimitiveTypeEncoding!(UnsignedInteger)
            , UnsignedIntegerEncoding
    {
        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.UINT0;
        }

        override
        protected int getFixedSize()
        {
            return 0;
        }


        public UnsignedIntegerType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
        }

        public bool encodesSuperset(TypeEncoding!(UnsignedInteger) encoder)
        {
            return encoder == this;
        }

        public UnsignedInteger readValue()
        {
            return UnsignedInteger.ZERO;
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
