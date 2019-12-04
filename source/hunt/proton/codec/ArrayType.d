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

module hunt.proton.codec.ArrayType;

/*
import java.lang.reflect.Array;
import java.util.Arrays;
import hunt.collection.Collection;

class ArrayType implements PrimitiveType!(Object[])
{
    private EncoderImpl _encoder;
    private BooleanType _boolType;
    private ByteType _byteType;
    private ShortType _shortType;
    private IntegerType _integerType;
    private LongType _longType;
    private FloatType _floatType;
    private DoubleType _doubleType;
    private CharacterType _characterType;

    public static interface ArrayEncoding : PrimitiveTypeEncoding!(Object[])
    {
        void writeValue(bool[] a);
        void writeValue(byte[] a);
        void writeValue(short[] a);
        void writeValue(int[] a);
        void writeValue(long[] a);
        void writeValue(float[] a);
        void writeValue(double[] a);
        void writeValue(char[] a);

        void setValue(Object[] val, TypeEncoding<?> encoder, int size);

        int getSizeBytes();

        Object readValueArray();
    }

    private ArrayEncoding _shortArrayEncoding;
    private ArrayEncoding _arrayEncoding;

    public ArrayType(EncoderImpl encoder,
                     DecoderImpl decoder, BooleanType boolType,
                     ByteType byteType,
                     ShortType shortType,
                     IntegerType intType,
                     LongType longType,
                     FloatType floatType,
                     DoubleType doubleType,
                     CharacterType characterType)
    {
        _encoder = encoder;
        _boolType = boolType;
        _byteType = byteType;
        _shortType = shortType;
        _integerType = intType;
        _longType = longType;
        _floatType = floatType;
        _doubleType = doubleType;
        _characterType = characterType;

        _arrayEncoding = new AllArrayEncoding(encoder, decoder);
        _shortArrayEncoding = new ShortArrayEncoding(encoder, decoder);

        encoder.register(Object[].class, this);
        decoder.register(this);
    }

    override
    public Class!(Object[]) getTypeClass()
    {
        return Object[].class;
    }

    override
    public ArrayEncoding getEncoding(Object[] val)
    {
        TypeEncoding<?> encoder = calculateEncoder(val,_encoder);
        int size = calculateSize(val, encoder);
        ArrayEncoding arrayEncoding = (val.length > 255 || size > 254)
                                      ? _arrayEncoding
                                      : _shortArrayEncoding;
        arrayEncoding.setValue(val, encoder, size);
        return arrayEncoding;
    }

    private static TypeEncoding<?> calculateEncoder(Object[] val, EncoderImpl encoder)
    {
        if(val.length == 0)
        {
            AMQPType underlyingType = encoder.getTypeFromClass(val.getClass().getComponentType());
            return underlyingType.getCanonicalEncoding();
        }
        else
        {
            AMQPType underlyingType = encoder.getTypeFromClass(val.getClass().getComponentType());
            bool checkTypes = false;

            if(val[0].getClass().isArray() && val[0].getClass().getComponentType().isPrimitive())
            {
                Class componentType = val[0].getClass().getComponentType();
                if(componentType == Boolean.TYPE)
                {
                    return ((ArrayType)underlyingType).getEncoding((bool[])val[0]);
                }
                else if(componentType == Byte.TYPE)
                {
                    return ((ArrayType)underlyingType).getEncoding((byte[])val[0]);
                }
                else if(componentType == Short.TYPE)
                {
                    return ((ArrayType)underlyingType).getEncoding((short[])val[0]);
                }
                else if(componentType == Integer.TYPE)
                {
                    return ((ArrayType)underlyingType).getEncoding((int[])val[0]);
                }
                else if(componentType == Long.TYPE)
                {
                    return ((ArrayType)underlyingType).getEncoding((long[])val[0]);
                }
                else if(componentType == Float.TYPE)
                {
                    return ((ArrayType)underlyingType).getEncoding((float[])val[0]);
                }
                else if(componentType == Double.TYPE)
                {
                    return ((ArrayType)underlyingType).getEncoding((double[])val[0]);
                }
                else if(componentType == Character.TYPE)
                {
                    return ((ArrayType)underlyingType).getEncoding((char[])val[0]);
                }
                else
                {
                    throw new IllegalArgumentException("Cannot encode arrays of type " ~ componentType.getName());
                }
            }
            else
            {
                if(underlyingType is null)
                {
                    checkTypes = true;
                    underlyingType = encoder.getType(val[0]);
                }
                TypeEncoding underlyingEncoding = underlyingType.getEncoding(val[0]);
                TypeEncoding canonicalEncoding = underlyingType.getCanonicalEncoding();

                for(int i = 0; i < val.length && (checkTypes || underlyingEncoding != canonicalEncoding); i++)
                {
                    if(checkTypes && encoder.getType(val[i]) != underlyingType)
                    {
                        throw new IllegalArgumentException("Non matching types " ~ underlyingType ~ " and " ~ encoder
                                .getType(val[i]) ~ " in array");
                    }

                    TypeEncoding elementEncoding = underlyingType.getEncoding(val[i]);
                    if(elementEncoding != underlyingEncoding && !underlyingEncoding.encodesSuperset(elementEncoding))
                    {
                        if(elementEncoding.encodesSuperset(underlyingEncoding))
                        {
                            underlyingEncoding = elementEncoding;
                        }
                        else
                        {
                            underlyingEncoding = canonicalEncoding;
                        }
                    }

                }

                return underlyingEncoding;
            }
        }
    }

    private static int calculateSize(Object[] val, TypeEncoding encoder)
    {
        int size = encoder.getConstructorSize();
        if(encoder.isFixedSizeVal())
        {
            size += val.length * encoder.getValueSize(null);
        }
        else
        {
            for(Object o : val)
            {
                if(o.getClass().isArray() && o.getClass().getComponentType().isPrimitive())
                {
                    ArrayEncoding arrayEncoding = (ArrayEncoding) encoder;
                    ArrayType arrayType = (ArrayType) arrayEncoding.getType();

                    Class componentType = o.getClass().getComponentType();

                    size += 2 * arrayEncoding.getSizeBytes();

                    TypeEncoding componentEncoding;
                    int componentCount;

                    if(componentType == Boolean.TYPE)
                    {
                        bool[] componentArray = (bool[]) o;
                        componentEncoding = arrayType.getUnderlyingEncoding(componentArray);
                        componentCount = componentArray.length;
                    }
                    else if(componentType == Byte.TYPE)
                    {
                        byte[] componentArray = (byte[]) o;
                        componentEncoding = arrayType.getUnderlyingEncoding(componentArray);
                        componentCount = componentArray.length;
                    }
                    else if(componentType == Short.TYPE)
                    {
                        short[] componentArray = (short[]) o;
                        componentEncoding = arrayType.getUnderlyingEncoding(componentArray);
                        componentCount = componentArray.length;
                    }
                    else if(componentType == Integer.TYPE)
                    {
                        int[] componentArray = (int[]) o;
                        componentEncoding = arrayType.getUnderlyingEncoding(componentArray);
                        componentCount = componentArray.length;
                    }
                    else if(componentType == Long.TYPE)
                    {
                        long[] componentArray = (long[]) o;
                        componentEncoding = arrayType.getUnderlyingEncoding(componentArray);
                        componentCount = componentArray.length;
                    }
                    else if(componentType == Float.TYPE)
                    {
                        float[] componentArray = (float[]) o;
                        componentEncoding = arrayType.getUnderlyingEncoding(componentArray);
                        componentCount = componentArray.length;
                    }
                    else if(componentType == Double.TYPE)
                    {
                        double[] componentArray = (double[]) o;
                        componentEncoding = arrayType.getUnderlyingEncoding(componentArray);
                        componentCount = componentArray.length;
                    }
                    else if(componentType == Character.TYPE)
                    {
                        char[] componentArray = (char[]) o;
                        componentEncoding = arrayType.getUnderlyingEncoding(componentArray);
                        componentCount = componentArray.length;
                    }
                    else
                    {
                        throw new IllegalArgumentException("Cannot encode arrays of type " ~ componentType.getName());
                    }

                    size +=  componentEncoding.getConstructorSize()
                                + componentEncoding.getValueSize(null) * componentCount;
                }
                else
                {
                    size += encoder.getValueSize(o);
                }
            }
        }

        return size;
    }

    override
    public ArrayEncoding getCanonicalEncoding()
    {
        return _arrayEncoding;
    }

    override
    public Collection!(ArrayEncoding) getAllEncodings()
    {
        return Arrays.asList(_shortArrayEncoding, _arrayEncoding);
    }

    override
    public void write(Object[] val)
    {
        ArrayEncoding encoding = getEncoding(val);
        encoding.writeConstructor();
        encoding.writeValue(val);
    }

    public void write(bool[] a)
    {
        ArrayEncoding encoding = getEncoding(a);
        encoding.writeConstructor();
        encoding.writeValue(a);
    }

    private ArrayEncoding getEncoding(bool[] a)
    {
        return a.length < 254 || a.length <= 255 && allSameValue(a) ? _shortArrayEncoding : _arrayEncoding;
    }

    private bool allSameValue(bool[] a)
    {
        bool val = a[0];
        for(int i = 1; i < a.length; i++)
        {
            if(val != a[i])
            {
                return false;
            }
        }
        return true;
    }

    public void write(byte[] a)
    {
        ArrayEncoding encoding = getEncoding(a);
        encoding.writeConstructor();
        encoding.writeValue(a);
    }

    private ArrayEncoding getEncoding(byte[] a)
    {
        return a.length < 254 ? _shortArrayEncoding : _arrayEncoding;
    }

    public void write(short[] a)
    {
        ArrayEncoding encoding = getEncoding(a);
        encoding.writeConstructor();
        encoding.writeValue(a);
    }

    private ArrayEncoding getEncoding(short[] a)
    {
        return a.length < 127 ? _shortArrayEncoding : _arrayEncoding;
    }

    public void write(int[] a)
    {
        ArrayEncoding encoding = getEncoding(a);
        encoding.writeConstructor();
        encoding.writeValue(a);
    }

    private ArrayEncoding getEncoding(int[] a)
    {
        return a.length < 63 || (a.length < 254 && allSmallInts(a)) ? _shortArrayEncoding : _arrayEncoding;
    }

    private bool allSmallInts(int[] a)
    {
        for(int i = 0; i < a.length; i++)
        {
            if(a[i] < -128 || a[i] > 127)
            {
                return false;
            }
        }
        return true;
    }

    public void write(long[] a)
    {
        ArrayEncoding encoding = getEncoding(a);
        encoding.writeConstructor();
        encoding.writeValue(a);
    }

    private ArrayEncoding getEncoding(long[] a)
    {
        return a.length < 31 || (a.length < 254 && allSmallLongs(a)) ? _shortArrayEncoding : _arrayEncoding;
    }

    private bool allSmallLongs(long[] a)
    {
        for(int i = 0; i < a.length; i++)
        {
            if(a[i] < -128L || a[i] > 127L)
            {
                return false;
            }
        }
        return true;
    }

    public void write(float[] a)
    {
        ArrayEncoding encoding = getEncoding(a);
        encoding.writeConstructor();
        encoding.writeValue(a);
    }

    private ArrayEncoding getEncoding(float[] a)
    {
        return a.length < 63 ? _shortArrayEncoding : _arrayEncoding;
    }

    public void write(double[] a)
    {
        ArrayEncoding encoding = getEncoding(a);
        encoding.writeConstructor();
        encoding.writeValue(a);
    }

    private ArrayEncoding getEncoding(double[] a)
    {
        return a.length < 31 ? _shortArrayEncoding : _arrayEncoding;
    }

    public void write(char[] a)
    {
        ArrayEncoding encoding = getEncoding(a);
        encoding.writeConstructor();
        encoding.writeValue(a);
    }

    private ArrayEncoding getEncoding(char[] a)
    {
        return a.length < 63 ? _shortArrayEncoding : _arrayEncoding;
    }

    private class AllArrayEncoding
            : LargeFloatingSizePrimitiveTypeEncoding!(Object[])
            implements ArrayEncoding
    {
        private Object[] _val;
        private TypeEncoding _underlyingEncoder;
        private int _size;

        AllArrayEncoding(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected void writeSize(Object[] val)
        {
            int encodedValueSize = getEncodedValueSize(val);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw(encodedValueSize);
        }

        override
        public void writeValue(bool[] a)
        {
            BooleanType.BooleanEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 4 + underlyingEncoder.getConstructorSize() +
                                   a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw(encodedValueSize);
            getEncoder().writeRaw(a.length);
            underlyingEncoder.writeConstructor();
            for(bool b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void writeValue(byte[] a)
        {
            ByteType.ByteEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 4 + underlyingEncoder.getConstructorSize() +
                                   a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw(encodedValueSize);
            getEncoder().writeRaw(a.length);
            underlyingEncoder.writeConstructor();
            for(byte b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void writeValue(short[] a)
        {
            ShortType.ShortEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 4 + underlyingEncoder.getConstructorSize() +
                                   a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw(encodedValueSize);
            getEncoder().writeRaw(a.length);
            underlyingEncoder.writeConstructor();
            for(short b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void writeValue(int[] a)
        {
            IntegerType.IntegerEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 4 + underlyingEncoder.getConstructorSize() +
                                   a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw(encodedValueSize);
            getEncoder().writeRaw(a.length);
            underlyingEncoder.writeConstructor();
            for(int b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void writeValue(long[] a)
        {
            LongType.LongEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 4 + underlyingEncoder.getConstructorSize() +
                                   a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw(encodedValueSize);
            getEncoder().writeRaw(a.length);
            underlyingEncoder.writeConstructor();
            for(long b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void writeValue(float[] a)
        {
            FloatType.FloatEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 4 + underlyingEncoder.getConstructorSize() +
                                   a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw(encodedValueSize);
            getEncoder().writeRaw(a.length);
            underlyingEncoder.writeConstructor();
            for(float b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void writeValue(double[] a)
        {
            DoubleType.DoubleEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 4 + underlyingEncoder.getConstructorSize() +
                                   a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw(encodedValueSize);
            getEncoder().writeRaw(a.length);
            underlyingEncoder.writeConstructor();
            for(double b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void writeValue(char[] a)
        {
            CharacterType.CharacterEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 4 + underlyingEncoder.getConstructorSize() +
                                   a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw(encodedValueSize);
            getEncoder().writeRaw(a.length);
            underlyingEncoder.writeConstructor();
            for(char b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void setValue(Object[] val, TypeEncoding encoder, int size)
        {
            _val = val;
            _underlyingEncoder = encoder;
            _size = size;
        }

        override
        protected void writeEncodedValue(Object[] val)
        {
            TypeEncoding underlyingEncoder;

            if(_val != val)
            {
                _val = val;
                _underlyingEncoder = underlyingEncoder = calculateEncoder(val, getEncoder());
                _size =  calculateSize(val, underlyingEncoder);
            }
            else
            {
                underlyingEncoder = _underlyingEncoder;
            }
            getEncoder().writeRaw(val.length);
            underlyingEncoder.writeConstructor();
            for(Object o : val)
            {
                underlyingEncoder.writeValue(o);
            }
        }

        override
        protected int getEncodedValueSize(Object[] val)
        {
            if(_val != val)
            {
                _val = val;
                _underlyingEncoder = calculateEncoder(val, getEncoder());
                _size = calculateSize(val, _underlyingEncoder);
            }
            return 4 + _size;
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.ARRAY32;
        }

        override
        public ArrayType getType()
        {
            return ArrayType.this;
        }

        override
        public bool encodesSuperset(TypeEncoding!(Object[]) encoding)
        {
            return getType() == encoding.getType();
        }

        override
        public Object[] readValue()
        {
            DecoderImpl decoder = getDecoder();
            int size = decoder.readRawInt();
            int count = decoder.readRawInt();
            return decodeArray(decoder, count);
        }

        override
        public Object readValueArray()
        {
            DecoderImpl decoder = getDecoder();
            int size = decoder.readRawInt();
            int count = decoder.readRawInt();
            return decodeArrayAsObject(decoder, count);
        }

        override
        public void skipValue()
        {
            DecoderImpl decoder = getDecoder();
            ReadableBuffer buffer = decoder.getBuffer();
            int size = decoder.readRawInt();
            buffer.position(buffer.position() + size);
        }
    }

    private class ShortArrayEncoding
            : SmallFloatingSizePrimitiveTypeEncoding!(Object[])
            implements ArrayEncoding
    {
        private Object[] _val;
        private TypeEncoding _underlyingEncoder;
        private int _size;

        ShortArrayEncoding(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected void writeSize(Object[] val)
        {
            int encodedValueSize = getEncodedValueSize(val);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw((byte) encodedValueSize);
        }

        override
        public void writeValue(bool[] a)
        {
            BooleanType.BooleanEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 1 + underlyingEncoder.getConstructorSize() +
                                    a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw((byte)encodedValueSize);
            getEncoder().writeRaw((byte)a.length);
            underlyingEncoder.writeConstructor();
            for(bool b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void writeValue(byte[] a)
        {
            ByteType.ByteEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 1 + underlyingEncoder.getConstructorSize() +
                                    a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw((byte)encodedValueSize);
            getEncoder().writeRaw((byte)a.length);
            underlyingEncoder.writeConstructor();
            for(byte b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void writeValue(short[] a)
        {
            ShortType.ShortEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 1 + underlyingEncoder.getConstructorSize() +
                                    a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw((byte)encodedValueSize);
            getEncoder().writeRaw((byte)a.length);
            underlyingEncoder.writeConstructor();
            for(short b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void writeValue(int[] a)
        {
            IntegerType.IntegerEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 1 + underlyingEncoder.getConstructorSize() +
                                    a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw((byte)encodedValueSize);
            getEncoder().writeRaw((byte)a.length);
            underlyingEncoder.writeConstructor();
            for(int b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void writeValue(long[] a)
        {
            LongType.LongEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 1 + underlyingEncoder.getConstructorSize() +
                                    a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw((byte)encodedValueSize);
            getEncoder().writeRaw((byte)a.length);
            underlyingEncoder.writeConstructor();
            for(long b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void writeValue(float[] a)
        {
            FloatType.FloatEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 1 + underlyingEncoder.getConstructorSize() +
                                    a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw((byte)encodedValueSize);
            getEncoder().writeRaw((byte)a.length);
            underlyingEncoder.writeConstructor();
            for(float b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void writeValue(double[] a)
        {
            DoubleType.DoubleEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 1 + underlyingEncoder.getConstructorSize() +
                                    a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw((byte)encodedValueSize);
            getEncoder().writeRaw((byte)a.length);
            underlyingEncoder.writeConstructor();
            for(double b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void writeValue(char[] a)
        {
            CharacterType.CharacterEncoding underlyingEncoder = getUnderlyingEncoding(a);
            int encodedValueSize = 1 + underlyingEncoder.getConstructorSize() +
                                    a.length * underlyingEncoder.getValueSize(null);
            getEncoder().getBuffer().ensureRemaining(encodedValueSize);
            getEncoder().writeRaw((byte)encodedValueSize);
            getEncoder().writeRaw((byte)a.length);
            underlyingEncoder.writeConstructor();
            for(char b : a)
            {
                underlyingEncoder.writeValue(b);
            }
        }

        override
        public void setValue(Object[] val, TypeEncoding encoder, int size)
        {
            _val = val;
            _underlyingEncoder = encoder;
            _size = size;
        }

        override
        protected void writeEncodedValue(Object[] val)
        {
            TypeEncoding underlyingEncoder;

            if(_val != val)
            {
                _val = val;
                _underlyingEncoder = underlyingEncoder = calculateEncoder(val, getEncoder());
                _size =  calculateSize(val, underlyingEncoder);
            }
            else
            {
                underlyingEncoder = _underlyingEncoder;
            }
            getEncoder().writeRaw((byte)val.length);
            underlyingEncoder.writeConstructor();
            for(Object o : val)
            {
                if(o.getClass().isArray() && o.getClass().getComponentType().isPrimitive())
                {
                    ArrayEncoding arrayEncoding = (ArrayEncoding) underlyingEncoder;
                    ArrayType arrayType = (ArrayType) arrayEncoding.getType();

                    Class componentType = o.getClass().getComponentType();

                    if(componentType == Boolean.TYPE)
                    {
                        bool[] componentArray = (bool[]) o;
                        arrayEncoding.writeValue(componentArray);
                    }
                    else if(componentType == Byte.TYPE)
                    {
                        byte[] componentArray = (byte[]) o;
                        arrayEncoding.writeValue(componentArray);
                    }
                    else if(componentType == Short.TYPE)
                    {
                        short[] componentArray = (short[]) o;
                        arrayEncoding.writeValue(componentArray);
                    }
                    else if(componentType == Integer.TYPE)
                    {
                        int[] componentArray = (int[]) o;
                        arrayEncoding.writeValue(componentArray);
                    }
                    else if(componentType == Long.TYPE)
                    {
                        long[] componentArray = (long[]) o;
                        arrayEncoding.writeValue(componentArray);
                    }
                    else if(componentType == Float.TYPE)
                    {
                        float[] componentArray = (float[]) o;
                        arrayEncoding.writeValue(componentArray);
                    }
                    else if(componentType == Double.TYPE)
                    {
                        double[] componentArray = (double[]) o;
                        arrayEncoding.writeValue(componentArray);
                    }
                    else if(componentType == Character.TYPE)
                    {
                        char[] componentArray = (char[]) o;
                        arrayEncoding.writeValue(componentArray);
                    }
                    else
                    {
                        throw new IllegalArgumentException("Cannot encode arrays of type " ~ componentType.getName());
                    }
                }
                else
                {
                    underlyingEncoder.writeValue(o);
                }
            }
        }

        override
        protected int getEncodedValueSize(Object[] val)
        {
            if(_val != val)
            {
                _val = val;
                _underlyingEncoder = calculateEncoder(val, getEncoder());
                _size = calculateSize(val, _underlyingEncoder);
            }
            return 1 + _size;
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.ARRAY8;
        }

        override
        public ArrayType getType()
        {
            return ArrayType.this;
        }

        override
        public bool encodesSuperset(TypeEncoding!(Object[]) encoding)
        {
            return getType() == encoding.getType();
        }

        override
        public Object[] readValue()
        {
            DecoderImpl decoder = getDecoder();
            int size = ((int)decoder.readRawByte()) & 0xFF;
            int count = ((int)decoder.readRawByte()) & 0xFF;
            return decodeArray(decoder, count);
        }

        override
        public Object readValueArray()
        {
            DecoderImpl decoder = getDecoder();
            int size = ((int)decoder.readRawByte()) & 0xFF;
            int count = ((int)decoder.readRawByte()) & 0xFF;
            return decodeArrayAsObject(decoder, count);
        }

        override
        public void skipValue()
        {
            DecoderImpl decoder = getDecoder();
            ReadableBuffer buffer = decoder.getBuffer();
            int size = ((int)decoder.readRawByte()) & 0xFF;
            buffer.position(buffer.position() + size);
        }
    }

    private BooleanType.BooleanEncoding getUnderlyingEncoding(bool[] a)
    {
        if(a.length == 0)
        {
            return _boolType.getCanonicalEncoding();
        }
        else
        {
            bool val = a[0];
            for(int i = 1; i < a.length; i++)
            {
                if(val != a[i])
                {
                    return _boolType.getCanonicalEncoding();
                }
            }
            return _boolType.getEncoding(val);
        }
    }

    private ByteType.ByteEncoding getUnderlyingEncoding(byte[] a)
    {
        return _byteType.getCanonicalEncoding();
    }

    private ShortType.ShortEncoding getUnderlyingEncoding(short[] a)
    {
        return _shortType.getCanonicalEncoding();
    }

    private IntegerType.IntegerEncoding getUnderlyingEncoding(int[] a)
    {
        if(a.length == 0 || !allSmallInts(a))
        {
            return _integerType.getCanonicalEncoding();
        }
        else
        {
            return _integerType.getEncoding(a[0]);
        }
    }

    private LongType.LongEncoding getUnderlyingEncoding(long[] a)
    {
        if(a.length == 0 || !allSmallLongs(a))
        {
            return _longType.getCanonicalEncoding();
        }
        else
        {
            return _longType.getEncoding(a[0]);
        }
    }

    private FloatType.FloatEncoding getUnderlyingEncoding(float[] a)
    {
        return _floatType.getCanonicalEncoding();
    }

    private DoubleType.DoubleEncoding getUnderlyingEncoding(double[] a)
    {
        return _doubleType.getCanonicalEncoding();
    }

    private CharacterType.CharacterEncoding getUnderlyingEncoding(char[] a)
    {
        return _characterType.getCanonicalEncoding();
    }

    private static Object[] decodeArray(DecoderImpl decoder, int count)
    {
        TypeConstructor constructor = decoder.readConstructor(true);
        return decodeNonPrimitive(decoder, constructor, count);
    }

    private static Object[] decodeNonPrimitive(DecoderImpl decoder,
                                               TypeConstructor constructor,
                                               int count)
    {
        if (count > decoder.getByteBufferRemaining()) {
            throw new IllegalArgumentException("Array element count "+count+" is specified to be greater than the amount of data available ("+
                                               decoder.getByteBufferRemaining()+")");
        }

        if(constructor instanceof ArrayEncoding)
        {
            ArrayEncoding arrayEncoding = (ArrayEncoding) constructor;

            Object[] array = new Object[count];
            for(int i = 0; i < count; i++)
            {
                array[i] = arrayEncoding.readValueArray();
            }

            return array;
        }
        else
        {
            Object[] array = (Object[]) Array.newInstance(constructor.getTypeClass(), count);

            for(int i = 0; i < count; i++)
            {
                array[i] = constructor.readValue();
            }

            return array;
        }
    }

    private static Object decodeArrayAsObject(DecoderImpl decoder, int count)
    {
        TypeConstructor constructor = decoder.readConstructor(true);
        if(constructor.encodesJavaPrimitive())
        {
            if (count > decoder.getByteBufferRemaining()) {
                throw new IllegalArgumentException("Array element count "+count+" is specified to be greater than the amount of data available ("+
                                                   decoder.getByteBufferRemaining()+")");
            }

            if(constructor instanceof BooleanType.BooleanEncoding)
            {
                return decodeBooleanArray((BooleanType.BooleanEncoding) constructor, count);
            }
            else if(constructor instanceof ByteType.ByteEncoding)
            {
                return decodeByteArray((ByteType.ByteEncoding)constructor, count);
            }
            else if(constructor instanceof ShortType.ShortEncoding)
            {
                return decodeShortArray((ShortType.ShortEncoding)constructor, count);
            }
            else if(constructor instanceof IntegerType.IntegerEncoding)
            {
                return decodeIntArray((IntegerType.IntegerEncoding)constructor, count);
            }
            else if(constructor instanceof LongType.LongEncoding)
            {
                return decodeLongArray((LongType.LongEncoding) constructor, count);
            }
            else if(constructor instanceof FloatType.FloatEncoding)
            {
                return decodeFloatArray((FloatType.FloatEncoding) constructor, count);
            }
            else if(constructor instanceof DoubleType.DoubleEncoding)
            {
                return decodeDoubleArray((DoubleType.DoubleEncoding)constructor, count);
            }
            else if(constructor instanceof CharacterType.CharacterEncoding)
            {
                return decodeCharArray((CharacterType.CharacterEncoding)constructor, count);
            }
            else
            {
                throw new ClassCastException("Unexpected class " ~ constructor.getClass().getName());
            }
        }
        else
        {
            return decodeNonPrimitive(decoder, constructor, count);
        }
    }

    private static bool[] decodeBooleanArray(BooleanType.BooleanEncoding constructor, int count)
    {
        bool[] array = new bool[count];

        for(int i = 0; i < count; i++)
        {
            array[i] = constructor.readPrimitiveValue();
        }

        return array;
    }

    private static byte[] decodeByteArray(ByteType.ByteEncoding constructor , int count)
    {
        byte[] array = new byte[count];

        for(int i = 0; i < count; i++)
        {
            array[i] = constructor.readPrimitiveValue();
        }

        return array;
    }

    private static short[] decodeShortArray(ShortType.ShortEncoding constructor, int count)
    {
        short[] array = new short[count];

        for(int i = 0; i < count; i++)
        {
            array[i] = constructor.readPrimitiveValue();
        }

        return array;
    }

    private static int[] decodeIntArray(IntegerType.IntegerEncoding constructor, int count)
    {
        int[] array = new int[count];

        for(int i = 0; i < count; i++)
        {
            array[i] = constructor.readPrimitiveValue();
        }

        return array;
    }

    private static long[] decodeLongArray(LongType.LongEncoding constructor, int count)
    {
        long[] array = new long[count];

        for(int i = 0; i < count; i++)
        {
            array[i] = constructor.readPrimitiveValue();
        }

        return array;
    }

    private static float[] decodeFloatArray(FloatType.FloatEncoding constructor, int count)
    {
        float[] array = new float[count];

        for(int i = 0; i < count; i++)
        {
            array[i] = constructor.readPrimitiveValue();
        }

        return array;
    }

    private static double[] decodeDoubleArray(DoubleType.DoubleEncoding constructor, int count)
    {
        double[] array = new double[count];

        for(int i = 0; i < count; i++)
        {
            array[i] = constructor.readPrimitiveValue();
        }

        return array;
    }

    private static char[] decodeCharArray(CharacterType.CharacterEncoding constructor, int count)
    {
        char[] array = new char[count];

        for(int i = 0; i < count; i++)
        {
            array[i] = constructor.readPrimitiveValue();
        }

        return array;
    }
}

*/