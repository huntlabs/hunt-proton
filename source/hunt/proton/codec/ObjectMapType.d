module hunt.proton.codec.ObjectMapType;

import std.stdio;

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
import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.proton.codec.AMQPType;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.collection.Collection;
import hunt.collection.Map;
import hunt.collection.ArrayList;
import hunt.proton.codec.LargeFloatingSizePrimitiveTypeEncoding;
import hunt.Exceptions;
import hunt.Object;
import hunt.collection.Map;
import hunt.String;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.StringType;
import hunt.collection.LinkedHashMap;
import hunt.proton.codec.TypeConstructor;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.SmallFloatingSizePrimitiveTypeEncoding;
import hunt.logging;
import std.conv : to;

interface MapEncoding : PrimitiveTypeEncoding!(Map!(Object,Object))
{
    void setValue(Map!(Object,Object) value, int length);
}

class ObjectMapType : AbstractPrimitiveType!(Map!(Object,Object))
{
    private MapEncoding _mapEncoding;
    private MapEncoding _shortMapEncoding;
    private EncoderImpl _encoder;

    //private AMQPType<?> fixedKeyType;

    private IAMQPType  fixedKeyType;


    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _encoder = encoder;
        _mapEncoding = new AllMapEncoding(encoder, decoder);
        _shortMapEncoding = new ShortMapEncoding(encoder, decoder);
        encoder.register(typeid(LinkedHashMap!(Object,Object)), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(LinkedHashMap!(Object,Object));
    }

    public void setKeyEncoding(IAMQPType keyType)
    {
        this.fixedKeyType = keyType;
    }

    public ITypeEncoding getEncoding(Object val)
    {
        int calculatedSize = calculateSize(cast(Map!(Object,Object))val);
        MapEncoding encoding = ((cast(Map!(Object,Object))val).size() > 127 || calculatedSize >= 254)
        ? _mapEncoding
        : _shortMapEncoding;

        encoding.setValue(cast(Map!(Object,Object))val, calculatedSize);
        return encoding;
    }

    private int calculateSize(Map!(Object,Object) map)
    {

        //implementationMissing(false);
        int len = 0;

        //Iterator<Map.Entry<?, ?>> iter = map.entrySet().iterator();
        IAMQPType IfixedKeyType = this.fixedKeyType;

        // Clear existing fixed key type encoding to prevent application to nested Maps
        setKeyEncoding(null);

        try
        {

            foreach (MapEntry!(Object, Object) element ; map)
            {
                ITypeEncoding elementEncoding;
                if (IfixedKeyType is null)
                {
                    IAMQPType tmp = _encoder.getType( element.getKey());
                    if (tmp is null)
                    {
                        logError( "getType Error");
                    }

                    elementEncoding = tmp.getEncoding( element.getKey());
                    //  elementEncoding = _encoder.getType(element.getKey()).getEncoding(element.getKey());
                }
                else
                {
                    elementEncoding = IfixedKeyType.getEncoding( element.getKey());
                }

                len += elementEncoding.getConstructorSize() + elementEncoding.getValueSize( element.getKey());




                IAMQPType tmp = (_encoder.getType( element.getValue()));
                if (tmp is null)
                {
                    logError( "getType Error");
                }
                ITypeEncoding  elementEncodingVal = tmp.getEncoding( element.getValue());
                len += elementEncodingVal.getConstructorSize() + elementEncodingVal.getValueSize( element.getValue());


                //if (cast(String)element.getValue() !is null)
                //{
                //    StringType tmp = cast(StringType)(_encoder.getType(element.getValue()));
                //    if (tmp is null)
                //    {
                //        logError("getType Error");
                //    }
                //
                //    StringEncoding  elementEncodingVal = tmp.getEncoding(cast(String)element.getValue());
                //    len += elementEncodingVal.getConstructorSize() + elementEncodingVal.getValueSize(cast(String)element.getValue());
                //}else
                //{
                //    logError("unknown type");
                //}
            }
        } finally {
            setKeyEncoding(IfixedKeyType);
        }



        //try {
        //    while (iter.hasNext())
        //    {
        //        Map.Entry<?, ?> element = iter.next();
        //        TypeEncoding elementEncoding;
        //
        //        if (fixedKeyType is null)
        //        {
        //            elementEncoding = _encoder.getType(element.getKey()).getEncoding(element.getKey());
        //        }
        //        else
        //        {
        //            elementEncoding = fixedKeyType.getEncoding(element.getKey());
        //        }
        //
        //        len += elementEncoding.getConstructorSize() + elementEncoding.getValueSize(element.getKey());
        //        elementEncoding = _encoder.getType(element.getValue()).getEncoding(element.getValue());
        //        len += elementEncoding.getConstructorSize() + elementEncoding.getValueSize(element.getValue());
        //    }
        //} finally {
        //    // Reset Existing key type encoding for later encode step or reuse until cleared by caller
        //    setKeyEncoding(fixedKeyType);
        //}

        //scope(exit)
        //{
        //    setKeyEncoding(IfixedKeyType);
        //}

        return len;
    }


    private static ITypeConstructor findNextDecoder(DecoderImpl decoder, ReadableBuffer buffer, ITypeConstructor previousConstructor)
    {
        if (previousConstructor is null)
        {
            return decoder.readConstructor();
        }
        else
        {
            byte encodingCode = buffer.get(buffer.position());
            if (encodingCode == EncodingCodes.DESCRIBED_TYPE_INDICATOR)
            {
                return decoder.readConstructor();
            }
            else
            {
                IPrimitiveTypeEncoding primitiveConstructor = cast(IPrimitiveTypeEncoding) previousConstructor;
                if (encodingCode != primitiveConstructor.getEncodingCode())
                {
                    return decoder.readConstructor();
                }
                else
                {
                    // consume the encoding code byte for real
                    encodingCode = buffer.get();
                }
            }
        }

        return previousConstructor;
    }

    public MapEncoding getCanonicalEncoding()
    {
        return _mapEncoding;
    }



    //Collection!(TypeEncoding!(Map!(Object,Object)))
    public Collection!(TypeEncoding!(Map!(Object,Object))) getAllEncodings()
    {
        ArrayList!(TypeEncoding!(Map!(Object,Object))) lst = new ArrayList!(TypeEncoding!(Map!(Object,Object)))();
        lst.add(_shortMapEncoding);
        lst.add(_mapEncoding);
        return lst;
        // return Arrays.asList(_shortMapEncoding, _mapEncoding);
    }

    class AllMapEncoding
    : LargeFloatingSizePrimitiveTypeEncoding!(Map!(Object,Object))
    , MapEncoding
    {

        private Map!(Object,Object) _value;
        private int _length;

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected void writeEncodedValue(Map!(Object,Object) map)
        {
            getEncoder().getBuffer().ensureRemaining(getSizeBytes() + getEncodedValueSize(map));
            getEncoder().writeRaw(2 * map.size());

            //  Iterator<Map.Entry> iter = map.entrySet().iterator();
            IAMQPType IfixedKeyType =  this.outer.fixedKeyType;

            // Clear existing fixed key type encoding to prevent application to nested Maps
            setKeyEncoding(null);

            try
            {
                foreach (MapEntry!(Object, Object) element ; map)
                {
                    ITypeEncoding elementEncoding;
                    if (IfixedKeyType is null)
                    {
                        elementEncoding = (_encoder.getType( element.getKey())).getEncoding( element.getKey());
                        if (elementEncoding is null)
                        {
                            logError( "getType Error");
                        }

                        //  elementEncoding = _encoder.getType(element.getKey()).getEncoding(element.getKey());
                    }
                    else
                    {
                        elementEncoding = IfixedKeyType.getEncoding( element.getKey());
                    }

                    elementEncoding.writeConstructor();
                    elementEncoding.writeValue( element.getKey());

                    ITypeEncoding elementEncodingVal;
                    elementEncodingVal = _encoder.getType( element.getValue()).getEncoding( element.getValue());
                    //if (tmp is null)
                    //{
                    //    logError("getType error");
                    //}
                    //  elementEncodingVal = tmp.getEncoding(cast(String)element.getValue());
                    elementEncodingVal.writeConstructor();
                    elementEncodingVal.writeValue( element.getValue());

                    //elementEncoding = getEncoder().getType(element.getValue()).getEncoding(element.getValue());
                    //elementEncoding.writeConstructor();
                    //elementEncoding.writeValue(element.getValue());

                }
            } finally {
                setKeyEncoding(IfixedKeyType);
            }

            //try {
            //    while (iter.hasNext())
            //    {
            //       // Map.Entry<?, ?> element = iter.next();
            //        TypeEncoding elementEncoding;
            //
            //        if (fixedKeyType is null)
            //        {
            //            elementEncoding = _encoder.getType(element.getKey()).getEncoding(element.getKey());
            //        }
            //        else
            //        {
            //            elementEncoding = fixedKeyType.getEncoding(element.getKey());
            //        }
            //
            //        elementEncoding.writeConstructor();
            //        elementEncoding.writeValue(element.getKey());
            //        elementEncoding = getEncoder().getType(element.getValue()).getEncoding(element.getValue());
            //        elementEncoding.writeConstructor();
            //        elementEncoding.writeValue(element.getValue());
            //    }
            //} finally {
            //    // Reset Existing key type encoding for later encode step or reuse until cleared by caller
            //    setKeyEncoding(fixedKeyType);
            //}
        }

        override
        protected int getEncodedValueSize(Map!(Object,Object) val)
        {
            return 4 + ((val == _value) ? _length : calculateSize(val));
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.MAP32;
        }

        override
        public ObjectMapType getType()
        {
            return this.outer;
        }

        override
        public bool encodesSuperset(TypeEncoding!(Map!(Object,Object)) encoding)
        {
            return (getType() == encoding.getType());
        }

        override
        public Object readValue()
        {
            DecoderImpl decoder = getDecoder();
            ReadableBuffer buffer = decoder.getBuffer();

            int size = decoder.readRawInt();
            // todo - limit the decoder with size
            int count = decoder.readRawInt();
            if (count > decoder.getByteBufferRemaining()) {
                throw new IllegalArgumentException("Map element count " ~ to!string(count) ~" is specified to be greater than the amount of data available ("~
                to!string(decoder.getByteBufferRemaining())~ ")");
            }

            ITypeConstructor keyConstructor = null;
            ITypeConstructor valueConstructor = null;

            Map!(Object, Object) map = new LinkedHashMap!(Object,Object)(count);
            for(int i = 0; i < count / 2; i++)
            {
                keyConstructor =  findNextDecoder(decoder, buffer, keyConstructor);
                if(keyConstructor is null)
                {
                    // throw new DecodeException("Unknown constructor");
                    logError("Unknown constructor");
                    return null;
                }

                Object key = keyConstructor.readValue();

                bool arrayType = false;
                byte code = buffer.get(buffer.position());
                switch (code)
                {
                    case EncodingCodes.ARRAY8:
                    goto case;
                    case EncodingCodes.ARRAY32:
                    arrayType = true;
                    break;
                    default:
                    break;
                }

                valueConstructor = findNextDecoder(decoder, buffer, valueConstructor);
                if (valueConstructor is null)
                {
                    // throw new DecodeException("Unknown constructor");
                    logError("Unknown constructor");
                    return null;
                }

                Object value;

                //if (arrayType)
                //{
                //    value = ((ArrayType.ArrayEncoding) valueConstructor).readValueArray();
                //}
                //else
                {
                    value = valueConstructor.readValue();
                }

                map.put(key, value);
            }

            return cast(Object)map;
        }

        override
        public void skipValue()
        {
            DecoderImpl decoder = getDecoder();
            ReadableBuffer buffer = decoder.getBuffer();
            int size = decoder.readRawInt();
            buffer.position(buffer.position() + size);
        }

        public void setValue(Map!(Object,Object) value, int length)
        {
            _value = value;
            _length = length;
        }

        override
        void writeConstructor()
        {
            super.writeConstructor();
        }

        override int getConstructorSize()
        {
            return super.getConstructorSize();
        }


    }

    class ShortMapEncoding
    : SmallFloatingSizePrimitiveTypeEncoding!(Map!(Object,Object))
    , MapEncoding
    {
        private Map!(Object,Object) _value;
        private int _length;

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected void writeEncodedValue(Map!(Object,Object) map)
        {
            getEncoder().getBuffer().ensureRemaining(getSizeBytes() + getEncodedValueSize(map));
            getEncoder().writeRaw(cast(byte)(2 * map.size()));

            // Iterator<Map.Entry> iter = map.entrySet().iterator();

            IAMQPType IfixedKeyType = this.outer.fixedKeyType;

            // Clear existing fixed key type encoding to prevent application to nested Maps
            setKeyEncoding(null);

            try
            {
                foreach (MapEntry!(Object, Object) element ; map)
                {
                    ITypeEncoding elementEncoding;
                    if (IfixedKeyType is null)
                    {
                        IAMQPType tmp = _encoder.getType( element.getKey());
                        if (tmp is null)
                        {
                            logError( "getType error");
                        }
                        elementEncoding = tmp.getEncoding( element.getKey());
                    }
                    else
                    {
                        elementEncoding = IfixedKeyType.getEncoding( element.getKey());
                    }

                    elementEncoding.writeConstructor();
                    elementEncoding.writeValue( element.getKey());

                    elementEncoding = getEncoder().getType( element.getValue()).getEncoding( element.getValue());
                    elementEncoding.writeConstructor();
                    elementEncoding.writeValue( element.getValue());
                }

            } finally
            {
                setKeyEncoding(IfixedKeyType);
            }
            //try {
            //    while (iter.hasNext())
            //    {
            //        Map.Entry<?, ?> element = iter.next();
            //        TypeEncoding elementEncoding;
            //
            //        if (fixedKeyType is null)
            //        {
            //            elementEncoding = _encoder.getType(element.getKey()).getEncoding(element.getKey());
            //        }
            //        else
            //        {
            //            elementEncoding = fixedKeyType.getEncoding(element.getKey());
            //        }
            //
            //        elementEncoding.writeConstructor();
            //        elementEncoding.writeValue(element.getKey());
            //        elementEncoding = getEncoder().getType(element.getValue()).getEncoding(element.getValue());
            //        elementEncoding.writeConstructor();
            //        elementEncoding.writeValue(element.getValue());
            //    }
            //} finally {
            //    // Reset Existing key type encoding for later encode step or reuse until cleared by caller
            //    setKeyEncoding(fixedKeyType);
            //}
        }

        override
        protected int getEncodedValueSize(Map!(Object,Object) val)
        {
            return 1 + ((val == _value) ? _length : calculateSize(val));
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.MAP8;
        }

        override
        public ObjectMapType getType()
        {
            return this.outer;
        }

        override
        public bool encodesSuperset(TypeEncoding!(Map!(Object,Object)) encoder)
        {
            return encoder == this;
        }

        override
        public Object readValue()
        {
            DecoderImpl decoder = getDecoder();
            ReadableBuffer buffer = decoder.getBuffer();

            int size = (decoder.readRawByte()) & 0xff;
            // todo - limit the decoder with size
            int count = (decoder.readRawByte()) & 0xff;

            ITypeConstructor keyConstructor = null;
            ITypeConstructor valueConstructor = null;

            Map!(Object, Object) map = new LinkedHashMap!(Object, Object)(count);
            for(int i = 0; i < count / 2; i++)
            {
                keyConstructor = findNextDecoder(decoder, buffer, keyConstructor);
                if(keyConstructor is null)
                {
                    logError("Unknown constructor");
                    return null;
                    // throw new DecodeException("Unknown constructor");
                }

                Object key = keyConstructor.readValue();

                bool arrayType = false;
                byte code = buffer.get(buffer.position());
                switch (code)
                {
                    case EncodingCodes.ARRAY8:
                    goto case;
                    case EncodingCodes.ARRAY32:
                    arrayType = true;
                    break;
                    default:
                    break;
                }

                valueConstructor = findNextDecoder(decoder, buffer, valueConstructor);
                if(valueConstructor is null)
                {
                    //throw new DecodeException("Unknown constructor");
                    logError("Unknown constructor");
                    return null;
                }

                Object value;

                //if (arrayType)
                //{
                //    value = ((ArrayType.ArrayEncoding) valueConstructor).readValueArray();
                //}
                //else
                {
                    value  = valueConstructor.readValue();
                }

                map.put(key, value);
            }

            return cast(Object)map;
        }

        override
        public void skipValue()
        {
            DecoderImpl decoder = getDecoder();
            ReadableBuffer buffer = decoder.getBuffer();
            int size = (cast(int)decoder.readRawByte()) & 0xff;
            buffer.position(buffer.position() + size);
        }

        public void setValue(Map!(Object,Object) value, int length)
        {
            _value = value;
            _length = length;
        }

        override
        void writeConstructor()
        {
            super.writeConstructor();
        }

        override int getConstructorSize()
        {
            return super.getConstructorSize();
        }
    }
}
