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

module hunt.proton.codec.AbstractDescribedType;

import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.AMQPType;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.amqp.UnsignedLong;

import hunt.collection.Map;
import hunt.collection.HashMap;
import hunt.collection.Collection;
import hunt.collection.ArrayList;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;

abstract class AbstractDescribedType(T,M) : AMQPType!(T)  //!(AmqpValue,Object)
{
    private DecoderImpl _decoder;
    private EncoderImpl _encoder;
    private Map!(TypeEncoding!(M), TypeEncoding!(T)) _encodings ;

    this(EncoderImpl encoder)
    {
        _encoder = encoder;
        _decoder = encoder.getDecoder();
        _encodings = new HashMap!(TypeEncoding!(M), TypeEncoding!(T));
    }

    abstract protected UnsignedLong getDescriptor();

    public EncoderImpl getEncoder()
    {
        return _encoder;
    }

    public DecoderImpl getDecoder()
    {
        return _decoder;
    }

    public ITypeEncoding getEncoding(Object v)
    {

        T val = cast(T)v;
        //M asUnderlying = wrap(val);
        //TypeEncoding<M> underlyingEncoding = _encoder.getType(asUnderlying).getEncoding(asUnderlying);
        //TypeEncoding<T> encoding = _encodings.get(underlyingEncoding);
        //if(encoding == null)
        //{
        //    encoding = new DynamicDescribedTypeEncoding(underlyingEncoding);
        //    _encodings.put(underlyingEncoding, encoding);
        //}

        //protected List!Object wrap(Header val)
        //{
        //    return new HeaderWrapper(val);
        //}
        //String
        M asUnderlying = wrap(val); //ArrayList!Object

        IAMQPType tt = _encoder.getType(cast(Object)asUnderlying);
       // IAMQPType tt = _encoder.getType(cast(Object)asUnderlying,typeid(M));
       ITypeEncoding typeEncoding = tt.getEncoding(cast(Object)asUnderlying);
        TypeEncoding!(M) underlyingEncoding = cast(TypeEncoding!(M))typeEncoding;

        if(underlyingEncoding is null) {
            warningf("Wrong casting from %s to %s", typeid(typeEncoding), typeid(TypeEncoding!(M)));
            return null;
        }

       // TypeEncoding!(M) underlyingEncoding = (cast(AMQPType!M)(_encoder.getType(cast(Object)asUnderlying,this.getTypeClass()))).getEncoding(asUnderlying);
        TypeEncoding!(T) encoding = _encodings.get(underlyingEncoding);
        if(encoding is null)
        {
            encoding = new DynamicDescribedTypeEncoding(underlyingEncoding);
            _encodings.put(underlyingEncoding, encoding);
        }
        return cast(ITypeEncoding)encoding;
        //implementationMissing(false);
        //return null;
    }

    abstract protected M wrap(T val);

    public TypeEncoding!(T) getCanonicalEncoding()
    {
        return null;
    }

    public  Collection!(TypeEncoding!(T)) getAllEncodings()
    {
       // auto lst = new ArrayList!(TypeEncoding!(T));

        return new ArrayList!(TypeEncoding!(T)) (_encodings.values());
       // Collection unmodifiable = Collections.unmodifiableCollection(values);
       // return (Collection!(TypeEncoding!(T))) unmodifiable;
    }

    public void write(Object val)
    {
        //T t = cast(T)val;
        //assert(t !is null);
        ITypeEncoding encoding = getEncoding(val);
        if(encoding is null) {
            warning("encoding is null");
        } else {
            encoding.writeConstructor();
            encoding.writeValue(val);
        }
    }

    class DynamicDescribedTypeEncoding : TypeEncoding!(T)
    {
        private TypeEncoding!(M) _underlyingEncoding;
        private TypeEncoding!(UnsignedLong) _descriptorType;
        private int _constructorSize;


        this(TypeEncoding!(M) underlyingEncoding)
        {
            _underlyingEncoding = underlyingEncoding;
            _descriptorType = cast(TypeEncoding!(UnsignedLong))(_encoder.getType(getDescriptor()).getEncoding(getDescriptor()));
            _constructorSize = 1 + _descriptorType.getConstructorSize()
                               + _descriptorType.getValueSize(getDescriptor())
                               + _underlyingEncoding.getConstructorSize();
        }

        public AMQPType!(T) getType()
        {
           // return AbstractDescribedType.this;
            return this.outer;
        }


        int opCmp(ITypeEncoding o)
        {
            return this.getConstructorSize - o.getConstructorSize;
        }

       // alias opCmp = Object.opCmp;

        public void writeConstructor()
        {
            _encoder.writeRaw(EncodingCodes.DESCRIBED_TYPE_INDICATOR);
            _descriptorType.writeConstructor();
            _descriptorType.writeValue(getDescriptor());
            _underlyingEncoding.writeConstructor();
        }

        public int getConstructorSize()
        {
            return _constructorSize;
        }

        public void writeValue(Object val)
        {
            _underlyingEncoding.writeValue(cast(Object)wrap(cast(T)val));
        }

        public int getValueSize(Object val)
        {
            return _underlyingEncoding.getValueSize(cast(Object)wrap(cast(T)val));
        }

        public bool isFixedSizeVal()
        {
            return _underlyingEncoding.isFixedSizeVal();
        }

        public bool encodesSuperset(TypeEncoding!(T) encoding)
        {
            return (getType() == encoding.getType())
                   && (_underlyingEncoding.encodesSuperset((cast(DynamicDescribedTypeEncoding)encoding)
                                                                   ._underlyingEncoding));
        }

        override
        public bool encodesJavaPrimitive()
        {
            return false;
        }

    }
}
