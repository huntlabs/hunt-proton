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

module hunt.proton.codec.CharacterType;

import hunt.collection.Collection;
import hunt.collection.Collections;

import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.Char;
import hunt.proton.codec.PrimitiveTypeEncoding;

class CharacterType : AbstractPrimitiveType!(Char)
{
    private CharacterEncoding _characterEncoding;

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _characterEncoding = new CharacterEncoding(encoder, decoder);
        encoder.register(typeid(Char), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Char);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        return _characterEncoding;
    }


    public CharacterEncoding getCanonicalEncoding()
    {
        return _characterEncoding;
    }

    public Collection!(TypeEncoding!(Char)) getAllEncodings()
    {
        return Collections.singleton!(TypeEncoding!(Char))(_characterEncoding);
    }

    //public Collection!(PrimitiveTypeEncoding!(Char)) getAllEncodings()
    // {
    //    return super.getAllEncodings();
    // }

    public void write(char c)
    {
        _characterEncoding.write(c);
    }

    class CharacterEncoding : FixedSizePrimitiveTypeEncoding!(Char)
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
            return EncodingCodes.CHAR;
        }

        public CharacterType getType()
        {
            return this.outer;
        }

        public void writeValue(Object val)
        {
            getEncoder().writeRaw(cast(int)(cast(Char)val).charValue() & 0xffff);
        }

        public void writeValue(char val)
        {
            getEncoder().writeRaw(cast(int)val & 0xffff);
        }

        public void write(char c)
        {
            writeConstructor();
            getEncoder().writeRaw(cast(int)c & 0xffff);

        }

        public bool encodesSuperset(TypeEncoding!(Char) encoding)
        {
            return (getType() == encoding.getType());
        }

        public Char readValue()
        {
            return readPrimitiveValue();
        }

        public Char readPrimitiveValue()
        {
            return  new Char(cast(char) (getDecoder().readRawInt() & 0xffff));
        }


        override
        public bool encodesJavaPrimitive()
        {
            return true;
        }
    }
}
