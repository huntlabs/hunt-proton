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

module hunt.proton.codec.DoubleType;

import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.collection.Collection;
import hunt.collection.Collections;



import hunt.Double;
import hunt.proton.codec.PrimitiveTypeEncoding;

class DoubleType : AbstractPrimitiveType!(Double)
{
    private DoubleEncoding _doubleEncoding;

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _doubleEncoding = new DoubleEncoding(encoder, decoder);
        encoder.register(typeid(Double), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Double);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        return _doubleEncoding;
    }


    public DoubleEncoding getCanonicalEncoding()
    {
        return _doubleEncoding;
    }

    public Collection!(TypeEncoding!(Double)) getAllEncodings()
    {
        return Collections.singleton!(TypeEncoding!(Double))(_doubleEncoding);
    }

    //public Collection!(PrimitiveTypeEncoding!(Double)) getAllEncodings()
    //{
    //    return super.getAllEncodings();
    //}

    public void write(double d)
    {
        _doubleEncoding.write(d);
    }
    
    class DoubleEncoding : FixedSizePrimitiveTypeEncoding!(Double)
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
            return EncodingCodes.DOUBLE;
        }

        public DoubleType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw((cast(Double)val).doubleValue());
        }

        public void writeValue(double val)
        {
            getEncoder().writeRaw(val);
        }

        public void write(double d)
        {
            writeConstructor();
            getEncoder().writeRaw(d);
            
        }

        public bool encodesSuperset(TypeEncoding!(Double) encoding)
        {
            return (getType() == encoding.getType());
        }

        public Double readValue()
        {
            return  new Double( readPrimitiveValue());
        }

        public double readPrimitiveValue()
        {
            return getDecoder().readRawDouble();
        }


        override
        public bool encodesJavaPrimitive()
        {
            return true;
        }
    }
}
