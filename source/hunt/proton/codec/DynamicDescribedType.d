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

module hunt.proton.codec.DynamicDescribedType;

import hunt.proton.amqp.DescribedType;

import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.proton.codec.AMQPType;

import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.EncoderImpl;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.proton.codec.EncodingCodes;

class DynamicDescribedType : AMQPType!(DescribedType)
{

    private EncoderImpl _encoder;
    private Map!(ITypeEncoding, ITypeEncoding) _encodings ;//= new HashMap!(ITypeEncoding, ITypeEncoding)();
    private Object _descriptor;

    this(EncoderImpl encoder, Object descriptor)
    {
        _encoder = encoder;
        _descriptor = descriptor;
        _encodings = new HashMap!(ITypeEncoding, ITypeEncoding);
    }


    public TypeInfo getTypeClass()
    {
        return typeid(DescribedType);
    }

    public ITypeEncoding getEncoding(Object v)
    {
        DescribedType val = cast(DescribedType)v;
        ITypeEncoding underlyingEncoding = _encoder.getType(val.getDescribed()).getEncoding(val.getDescribed());
        ITypeEncoding encoding = _encodings.get(underlyingEncoding);
        if(encoding is null)
        {
            encoding = new DynamicDescribedTypeEncoding(underlyingEncoding);
            _encodings.put(underlyingEncoding, encoding);
        }

        return encoding;
    }

    public TypeEncoding!(DescribedType) getCanonicalEncoding()
    {
        return null;
    }

    public Collection!(TypeEncoding!(DescribedType)) getAllEncodings()
    {
        //Collection values = _encodings.values();
        List!(TypeEncoding!(DescribedType)) lst = new ArrayList!(TypeEncoding!(DescribedType));
        foreach(ITypeEncoding v ;  _encodings.values() )
        {
            lst.add(cast(TypeEncoding!(DescribedType))v);
        }
        //Collection unmodifiable = Collections.unmodifiableCollection(values);
        return lst;
    }

    public void write(Object val)
    {
        ITypeEncoding encoding = getEncoding(val);
        encoding.writeConstructor();
        encoding.writeValue(val);
    }

    class DynamicDescribedTypeEncoding : ITypeEncoding
    {
        private ITypeEncoding _underlyingEncoding;
        private ITypeEncoding _descriptorType;
        private int _constructorSize;


        this(ITypeEncoding underlyingEncoding)
        {
            _underlyingEncoding = underlyingEncoding;
            _descriptorType = _encoder.getType(_descriptor).getEncoding(_descriptor);
            _constructorSize = 1 + _descriptorType.getConstructorSize()
                               + _descriptorType.getValueSize(_descriptor)
                               + _underlyingEncoding.getConstructorSize();
        }

        public AMQPType!(DescribedType) getType()
        {
            return this.outer;
        }

        public void writeConstructor()
        {
            _encoder.writeRaw(EncodingCodes.DESCRIBED_TYPE_INDICATOR);
            _descriptorType.writeConstructor();
            _descriptorType.writeValue(_descriptor);
            _underlyingEncoding.writeConstructor();
        }

        public int getConstructorSize()
        {
            return _constructorSize;
        }

        public void writeValue(Object val)
        {
            _underlyingEncoding.writeValue((cast(DescribedType)val).getDescribed());
        }

        public int getValueSize(Object val)
        {
            return _underlyingEncoding.getValueSize((cast(DescribedType) val).getDescribed());
        }

        public bool isFixedSizeVal()
        {
            return _underlyingEncoding.isFixedSizeVal();
        }

        public bool encodesSuperset(TypeEncoding!DescribedType encoding)
        {
            return (getType() == encoding.getType());
        }

        override
        public bool encodesJavaPrimitive()
        {
            return false;
        }

        int opCmp(ITypeEncoding o)
        {
            return this.getConstructorSize - o.getConstructorSize;
        }

    }
}