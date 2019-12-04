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

module hunt.proton.codec.LongType;


import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;
import hunt.proton.codec.EncodingCodes;


import hunt.collection.ArrayList;
import hunt.collection.Collection;
import hunt.Long;

class LongType : AbstractPrimitiveType!(Long)
{

    interface LongEncoding : PrimitiveTypeEncoding!(Long)
    {
        void write(long l);
        void writeValue(long l);
        public long readPrimitiveValue();
    }
    
    private LongEncoding _longEncoding;
    private LongEncoding _smallLongEncoding;

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _longEncoding = new AllLongEncoding(encoder, decoder);
        _smallLongEncoding = new SmallLongEncoding(encoder, decoder);
        encoder.register(typeid(Long), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Long);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        return getEncoding((cast(Long)val).longValue());
    }

    public LongEncoding getEncoding(long l)
    {
        return (l >= -128 && l <= 127) ? _smallLongEncoding : _longEncoding;
    }


    public LongEncoding getCanonicalEncoding()
    {
        return _longEncoding;
    }

    public Collection!(TypeEncoding!(Long)) getAllEncodings()
    {
        ArrayList!(TypeEncoding!(Long)) lst = new ArrayList!(TypeEncoding!(Long))();
        lst.add(_smallLongEncoding);
        lst.add(_longEncoding);
        return lst;
       // return Arrays.asList(_smallLongEncoding, _longEncoding);
    }

    //Collection!(PrimitiveTypeEncoding!(Long)) getAllEncodings()
    //{
    //    return super.getAllEncodings();
    //}



    public void write(long l)
    {
        if(l >= -128 && l <= 127)
        {
            _smallLongEncoding.write(l);
        }
        else
        {
            _longEncoding.write(l);
        }
    }
    
    class AllLongEncoding : FixedSizePrimitiveTypeEncoding!(Long) , LongEncoding
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
            return EncodingCodes.LONG;
        }

        public LongType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw((cast(Long)val).longValue());
        }
        
        public void write(long l)
        {
            writeConstructor();
            getEncoder().writeRaw(l);
            
        }

        public void writeValue(long l)
        {
            getEncoder().writeRaw(l);
        }

        public bool encodesSuperset(TypeEncoding!(Long) encoding)
        {
            return (getType() == encoding.getType());
        }

        public Long readValue()
        {
            return new Long(readPrimitiveValue());
        }

        public long readPrimitiveValue()
        {
            return getDecoder().readRawLong();
        }


        override
        public bool encodesJavaPrimitive()
        {
            return true;
        }

        override void skipValue()
        {
            return super.skipValue();
        }

        override  TypeInfo getTypeClass()
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

    class SmallLongEncoding  : FixedSizePrimitiveTypeEncoding!(Long) , LongEncoding
    {
        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.SMALLLONG;
        }

        override
        protected int getFixedSize()
        {
            return 1;
        }

        public void write(long l)
        {
            writeConstructor();
            getEncoder().writeRaw(cast(byte)l);
        }

        public void writeValue(long l)
        {
            getEncoder().writeRaw(cast(byte)l);
        }

        public long readPrimitiveValue()
        {
            return cast(long) getDecoder().readRawByte();
        }

        public LongType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw(cast(byte)(cast(Long)val).longValue());
        }

        public bool encodesSuperset(TypeEncoding!(Long) encoder)
        {
            return encoder == this;
        }

        public Long readValue()
        {
            return new Long(readPrimitiveValue());
        }


        override
        public bool encodesJavaPrimitive()
        {
            return true;
        }

        override
        public  void skipValue()
        {
            return super.skipValue();
        }

        override
        public  TypeInfo getTypeClass()
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
