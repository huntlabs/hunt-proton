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

module hunt.proton.codec.FloatType;

import hunt.proton.codec.AbstractPrimitiveType;
import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.proton.codec.TypeEncoding;

import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.Float;
import hunt.proton.codec.PrimitiveTypeEncoding;;

class FloatType : AbstractPrimitiveType!(Float)
{
    private FloatEncoding _floatEncoding;

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _floatEncoding = new FloatEncoding(encoder, decoder);
        encoder.register(typeid(Float), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Float);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        return _floatEncoding;
    }


    public FloatEncoding getCanonicalEncoding()
    {
        return _floatEncoding;
    }

    public Collection!(TypeEncoding!(Float)) getAllEncodings()
    {
        return Collections.singleton!(TypeEncoding!(Float))(_floatEncoding);
    }

     //Collection!(PrimitiveTypeEncoding!(Float)) getAllEncodings()
     //{
     //    return super.getAllEncodings();
     //}


    public void write(float f)
    {
        _floatEncoding.write(f);
    }
    
    class FloatEncoding : FixedSizePrimitiveTypeEncoding!(Float)
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
            return EncodingCodes.FLOAT;
        }

        public FloatType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw((cast(Float)val).floatValue());
        }

        public void writeValue(float val)
        {
            getEncoder().writeRaw(val);
        }


        public void write(float f)
        {
            writeConstructor();
            getEncoder().writeRaw(f);
            
        }

        public bool encodesSuperset(TypeEncoding!(Float) encoding)
        {
            return (getType() is encoding.getType());
        }

        public Float readValue()
        {
            return new Float(readPrimitiveValue());
        }

        public float readPrimitiveValue()
        {
            return getDecoder().readRawFloat();
        }


        override
        public bool encodesJavaPrimitive()
        {
            return true;
        }
    }
}
