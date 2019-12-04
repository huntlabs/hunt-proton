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

module hunt.proton.codec.BooleanType;


import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;
import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.proton.codec.AbstractPrimitiveType;

import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.collection.Collection;
import hunt.collection.ArrayList;
import hunt.Boolean;

interface BooleanEncoding : PrimitiveTypeEncoding!(Boolean)
{
    void write(bool b);
    void writeValue(Object b);

    bool readPrimitiveValue();
}


class BooleanType : AbstractPrimitiveType!(Boolean)
{

    enum byte BYTE_0 = cast(byte) 0;
    enum byte BYTE_1 = cast(byte) 1;




    private hunt.proton.codec.BooleanType.BooleanEncoding _trueEncoder;
    private hunt.proton.codec.BooleanType.BooleanEncoding _falseEncoder;
    private hunt.proton.codec.BooleanType.BooleanEncoding _boolEncoder;


    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _trueEncoder    = new TrueEncoding(encoder, decoder);
        _falseEncoder   = new FalseEncoding(encoder, decoder);
        _boolEncoder = new AllBooleanEncoding(encoder, decoder);

        encoder.register(typeid(Boolean), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Boolean);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        //return cast(Boolean)val ? _trueEncoder : _falseEncoder;
        return (cast(Boolean)val).booleanValue ? _trueEncoder : _falseEncoder;
    }

    //public BooleanEncoding getEncoding(bool val)
    //{
    //    return val ? _trueEncoder : _falseEncoder;
    //}

    public void writeValue(Boolean val)
    {
        (cast(BooleanEncoding)getEncoding(val)).write(val.booleanValue);
    }




    public BooleanEncoding getCanonicalEncoding()
    {
        return _boolEncoder;
    }

    public Collection!(TypeEncoding!(Boolean)) getAllEncodings()
    {
        ArrayList!(TypeEncoding!(Boolean)) lst = new ArrayList!(TypeEncoding!(Boolean))();
        lst.add(cast(TypeEncoding!(Boolean))_trueEncoder);
        lst.add(cast(TypeEncoding!(Boolean))_falseEncoder);
        lst.add(_boolEncoder);
        return lst;
       // return Arrays.asList(_trueEncoder, _falseEncoder, _boolEncoder);
    }


     //Collection!(PrimitiveTypeEncoding!(Boolean)) getAllEncodings()
     //{
     //    return super.getAllEncodings();
     //}

    class TrueEncoding : FixedSizePrimitiveTypeEncoding!(Boolean) , BooleanEncoding
    {

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected int getFixedSize()
        {
            return 0;
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.BOOLEAN_TRUE;
        }

        public BooleanType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
        }

        public void write(bool b)
        {
            writeConstructor();
        }

        public void writeValue(bool b)
        {
        }

        public bool encodesSuperset(TypeEncoding!(Boolean) encoding)
        {
            return encoding == this;
        }

        public Boolean readValue()
        {
            return Boolean.TRUE;
        }

        public bool readPrimitiveValue()
        {
            return true;
        }

        override
        public bool encodesJavaPrimitive()
        {
            return true;
        }

        override
        void skipValue()
        {
            super.skipValue();
        }

        override
        TypeInfo getTypeClass()
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


    class FalseEncoding : FixedSizePrimitiveTypeEncoding!(Boolean) , hunt.proton.codec.BooleanType.BooleanEncoding
    {

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected int getFixedSize()
        {
            return 0;
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.BOOLEAN_FALSE;
        }

        public BooleanType getType()
        {
            return this.outer;
        }

        public void writeValue(Boolean val)
        {
        }

        public void write(bool b)
        {
            writeConstructor();
        }

        public void writeValue(Object b)
        {
        }

        public bool readPrimitiveValue()
        {
            return false;
        }

        public bool encodesSuperset(TypeEncoding!(Boolean) encoding)
        {
            return encoding == this;
        }

        public Boolean readValue()
        {
            return Boolean.FALSE;
        }


        override
        public bool encodesJavaPrimitive()
        {
            return true;
        }

        override
        void skipValue()
        {
            super.skipValue();
        }

        override
        TypeInfo getTypeClass()
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

    class AllBooleanEncoding : FixedSizePrimitiveTypeEncoding!(Boolean) , BooleanEncoding
    {

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        public BooleanType getType()
        {
            return this.outer;
        }

        override
        protected int getFixedSize()
        {
            return 1;
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.BOOLEAN;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw(cast(Boolean)val ? BYTE_1 : BYTE_0);
        }

        public void write(bool val)
        {
            writeConstructor();
            getEncoder().writeRaw(val ? BYTE_1 : BYTE_0);
        }

        public void writeValue(bool b)
        {
            getEncoder().writeRaw(b ? BYTE_1 : BYTE_0);
        }

        public bool readPrimitiveValue()
        {

            return getDecoder().readRawByte() != BYTE_0;
        }

        public bool encodesSuperset(TypeEncoding!(Boolean) encoding)
        {
            return (getType() == encoding.getType());
        }

        public Boolean readValue()
        {
            return readPrimitiveValue() ? Boolean.TRUE : Boolean.FALSE;
        }


        override
        public bool encodesJavaPrimitive()
        {
            return true;
        }


        override
        public void skipValue()
        {
            super.skipValue();
        }

        override
        public TypeInfo getTypeClass()
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
