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

module hunt.proton.codec.ByteType;


import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.Byte;
import hunt.proton.codec.PrimitiveTypeEncoding;

class ByteType : AbstractPrimitiveType!(Byte)
{
    private ByteEncoding _byteEncoding;

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _byteEncoding = new ByteEncoding(encoder, decoder);
        encoder.register(typeid(Byte), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Byte);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        return _byteEncoding;
    }


    public ByteEncoding getCanonicalEncoding()
    {
        return _byteEncoding;
    }

    public Collection!(TypeEncoding!(Byte)) getAllEncodings()
    {
        return Collections.singleton!(TypeEncoding!(Byte))(_byteEncoding);
    }

     //Collection!(PrimitiveTypeEncoding!(Byte)) getAllEncodings()
     //{
     //   return super.getAllEncodings();
     //}

    public void writeType(byte b)
    {
        _byteEncoding.write(b);
    }


    class ByteEncoding : FixedSizePrimitiveTypeEncoding!(Byte)
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
            return EncodingCodes.BYTE;
        }

        public ByteType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw((cast(Byte)val).byteValue);
        }


        public void write(byte val)
        {
            writeConstructor();
            getEncoder().writeRaw(val);
        }

        public void writeValue(byte val)
        {
            getEncoder().writeRaw(val);
        }

        public bool encodesSuperset(TypeEncoding!(Byte) encoding)
        {
            return (getType() == encoding.getType());
        }

        public Byte readValue()
        {
            return readPrimitiveValue();
        }

        public Byte readPrimitiveValue()
        {
            return new Byte( getDecoder().readRawByte());
        }


        override
        public bool encodesJavaPrimitive()
        {
            return true;
        }

    }
}
