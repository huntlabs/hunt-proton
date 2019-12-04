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

module hunt.proton.codec.NullType;

import hunt.collection.Collection;
import hunt.collection.Collections;

import hunt.Nullable;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.EncodingCodes;
import hunt.Object;
import hunt.logging;

class Null
{

}

class NullEncoding : FixedSizePrimitiveTypeEncoding!(Null)
{

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        super(encoder, decoder);
    }

    override
    public int getFixedSize()
    {
        return 0;
    }

    override
    public byte getEncodingCode()
    {
        return EncodingCodes.NULL;
    }

    public NullType getType()
    {
      //  return this.outer;
        return null;
    }

    public void writeValue(Object val)
    {
    }

    public void writeValue()
    {
    }

    public bool encodesSuperset(TypeEncoding!(Null) encoding)
    {
        return encoding == this;
    }

    public Object readValue()
    {
        return null;
    }

    public void write()
    {
        writeConstructor();
    }
}

class NullType : AbstractPrimitiveType!(Null)
{
    private NullEncoding _nullEncoding;

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _nullEncoding = new NullEncoding(encoder, decoder);
        encoder.register(typeid(Null), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Null);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        return _nullEncoding;
    }


    public NullEncoding getCanonicalEncoding()
    {
        return _nullEncoding;
    }

    public Collection!(TypeEncoding!Null) getAllEncodings()
    {
        return Collections.singleton!(TypeEncoding!Null)(_nullEncoding);
    }

    public void write()
    {
        _nullEncoding.write();
    }


}