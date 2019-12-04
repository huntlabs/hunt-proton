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

module hunt.proton.codec.ShortType;

import hunt.proton.codec.AbstractPrimitiveType;
import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.TypeEncoding;

import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.Short;
import hunt.proton.codec.PrimitiveTypeEncoding;

class ShortType : AbstractPrimitiveType!(Short)
{
    private ShortEncoding _shortEncoding;

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _shortEncoding = new ShortEncoding(encoder, decoder);
        encoder.register(typeid(Short), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Short);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        return _shortEncoding;
    }

    public void write(short s)
    {
        _shortEncoding.write(s);
    }

    public ShortEncoding getCanonicalEncoding()
    {
        return _shortEncoding;
    }

    public Collection!(TypeEncoding!(Short)) getAllEncodings()
    {
        return Collections.singleton!(TypeEncoding!(Short))(_shortEncoding);
    }


     //Collection!(PrimitiveTypeEncoding!(Short)) getAllEncodings()
     //{
     //   return super.getAllEncodings();
     //}



    class ShortEncoding : FixedSizePrimitiveTypeEncoding!(Short)
    {

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected int getFixedSize()
        {
            return 2;
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.SHORT;
        }

        public ShortType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw((cast(Short)val).shortValue());
        }

        public void writeValue(short val)
        {
            getEncoder().writeRaw(val);
        }


        public void write(short s)
        {
            writeConstructor();
            getEncoder().writeRaw(s);
        }

        public bool encodesSuperset(TypeEncoding!(Short) encoding)
        {
            return (getType() == encoding.getType());
        }

        public Short readValue()
        {
            return  new Short( readPrimitiveValue());
        }

        public short readPrimitiveValue()
        {
            return getDecoder().readRawShort();
        }


        override
        public bool encodesJavaPrimitive()
        {
            return true;
        }

    }
}
