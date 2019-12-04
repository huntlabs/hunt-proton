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

module hunt.proton.codec.BinaryType;

import hunt.proton.codec.SmallFloatingSizePrimitiveTypeEncoding;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.LargeFloatingSizePrimitiveTypeEncoding;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.collection.Collection;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.collection.ArrayList;


import hunt.Exceptions;
import hunt.proton.amqp.Binary;
import hunt.logging;

class BinaryType : AbstractPrimitiveType!(Binary)
{
    private BinaryEncoding _binaryEncoding;
    private BinaryEncoding _shortBinaryEncoding;

    interface BinaryEncoding : PrimitiveTypeEncoding!(Binary)
    {

    }

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _binaryEncoding = new LongBinaryEncoding(encoder, decoder);
        _shortBinaryEncoding = new ShortBinaryEncoding(encoder, decoder);
        encoder.register(typeid(Binary), this);
        decoder.register(this);
    }


    public TypeInfo getTypeClass()
    {
        return typeid(Binary);
    }


    public ITypeEncoding getEncoding(Object val)
    {
        return (cast(Binary)val).getLength() <= 255 ? _shortBinaryEncoding : _binaryEncoding;
    }


    public BinaryEncoding getCanonicalEncoding()
    {
        return _binaryEncoding;
    }


    public Collection!(TypeEncoding!(Binary)) getAllEncodings()
    {
        ArrayList!(TypeEncoding!(Binary)) lst = new ArrayList!(TypeEncoding!(Binary))();
        lst.add(cast(TypeEncoding!(Binary))_shortBinaryEncoding);
        lst.add(cast(TypeEncoding!(Binary))_binaryEncoding);
        //return Arrays.asList(_shortBinaryEncoding, _binaryEncoding);
        return lst;
    }

    //public Collection!(PrimitiveTypeEncoding!(Binary)) getAllEncodings()
    //{
    //   return super.getAllEncodings();
    //}


    public void fastWrite(EncoderImpl encoder, Binary binary)
    {
        if (binary.getLength() <= 255)
        {
            // Reserve size of body + type encoding and single byte size
            encoder.getBuffer().ensureRemaining(2 + binary.getLength());
            encoder.writeRaw(EncodingCodes.VBIN8);
            encoder.writeRaw(cast(byte) binary.getLength());
            encoder.writeRaw(binary.getArray(), binary.getArrayOffset(), binary.getLength());
        }
        else
        {
            // Reserve size of body + type encoding and four byte size
            encoder.getBuffer().ensureRemaining(5 + binary.getLength());
            encoder.writeRaw(EncodingCodes.VBIN32);
            encoder.writeRaw(binary.getLength());
            encoder.writeRaw(binary.getArray(), binary.getArrayOffset(), binary.getLength());
        }
    }

    class LongBinaryEncoding
            : LargeFloatingSizePrimitiveTypeEncoding!(Binary)
            , BinaryEncoding
    {

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected void writeEncodedValue(Binary val)
        {
            getEncoder().getBuffer().ensureRemaining(val.getLength());
            getEncoder().writeRaw(val.getArray(), val.getArrayOffset(), val.getLength());
        }

        override
        protected int getEncodedValueSize(Binary val)
        {
            return val.getLength();
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.VBIN32;
        }

        override
        public BinaryType getType()
        {
            return this.outer;
        }

        override
        public bool encodesSuperset(TypeEncoding!(Binary) encoding)
        {
            return (getType() == encoding.getType());
        }

        override
        public Object readValue()
        {
            DecoderImpl decoder = getDecoder();
            int size = decoder.readRawInt();
            if (size > decoder.getByteBufferRemaining()) {
                logError("Binary data size is specified to be greater than the amount of data available");
                //throw new IllegalArgumentException("Binary data size "+size+" is specified to be greater than the amount of data available ("+
                //                                   decoder.getByteBufferRemaining()+")");
            }
            byte[] data = new byte[size];
            decoder.readRaw(data, 0, size);
            return new Binary(data);
        }

        override
        public void skipValue()
        {
            DecoderImpl decoder = getDecoder();
            ReadableBuffer buffer = decoder.getBuffer();
            int size = decoder.readRawInt();
            buffer.position(buffer.position() + size);
        }


        override
        public TypeInfo getTypeClass()
        {
            return super.getTypeClass();
        }



        override
        public bool encodesJavaPrimitive()
        {
            return false;
        }


        override void writeConstructor()
        {
            super.writeConstructor();
        }

        override int getConstructorSize()
        {
            return super.getConstructorSize();
        }

    }

    class ShortBinaryEncoding
            : SmallFloatingSizePrimitiveTypeEncoding!(Binary)
            , BinaryEncoding
    {

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected void writeEncodedValue(Binary val)
        {
            getEncoder().getBuffer().ensureRemaining(val.getLength());
            getEncoder().writeRaw(val.getArray(), val.getArrayOffset(), val.getLength());
        }

        override
        protected int getEncodedValueSize(Binary val)
        {
            return val.getLength();
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.VBIN8;
        }

        override
        public BinaryType getType()
        {
            return this.outer;
        }

        override
        public bool encodesSuperset(TypeEncoding!(Binary) encoder)
        {
            return encoder == this;
        }

        override
        public Binary readValue()
        {
            int size = (cast(int)getDecoder().readRawByte()) & 0xff;
            byte[] data = new byte[size];
            getDecoder().readRaw(data, 0, size);
            return new Binary(data);
        }

        override
        public void skipValue()
        {
            DecoderImpl decoder = getDecoder();
            ReadableBuffer buffer = decoder.getBuffer();
            int size = (cast(int)getDecoder().readRawByte()) & 0xff;
            buffer.position(buffer.position() + size);
        }


        override
        public TypeInfo getTypeClass()
        {
            return super.getTypeClass();
        }


        override
        public bool encodesJavaPrimitive()
        {
            return false;
        }

        override void writeConstructor()
        {
            super.writeConstructor();
        }

        override int getConstructorSize()
        {
            return super.getConstructorSize();
        }
    }
}
