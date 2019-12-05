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

module hunt.proton.codec.ListType;

import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.collection.List;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.proton.codec.LargeFloatingSizePrimitiveTypeEncoding;
import hunt.Exceptions;
import  hunt.proton.codec.AMQPType;
import hunt.proton.codec.TypeEncoding;
import hunt.collection.ArrayList;
import hunt.proton.codec.TypeConstructor;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.SmallFloatingSizePrimitiveTypeEncoding;
import hunt.proton.codec.FixedSizePrimitiveTypeEncoding;
import hunt.logging;
import std.conv : to;
import hunt.proton.codec.NullType;
import hunt.proton.codec.BooleanType;
import hunt.proton.codec.ByteType;
import hunt.proton.codec.ShortType;
import hunt.proton.codec.IntegerType;
import hunt.proton.codec.LongType;
import hunt.proton.codec.FloatType;
import hunt.proton.codec.DoubleType;
import hunt.proton.codec.CharacterType;

import hunt.Boolean;
import hunt.Short;
import hunt.Integer;
import hunt.Long;
import hunt.Float;
import hunt.Double;

interface ListEncoding : PrimitiveTypeEncoding!(List!Object)
{
   void setValue(List!Object value, int length);
   Object readValueArray();
}

class ListType : AbstractPrimitiveType!(List!Object)
{
    private ListEncoding _listEncoding;
    private ListEncoding _shortListEncoding;
    private ListEncoding _zeroListEncoding;
    private EncoderImpl _encoder;



    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _encoder = encoder;
        _listEncoding = new AllListEncoding(encoder, decoder);
        _shortListEncoding = new ShortListEncoding(encoder, decoder);
        _zeroListEncoding = new ZeroListEncoding(encoder, decoder);
        encoder.register(typeid(List!Object),this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(List!Object);
    }

    public ITypeEncoding getEncoding(Object v)
    {
        List!Object val = cast(List!Object)v;
        int calculatedSize = calculateSize(val, _encoder);
        ListEncoding encoding = val.isEmpty()
                                    ? _zeroListEncoding
                                    : (val.size() > 255 || calculatedSize >= 254)
                                        ? _listEncoding
                                        : _shortListEncoding;

        encoding.setValue(val, calculatedSize);
        return encoding;
    }

   // public static TypeInfo
  private static List!Object decodeBooleanArray(BooleanEncoding constructor,  int count)
  {
   // boolean[] array = new boolean[count];
     List!Object array = new ArrayList!Object;
    for(int i = 0; i < count; i++)
    {
      array.add(new Boolean(constructor.readPrimitiveValue()));
    }

    return array;
  }

  private static List!Object decodeByteArray(ByteType.ByteEncoding constructor ,  int count)
  {
    List!Object array = new ArrayList!Object;

    for(int i = 0; i < count; i++)
    {
      array.add(constructor.readPrimitiveValue());
    }

    return array;
  }

  private static  List!Object decodeShortArray(ShortType.ShortEncoding constructor,  int count)
  {
    List!Object array = new ArrayList!Object;

    for(int i = 0; i < count; i++)
    {
      array.add(new Short(constructor.readPrimitiveValue()));
    }

    return array;
  }

  private static List!Object decodeIntArray(IntegerType.IntegerEncoding constructor,  int count)
  {
    List!Object array = new ArrayList!Object;

    for(int i = 0; i < count; i++)
    {
      array.add (new Integer(constructor.readPrimitiveValue()));
    }

    return array;
  }

  private static List!Object decodeLongArray(LongType.LongEncoding constructor,  int count)
  {
    List!Object array = new ArrayList!Object;

    for(int i = 0; i < count; i++)
    {
      array.add (new Long(constructor.readPrimitiveValue()));
    }

    return array;
  }

  private static List!Object decodeFloatArray(FloatType.FloatEncoding constructor,  int count)
  {
    List!Object array = new ArrayList!Object;
    for(int i = 0; i < count; i++)
    {
      array.add(new Float(constructor.readPrimitiveValue()));
    }

    return array;
  }

  private static List!Object decodeDoubleArray(DoubleType.DoubleEncoding constructor,  int count)
  {
    List!Object array = new ArrayList!Object;

    for(int i = 0; i < count; i++)
    {
      array.add(new Double(constructor.readPrimitiveValue()));
    }

    return array;
  }

  private static List!Object decodeCharArray(CharacterType.CharacterEncoding constructor,  int count)
  {
    List!Object array = new ArrayList!Object;

    for(int i = 0; i < count; i++)
    {
      array.add(constructor.readPrimitiveValue());
    }

    return array;
  }


   private static Object decodeArrayAsObject(DecoderImpl decoder,  int count)
    {
        ITypeConstructor constructor = decoder.readConstructor(true);
        if(constructor.encodesJavaPrimitive())
        {
            if (count > decoder.getByteBufferRemaining()) {
              throw new IllegalArgumentException("Array element count error");
            }

            if( cast(BooleanEncoding)constructor !is null )
            {
                return cast(Object)( decodeBooleanArray(cast(BooleanEncoding) constructor, count));
            }
            else if( cast(ByteType.ByteEncoding)constructor !is null )
            {
                return cast(Object) (decodeByteArray(cast(ByteType.ByteEncoding)constructor, count));
            }
            else if( cast(ShortType.ShortEncoding) constructor !is null)
            {
                return cast(Object)( decodeShortArray(cast(ShortType.ShortEncoding)constructor, count));
            }
            else if(cast(IntegerType.IntegerEncoding) constructor !is null)
            {
                return cast(Object)(decodeIntArray(cast(IntegerType.IntegerEncoding)constructor, count));
            }
            else if( cast(LongType.LongEncoding)constructor !is null)
            {
                return cast (Object) (decodeLongArray(cast(LongType.LongEncoding) constructor, count));
            }
            else if(cast (FloatType.FloatEncoding) constructor !is null)
            {
                return  cast(Object)( decodeFloatArray(cast(FloatType.FloatEncoding) constructor, count));
            }
            else if( cast(DoubleType.DoubleEncoding)constructor !is null)
            {
                return cast(Object)( decodeDoubleArray(cast(DoubleType.DoubleEncoding)constructor, count));
            }
            else if( cast (CharacterType.CharacterEncoding) constructor !is null)
            {
                return cast(Object) (decodeCharArray(cast(CharacterType.CharacterEncoding)constructor, count));
            }
            else
            {
                throw new ClassCastException("Unexpected class ");
            }
        }
        else
        {
            return cast(Object) (decodeNonPrimitive(decoder, constructor, count));
        }
    }


   private static List!Object decodeNonPrimitive(DecoderImpl decoder,ITypeConstructor constructor, int count)
    {
        if (count > decoder.getByteBufferRemaining()) {
          throw new IllegalArgumentException("Array element count " ~ to!string(count) ~" is specified to be greater than the amount of data available (" ~
          to!string(decoder.getByteBufferRemaining()) ~")");
        }

        if( cast(ShortListEncoding)constructor !is null)
        {
            ShortListEncoding arrayEncoding = cast (ShortListEncoding) constructor;

           // Object[] array = new Object[count];
            List!Object ob = new ArrayList!Object;
            for(int i = 0; i < count; i++)
            {
              ob.add(arrayEncoding.readValueArray());
            }

            return ob;
        }
        else if ( cast(AllListEncoding)constructor !is null)
        {
          AllListEncoding arrayEncoding = cast (AllListEncoding) constructor;

         // Object[] array = new Object[count];
          List!Object ob = new ArrayList!Object;
          for(int i = 0; i < count; i++)
          {
            ob.add(arrayEncoding.readValueArray());
          }

          return ob;
        }
        else
        {
           // Object[] array = (Object[]) Array.newInstance(constructor.getTypeClass(), count);

            List!Object array = new ArrayList!Object;
            for(int i = 0; i < count; i++)
            {
              array.add(constructor.readValue());
            }

            return array;
        }
    }


    private static int calculateSize(List!Object val, EncoderImpl encoder)
    {
        int len = 0;
        int count = val.size();
        version(HUNT_DEBUG)
        {
          logInfo("^^^^^^^ count : %d ^^^^ " , count );
        }
        for(int i = 0; i < count; i++)
        {
            Object element = val.get(i);
            //logInfo("^^^^^^^ i : %d ^^^^ " , i );
            //if (element !is null)
            //{
            //    logInfo("^^^^^^^  %s ^^^^ " ,  typeid(element).toString );
            //}
            IAMQPType type = encoder.getType(element);
            //if (cast( NullType)type !is null)
            //{
            //    logInfo("null!!!!!!!!!!!!!!!!!!!!!!");
            //}
            if(type is null)
            {
                logError("!!!!!!logError!!!!!!!!!!!!!!!!");
              //  throw new IllegalArgumentException("No encoding defined for type: ");
            }
            ITypeEncoding elementEncoding = type.getEncoding(element);

            //NullEncoding n = cast(NullEncoding)elementEncoding;
            //if (n !is null)
            //{
            //    logInfo("n!!!!!!!!!!!!!!!!!!!!!!");
            //}

            len += elementEncoding.getConstructorSize()+elementEncoding.getValueSize(element);
        }
        return len;
    }

    public ListEncoding getCanonicalEncoding()
    {
        return _listEncoding;
    }

    public Collection!(TypeEncoding!(List!Object)) getAllEncodings()
    {
        List!(TypeEncoding!(List!Object))  lst = new ArrayList!(TypeEncoding!(List!Object));
        lst.add(_zeroListEncoding);
        lst.add(_shortListEncoding);
        lst.add(_listEncoding);
        return lst;
    }

    class AllListEncoding
            : LargeFloatingSizePrimitiveTypeEncoding!(List!Object)
            , ListEncoding
    {

        private List!Object _value;
        private int _length;

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected void writeEncodedValue(List!Object val)
        {
            getEncoder().getBuffer().ensureRemaining(getSizeBytes() + getEncodedValueSize(val));
            getEncoder().writeRaw(val.size());

            int count = val.size();

            for(int i = 0; i < count; i++)
            {
                Object element = val.get(i);
                ITypeEncoding elementEncoding = getEncoder().getType(element).getEncoding(element);
                elementEncoding.writeConstructor();
                elementEncoding.writeValue(element);
            }
        }

        override
        protected int getEncodedValueSize(List!Object val)
        {
            return 4 + ((val == _value) ? _length : calculateSize(val, getEncoder()));
        }


        override
        public byte getEncodingCode()
        {
            return EncodingCodes.LIST32;
        }

      public Object readValueArray()
      {
        DecoderImpl decoder = getDecoder();
        int size = (cast(int)decoder.readRawByte()) & 0xFF;
        int count = (cast(int)decoder.readRawByte()) & 0xFF;
        return decodeArrayAsObject(decoder, count);
      }

        override
        public ListType getType()
        {
            return this.outer;
        }

        override
        public bool encodesSuperset(TypeEncoding!(List!Object) encoding)
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
            // Ensure we do not allocate an array of size greater then the available data, otherwise there is a risk for an OOM error
            if (count > decoder.getByteBufferRemaining()) {
                throw new IllegalArgumentException("List element count " ~ to!string(count) ~" is specified to be greater than the amount of data available (" ~
                                                   to!string(decoder.getByteBufferRemaining()) ~")");
            }

            ITypeConstructor  typeConstructor = null;

            List!(Object) list = new ArrayList!(Object)(count);
            for (int i = 0; i < count; i++)
            {
                bool arrayType = false;
                byte encodingCode = buffer.get(buffer.position());
                switch (encodingCode)
                {
                    case EncodingCodes.ARRAY8:
                         goto case;
                    case EncodingCodes.ARRAY32:
                        arrayType = true;
                        break;
                    default:
                        break;
                }

                // Whenever we can just reuse the previously used TypeDecoder instead
                // of spending time looking up the same one again.
                if (typeConstructor is null)
                {
                    typeConstructor = getDecoder().readConstructor();
                }
                else
                {
                    if (encodingCode == EncodingCodes.DESCRIBED_TYPE_INDICATOR )
                    {
                        typeConstructor = getDecoder().readConstructor();
                    }
                    else
                    {
                        IPrimitiveTypeEncoding primitiveConstructor = cast(IPrimitiveTypeEncoding) typeConstructor;
                        if (encodingCode != primitiveConstructor.getEncodingCode())
                        {
                            typeConstructor = getDecoder().readConstructor();
                        }
                        else
                        {
                            // consume the encoding code byte for real
                            encodingCode = buffer.get();
                        }
                    }
                }

                if(typeConstructor is null)
                {
                   // throw new DecodeException("Unknown constructor");
                    logError("Unknown constructor");
                }

                Object value;

                if (arrayType)
                {
                    value = (cast (ListEncoding)typeConstructor).readValueArray();
                }
                else
                {
                    value = typeConstructor.readValue();
                }

                list.add(value);
            }

            return cast(Object)list;
        }

        override
        public void skipValue()
        {
            DecoderImpl decoder = getDecoder();
            ReadableBuffer buffer = decoder.getBuffer();
            int size = decoder.readRawInt();
            buffer.position(buffer.position() + size);
        }

        override
        public void setValue(List!Object value, int length)
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

    class ShortListEncoding
            : SmallFloatingSizePrimitiveTypeEncoding!(List!Object)
            , ListEncoding
    {

        private List!Object _value;
        private int _length;

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected void writeEncodedValue(List!Object val)
        {
            getEncoder().getBuffer().ensureRemaining(getSizeBytes() + getEncodedValueSize(val));
            getEncoder().writeRaw(cast(byte)val.size());

            int count = val.size();

            for(int i = 0; i < count; i++)
            {
                Object element = val.get(i);
                ITypeEncoding elementEncoding = getEncoder().getType(element).getEncoding(element);
                elementEncoding.writeConstructor();
                elementEncoding.writeValue(element);
            }
        }

        override
        protected int getEncodedValueSize(List!Object val)
        {
            return 1 + ((val == _value) ? _length : calculateSize(val, getEncoder()));
        }


        override
        public byte getEncodingCode()
        {
            return EncodingCodes.LIST8;
        }

        override
        public ListType getType()
        {
            return this.outer;
        }

        override
        public bool encodesSuperset(TypeEncoding!(List!Object) encoder)
        {
            return encoder == this;
        }


     public Object readValueArray()
     {
          DecoderImpl decoder = getDecoder();
          int size = (cast(int)decoder.readRawByte()) & 0xFF;
          int count = (cast(int)decoder.readRawByte()) & 0xFF;
          return decodeArrayAsObject(decoder, count);
     }


        override
        public Object readValue()
        {
            DecoderImpl decoder = getDecoder();
            ReadableBuffer buffer = decoder.getBuffer();

            int size = (cast(int)decoder.readRawByte()) & 0xff;
            // todo - limit the decoder with size
            int count = (cast(int)decoder.readRawByte()) & 0xff;

            ITypeConstructor typeConstructor = null;

            List!(Object) list = new ArrayList!Object(count);
            for (int i = 0; i < count; i++)
            {
                bool arrayType = false;
                byte encodingCode = buffer.get(buffer.position());
                switch (encodingCode)
                {
                    case EncodingCodes.ARRAY8:
                         goto case;
                    case EncodingCodes.ARRAY32:
                        arrayType = true;
                        break;
                    default:
                        break;
                }

                // Whenever we can just reuse the previously used TypeDecoder instead
                // of spending time looking up the same one again.
                if (typeConstructor is null)
                {
                    typeConstructor = getDecoder().readConstructor();
                }
                else
                {
                    //|| !(typeConstructor instanceof PrimitiveTypeEncoding<?>))
                    if (encodingCode == EncodingCodes.DESCRIBED_TYPE_INDICATOR || (cast(IPrimitiveTypeEncoding)typeConstructor is null))
                    {
                        typeConstructor = getDecoder().readConstructor();
                    }
                    else
                    {
                        IPrimitiveTypeEncoding primitiveConstructor = cast(IPrimitiveTypeEncoding) typeConstructor;
                        if (encodingCode != primitiveConstructor.getEncodingCode())
                        {
                            typeConstructor = getDecoder().readConstructor();
                        }
                        else
                        {
                            // consume the encoding code byte for real
                            encodingCode = buffer.get();
                        }
                    }
                }

                if (typeConstructor is null)
                {
                    logError("Unknown constructor");
                  //  throw new DecodeException("Unknown constructor");
                }

                Object value;

                if (arrayType)
                {
                    value = (cast(ListEncoding) typeConstructor).readValueArray();
                }
                else
                {
                    value = typeConstructor.readValue();
                }

                list.add(value);
            }

            return cast(Object)list;
        }

        override
        public void skipValue()
        {
            DecoderImpl decoder = getDecoder();
            ReadableBuffer buffer = decoder.getBuffer();
            int size = (cast(int)decoder.readRawByte()) & 0xff;
            buffer.position(buffer.position() + size);
        }

        override
        public void setValue(List!Object value, int length)
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


    class ZeroListEncoding
            : FixedSizePrimitiveTypeEncoding!(List!Object)
            , ListEncoding
    {
        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.LIST0;
        }

        override
        protected int getFixedSize()
        {
            return 0;
        }

        override
        public ListType getType()
        {
           return this.outer;
        }


      Object readValueArray(){
          return null;
      }

        override
        public void setValue(List!Object value, int length)
        {
        }

        override
        public void writeValue(Object val)
        {
        }

        override
        public bool encodesSuperset(TypeEncoding!(List!Object) encoder)
        {
            return encoder == this;
        }

        override
        public Object readValue()
        {
            return new ArrayList!Object;
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
