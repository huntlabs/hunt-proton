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

module hunt.proton.codec.IntegerType;


import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.collection.Collection;
import hunt.collection.ArrayList;
import hunt.Integer;





class IntegerType : AbstractPrimitiveType!(Integer)
{

    interface IntegerEncoding : PrimitiveTypeEncoding!(Integer)
    {
        void write(int i);
        void writeValue(int i);
        int readPrimitiveValue();
    }

    private IntegerEncoding _integerEncoding;
    private IntegerEncoding _smallIntegerEncoding;

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _integerEncoding = new AllIntegerEncoding(encoder, decoder);
        _smallIntegerEncoding = new SmallIntegerEncoding(encoder, decoder);
        encoder.register(typeid(Integer), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Integer);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        return getEncoding((cast(Integer)val).intValue());
    }

    public IntegerEncoding getEncoding(int i)
    {

        return (i >= -128 && i <= 127) ? _smallIntegerEncoding : _integerEncoding;
    }


    public IntegerEncoding getCanonicalEncoding()
    {
        return _integerEncoding;
    }

    public Collection!(TypeEncoding!(Integer)) getAllEncodings()
    {
        ArrayList!(TypeEncoding!(Integer)) lst = new ArrayList!(TypeEncoding!(Integer))();
        lst.add(cast(TypeEncoding!(Integer))_integerEncoding);
        lst.add(cast(TypeEncoding!(Integer))_smallIntegerEncoding);
        return lst;
        //return Arrays.asList(_integerEncoding, _smallIntegerEncoding);
    }

    //public Collection!(PrimitiveTypeEncoding!(Integer)) getAllEncodings()
    //{
    //    return super.getAllEncodings();
    //}

    public void write(int i)
    {
        if(i >= -128 && i <= 127)
        {
            _smallIntegerEncoding.write(i);
        }
        else
        {
            _integerEncoding.write(i);
        }
    }
    
    class AllIntegerEncoding : FixedSizePrimitiveTypeEncoding!(Integer) , IntegerEncoding
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
            return EncodingCodes.INT;
        }

        public IntegerType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw((cast(Integer)val).intValue());
        }
        
        public void write(int i)
        {
            writeConstructor();
            getEncoder().writeRaw(i);
            
        }

        public void writeValue(int i)
        {
            getEncoder().writeRaw(i);
        }

        public int readPrimitiveValue()
        {
            return getDecoder().readRawInt();
        }

        public bool encodesSuperset(TypeEncoding!(Integer) encoding)
        {
            return (getType() == encoding.getType());
        }

        public Integer readValue()
        {
            return new Integer(readPrimitiveValue());
        }

        override
        void skipValue()
        {
            return super.skipValue();
        }

        override
        TypeInfo getTypeClass()
        {
            return super.getTypeClass();
        }


        override
        public bool encodesJavaPrimitive()
        {
            return true;
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

    class SmallIntegerEncoding  : FixedSizePrimitiveTypeEncoding!(Integer) , IntegerEncoding
    {
        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.SMALLINT;
        }

        override
        protected int getFixedSize()
        {
            return 1;
        }

        public void write(int i)
        {
            writeConstructor();
            getEncoder().writeRaw(cast(byte)i);
        }

        public void writeValue(int i)
        {
            getEncoder().writeRaw(cast(byte)i);
        }

        public int readPrimitiveValue()
        {
            return getDecoder().readRawByte();
        }

        public IntegerType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw(cast(byte)(cast(Integer)val).intValue());
        }

        public bool encodesSuperset(TypeEncoding!(Integer) encoder)
        {
            return encoder == this;
        }

        public Integer readValue()
        {
            return new Integer(readPrimitiveValue());
        }


        override
        public bool encodesJavaPrimitive()
        {
            return true;
        }

        override public void skipValue()
        {
            return super.skipValue();
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
