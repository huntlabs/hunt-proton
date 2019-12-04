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

module hunt.proton.codec.DecoderImpl;

import hunt.collection.ByteBuffer;
import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.time.LocalDateTime;
import hunt.collection.HashMap;
import hunt.collection.List;
import hunt.collection.Map;
import std.uuid;

import hunt.proton.codec.PrimitiveType;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.TypeConstructor;
import hunt.proton.amqp.messaging.Section;
import hunt.proton.codec.FastPathDescribedTypeConstructor;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.ByteBufferDecoder;
import hunt.Exceptions;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Decimal128;
import hunt.proton.amqp.Decimal32;
import hunt.proton.amqp.Decimal64;
import hunt.proton.amqp.DescribedType;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedByte;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.UnsignedShort;
import hunt.proton.codec.DynamicTypeConstructor;
import hunt.proton.codec.AMQPType;
import hunt.proton.codec.TypeEncoding;

import hunt.logging;
import hunt.Boolean;
import hunt.Short;
import hunt.Byte;
import hunt.Integer;
import hunt.Long;
import hunt.Char;
import hunt.Float;
import hunt.Double;
import hunt.String;


alias Date = LocalDateTime;


class DecoderImpl : ByteBufferDecoder
{
    private ReadableBuffer _buffer;

   // private CharsetDecoder _charsetDecoder = StandardCharsets.UTF_8.newDecoder();

    private IPrimitiveTypeEncoding[] _constructors ;//= new IPrimitiveTypeEncoding[256];
    //private Map!(Object, DescribedTypeConstructor) _dynamicTypeConstructors =
    //        new HashMap!(Object, DescribedTypeConstructor)();

    //private Map!(Object, Object) _dynamicTypeConstructors =
    //new HashMap!(Object, Object)();


    private Map!(UnsignedLong,Object) _dynamicTypeConstructors_ul ;//= new HashMap!(UnsignedLong,Object);
    private Map!(Symbol,Object) _dynamicTypeConstructors_sy  ;//= new HashMap!(Symbol,Object);


    private Map!(UnsignedLong, Object) _fastPathTypeConstructors_ul;
    private Map!(Symbol, Object) _fastPathTypeConstructors_sy;

    //private Map!(Object, FastPathDescribedTypeConstructor!Section) _fastPathTypeConstructors =
    //    new HashMap!(Object, FastPathDescribedTypeConstructor!Section)();

    this()
    {
        _constructors = new IPrimitiveTypeEncoding[256];

        _dynamicTypeConstructors_ul = new HashMap!(UnsignedLong,Object);
        _dynamicTypeConstructors_sy = new HashMap!(Symbol,Object);

        _fastPathTypeConstructors_ul = new HashMap!(UnsignedLong,Object);
        _fastPathTypeConstructors_sy  = new HashMap!(Symbol,Object);
    }

    this(ByteBuffer buffer)
    {
        _buffer = new ByteBufferReader(buffer);
        _constructors = new IPrimitiveTypeEncoding[256];

        _dynamicTypeConstructors_ul = new HashMap!(UnsignedLong,Object);
        _dynamicTypeConstructors_sy = new HashMap!(Symbol,Object);

        _fastPathTypeConstructors_ul = new HashMap!(UnsignedLong,Object);
        _fastPathTypeConstructors_sy  = new HashMap!(Symbol,Object);

    }

    //public TypeConstructor<?> peekConstructor()
    //{
    //    _buffer.mark();
    //    try
    //    {
    //        return readConstructor();
    //    }
    //    finally
    //    {
    //        _buffer.reset();
    //    }
    //}

    public ITypeConstructor readConstructor()
    {
        return readConstructor(false);
    }

    public ITypeConstructor readConstructor(bool excludeFastPathConstructors)
    {
        //implementationMissing(false);
        //return null;
        int code = (cast(int)readRawByte()) & 0xff;
        if(code == EncodingCodes.DESCRIBED_TYPE_INDICATOR)
        {
            byte encoding = _buffer.get(_buffer.position());
            Object descriptor;

            int flag = 0;

            if (EncodingCodes.SMALLULONG == encoding || EncodingCodes.ULONG == encoding)
            {
                descriptor = readUnsignedLong(null);
                UnsignedLong dd = cast(UnsignedLong)descriptor;
             //   logInfo("descriptor:%d",dd.intValue());
                flag = 0;
            }
            else if (EncodingCodes.SYM8 == encoding || EncodingCodes.SYM32 == encoding)
            {
                descriptor = readSymbol(null);
                flag = 1;
            }
            else
            {
                descriptor = readObject();
            }

            if (!excludeFastPathConstructors)
            {
                Object fastPathTypeConstructor;
                if (flag == 0)
                {
                    UnsignedLong ul = cast(UnsignedLong)descriptor;
                    fastPathTypeConstructor = _fastPathTypeConstructors_ul.get(ul);


                } else
                {
                    Symbol sy = cast(Symbol)descriptor;
                    fastPathTypeConstructor = _fastPathTypeConstructors_sy.get(sy);
                }
                if (fastPathTypeConstructor !is null)
                {
                    return cast(ITypeConstructor)fastPathTypeConstructor;
                }
            }

            ITypeConstructor nestedEncoding = readConstructor(false);


            Object dtc ;

            if (flag == 0 )
            {
               dtc =  _dynamicTypeConstructors_ul.get(cast(UnsignedLong)descriptor);
            }else
            {
                dtc =  _dynamicTypeConstructors_sy.get(cast(Symbol)descriptor);
            }

            if(dtc is null)
            {
                dtc = new class DescribedTypeConstructor!UnknownDescribedType
                {
                    public UnknownDescribedType newInstance(Object described)
                    {
                        return new UnknownDescribedType(descriptor, described);
                    }

                    public TypeInfo getTypeClass()
                    {
                        return typeid(UnknownDescribedType);
                    }
                };
                registerDynamic(descriptor, dtc);
            }
            return new DynamicTypeConstructor(cast(IDescribedTypeConstructor)dtc, nestedEncoding);
        }
        else
        {
            return cast(ITypeConstructor)(_constructors[code]);
        }
    }

    override
    public void registerFastPath(Object descriptor, Object btc)
    {
        UnsignedLong ul = cast(UnsignedLong)descriptor;
        if (ul !is null)
        {
            _fastPathTypeConstructors_ul.put(ul, btc);
            return;
        }

        Symbol sy = cast(Symbol)descriptor;
        if(sy !is null)
        {
            _fastPathTypeConstructors_sy.put(sy,btc);
        }
       // _fastPathTypeConstructors.put(descriptor, btc);
    }

    override
    public void registerDynamic(Object descriptor, Object dtc)
    {
        // Allow external type constructors to replace the built-in instances.
        UnsignedLong ul = cast(UnsignedLong)descriptor;
        if (ul !is null)
        {
            _fastPathTypeConstructors_ul.remove(ul);
            _dynamicTypeConstructors_ul.put(ul,dtc);
            return;
        }
        Symbol sy = cast(Symbol)descriptor;
        if(sy !is null)
        {
            _fastPathTypeConstructors_sy.remove(sy);
            _dynamicTypeConstructors_sy.put(sy,dtc);
        }
    }

    //private ClassCastException unexpectedType(Object val, Class clazz)
    //{
    //    return new ClassCastException("Unexpected type "
    //                                  + val.getClass().getName()
    //                                  ~ ". Expected "
    //                                  + clazz.getName() +".");
    //}

    public Boolean readBoolean()
    {
        return readBoolean(null);
    }

    public Boolean readBoolean(Boolean defaultVal)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.BOOLEAN_TRUE:
                return Boolean.TRUE;
            case EncodingCodes.BOOLEAN_FALSE:
                return Boolean.FALSE;
            case EncodingCodes.BOOLEAN:
                return readRawByte() == 0 ? Boolean.FALSE : Boolean.TRUE;
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected bool type but found encoding");
                return null;
            }

               // throw new DecodeException("Expected bool type but found encoding: " ~ encodingCode);
        }
    }

    public bool readBoolean(bool defaultVal)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.BOOLEAN_TRUE:
                return true;
            case EncodingCodes.BOOLEAN_FALSE:
                return false;
            case EncodingCodes.BOOLEAN:
                return readRawByte() != 0;
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected bool type but found encoding");
                return false;
            }
              //  throw new DecodeException("Expected bool type but found encoding: " ~ encodingCode);
        }
    }

    public Byte readByte()
    {
        return readByte(null);
    }

    public Byte readByte(Byte defaultVal)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode) {
            case EncodingCodes.BYTE:
                return new Byte(readRawByte());
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected byte type but found encoding");
                return null;
            }
               // throw new DecodeException("Expected byte type but found encoding: " ~ encodingCode);
        }
    }

    public byte readByte(byte defaultVal)
    {

        implementationMissing(false);
        return defaultVal;
        //TypeConstructor<?> constructor = readConstructor();
        //if(constructor instanceof ByteType.ByteEncoding)
        //{
        //    return ((ByteType.ByteEncoding)constructor).readPrimitiveValue();
        //}
        //else
        //{
        //    Object val = constructor.readValue();
        //    if(val is null)
        //    {
        //        return defaultVal;
        //    }
        //    else
        //    {
        //        throw unexpectedType(val, Byte.class);
        //    }
        //}
    }

    public Short readShort()
    {
        return readShort(null);
    }

    public Short readShort(Short defaultVal)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.SHORT:
                return new Short(readRawShort());
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected Short type but found encoding:");
                return null;
            }
                //throw new DecodeException("Expected Short type but found encoding: " ~ encodingCode);
        }
    }

    public short readShort(short defaultVal)
    {
        implementationMissing(false);
        return defaultVal;
        //TypeConstructor<?> constructor = readConstructor();
        //if(constructor instanceof ShortType.ShortEncoding)
        //{
        //    return ((ShortType.ShortEncoding)constructor).readPrimitiveValue();
        //}
        //else
        //{
        //    Object val = constructor.readValue();
        //    if(val is null)
        //    {
        //        return defaultVal;
        //    }
        //    else
        //    {
        //        throw unexpectedType(val, Short.class);
        //    }
        //}
    }

    public Integer readInteger()
    {
        return readInteger(null);
    }

    public Integer readInteger(Integer defaultVal)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.SMALLINT:
                return Integer.valueOf(readRawByte());
            case EncodingCodes.INT:
                return Integer.valueOf(readRawInt());
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected Integer type but found encoding:");
                return null;
            }
              //  throw new DecodeException("Expected Integer type but found encoding: " ~ encodingCode);
        }
    }

    public int readInteger(int defaultVal)
    {
        implementationMissing(false);
        //TypeConstructor<?> constructor = readConstructor();
        //if(constructor instanceof IntegerType.IntegerEncoding)
        //{
        //    return ((IntegerType.IntegerEncoding)constructor).readPrimitiveValue();
        //}
        //else
        //{
        //    Object val = constructor.readValue();
        //    if(val is null)
        //    {
        //        return defaultVal;
        //    }
        //    else
        //    {
        //        throw unexpectedType(val, Integer.class);
        //    }
        //}
        return 0;
    }

    public Long readLong()
    {
        return readLong(null);
    }

    public Long readLong(Long defaultVal)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.SMALLLONG:
                return Long.valueOf(readRawByte());
            case EncodingCodes.LONG:
                return Long.valueOf(readRawLong());
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected Long type but found encoding");
                return null;
            }
               // throw new DecodeException("Expected Long type but found encoding: " ~ encodingCode);
        }
    }

    public long readLong(long defaultVal)
    {
        implementationMissing(false);
        //TypeConstructor<?> constructor = readConstructor();
        //if(constructor instanceof LongType.LongEncoding)
        //{
        //    return ((LongType.LongEncoding)constructor).readPrimitiveValue();
        //}
        //else
        //{
        //    Object val = constructor.readValue();
        //    if(val is null)
        //    {
        //        return defaultVal;
        //    }
        //    else
        //    {
        //        throw unexpectedType(val, Long.class);
        //    }
        //}
        return 0;
    }

    public UnsignedByte readUnsignedByte()
    {
        return readUnsignedByte(null);
    }

    public UnsignedByte readUnsignedByte(UnsignedByte defaultVal)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.UBYTE:
                return UnsignedByte.valueOf(readRawByte());
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected unsigned byte type but found encoding");
                return null;
            }
               // throw new DecodeException("Expected unsigned byte type but found encoding: " ~ encodingCode);
        }
    }


    public UnsignedShort readUnsignedShort()
    {
        return readUnsignedShort(null);
    }

    public UnsignedShort readUnsignedShort(UnsignedShort defaultVal)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.USHORT:
                return UnsignedShort.valueOf(readRawShort());
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected UnsignedShort type but found encoding:");
                return null;
            }
               // throw new DecodeException("Expected UnsignedShort type but found encoding: " ~ encodingCode);
        }
    }

    public UnsignedInteger readUnsignedInteger()
    {
        return readUnsignedInteger(null);
    }

    public UnsignedInteger readUnsignedInteger(UnsignedInteger defaultVal)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.UINT0:
                return UnsignedInteger.ZERO;
            case EncodingCodes.SMALLUINT:
                return UnsignedInteger.valueOf((cast(int) readRawByte()) & 0xff);
            case EncodingCodes.UINT:
                return UnsignedInteger.valueOf(readRawInt());
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected UnsignedInteger type but found encoding");
                return null;
            }
                //throw new DecodeException("Expected UnsignedInteger type but found encoding: " ~ encodingCode);
        }
    }

    public UnsignedLong readUnsignedLong()
    {
        return readUnsignedLong(null);
    }

    public UnsignedLong readUnsignedLong(UnsignedLong defaultVal)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.ULONG0:
                return UnsignedLong.ZERO;
            case EncodingCodes.SMALLULONG:
                return UnsignedLong.valueOf((cast(long) readRawByte())&0xff);
            case EncodingCodes.ULONG:
                return UnsignedLong.valueOf(readRawLong());
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected UnsignedLong type but found encoding");
                return null;
            }
               // throw new DecodeException("Expected UnsignedLong type but found encoding: " ~ encodingCode);
        }
    }

    public Char readCharacter()
    {
        return readCharacter(null);
    }

    public Char readCharacter(Char defaultVal)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.CHAR:
                return Char.valueOf(cast(char) (readRawInt() & 0xffff));
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected Character type but found encoding");
                return null;
            }
                //throw new DecodeException("Expected Character type but found encoding: " ~ encodingCode);
        }
    }

    public char readCharacter(char defaultVal)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.CHAR:
                return cast(char) (readRawInt() & 0xffff);
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected Character type but found encoding");
                return defaultVal;
            }
               // throw new DecodeException("Expected Character type but found encoding: " ~ encodingCode);
        }
    }


    public Float readFloat()
    {
        return readFloat(null);
    }


    public Float readFloat(Float defaultVal)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.FLOAT:
                return Float.valueOf(readRawFloat());
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected Float type but found encoding:");
                return null;
            }
              //  throw new ProtonException("Expected Float type but found encoding: " ~ encodingCode);
        }
    }


    public float readFloat(float defaultVal)
    {
        implementationMissing(false);
        return defaultVal;
        //TypeConstructor<?> constructor = readConstructor();
        //if(constructor instanceof FloatType.FloatEncoding)
        //{
        //    return ((FloatType.FloatEncoding)constructor).readPrimitiveValue();
        //}
        //else
        //{
        //    Object val = constructor.readValue();
        //    if(val is null)
        //    {
        //        return defaultVal;
        //    }
        //    else
        //    {
        //        throw unexpectedType(val, Float.class);
        //    }
        //}
    }


    public Double readDouble()
    {
        return readDouble(null);
    }


    public Double readDouble(Double defaultVal)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.DOUBLE:
                return Double.valueOf(readRawDouble());
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected Double type but found encoding");
                return null;
            }
             //   throw new ProtonException("Expected Double type but found encoding: " ~ encodingCode);
        }
    }


    public double readDouble(double defaultVal)
    {


        implementationMissing(false);
        return defaultVal;
        //TypeConstructor<?> constructor = readConstructor();
        //if(constructor instanceof DoubleType.DoubleEncoding)
        //{
        //    return ((DoubleType.DoubleEncoding)constructor).readPrimitiveValue();
        //}
        //else
        //{
        //    Object val = constructor.readValue();
        //    if(val is null)
        //    {
        //        return defaultVal;
        //    }
        //    else
        //    {
        //        throw unexpectedType(val, Double.class);
        //    }
        //}
    }


    public UUID readUUID()
    {
       // return readUUID(null);
        UUID id;
        return id;
    }


    public UUID readUUID(UUID defaultVal)
    {
        implementationMissing(false);
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.UUID:
                //return  UUID(readRawLong(), readRawLong());
                return defaultVal;
            case EncodingCodes.NULL:
                return defaultVal;
            default:
            {
                logError("Expected UUID type but found encoding");
                return defaultVal;
            }
                //throw new ProtonException("Expected UUID type but found encoding: " ~ encodingCode);
        }
    }


    public Decimal32 readDecimal32()
    {
        return readDecimal32(null);
    }


    public Decimal32 readDecimal32(Decimal32 defaultValue)
    {
        implementationMissing(false);
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.DECIMAL32:
               // return cast(Decimal32) _constructors[EncodingCodes.DECIMAL32 & 0xff].readValue();
            return defaultValue;
            case EncodingCodes.NULL:
                return defaultValue;
            default:
            {
                logError("Expected Decimal32 type but found encoding");
                return null;
            }
              //  throw new ProtonException("Expected Decimal32 type but found encoding: " ~ encodingCode);
        }
    }


    public Decimal64 readDecimal64()
    {
        return readDecimal64(null);
    }


    public Decimal64 readDecimal64(Decimal64 defaultValue)
    {
        implementationMissing(false);
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.DECIMAL64:
                //return cast(Decimal64) _constructors[EncodingCodes.DECIMAL64 & 0xff].readValue();
            return defaultValue;
            case EncodingCodes.NULL:
                return defaultValue;
            default:
            {
                logError("Expected Decimal64 type but found encoding");
                return null;
            }
               // throw new ProtonException("Expected Decimal64 type but found encoding: " ~ encodingCode);
        }
    }


    public Decimal128 readDecimal128()
    {
        return readDecimal128(null);
    }


    public Decimal128 readDecimal128(Decimal128 defaultValue)
    {
        implementationMissing(false);
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.DECIMAL128:
              //  return cast(Decimal128) _constructors[EncodingCodes.DECIMAL128 & 0xff].readValue();
            return defaultValue;
            case EncodingCodes.NULL:
                return defaultValue;
            default:
            {
                logError("Expected Decimal128 type but found encoding");
                return null;
            }
                //throw new ProtonException("Expected Decimal128 type but found encoding: " ~ encodingCode);
        }
    }


    public Date readTimestamp()
    {
        return readTimestamp(null);
    }


    public Date readTimestamp(Date defaultValue)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.TIMESTAMP:
                return  Date.ofEpochMilli(readRawLong());
            case EncodingCodes.NULL:
                return defaultValue;
            default:
            {
                logError("Expected Timestamp type but found encoding");
                return null;
            }
               // throw new ProtonException("Expected Timestamp type but found encoding: " ~ encodingCode);
        }
    }


    public Binary readBinary()
    {
        return readBinary(null);
    }


    public Binary readBinary(Binary defaultValue)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.VBIN8:
                return cast(Binary)((cast(TypeConstructor!Binary) _constructors[EncodingCodes.VBIN8 & 0xff]).readValue());
                //return defaultValue;
            case EncodingCodes.VBIN32:
                return cast(Binary)((cast(TypeConstructor!Binary) _constructors[EncodingCodes.VBIN32 & 0xff]).readValue());
               // return defaultValue;
            case EncodingCodes.NULL:
                return defaultValue;
            default:
            {
                logError("Expected Binary type but found encoding");
                return null;
            }
                //throw new ProtonException("Expected Binary type but found encoding: " ~ encodingCode);
        }
    }


    public Symbol readSymbol()
    {
        return readSymbol(null);
    }


    public Symbol readSymbol(Symbol defaultValue)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.SYM8:
                return cast(Symbol)((cast(TypeConstructor!Symbol) (_constructors[EncodingCodes.SYM8 & 0xff])).readValue());
                //return defaultValue;
            case EncodingCodes.SYM32:
                return  cast(Symbol)((cast(TypeConstructor!Symbol) (_constructors[EncodingCodes.SYM32 & 0xff])).readValue());
                //return defaultValue;
            case EncodingCodes.NULL:
                return defaultValue;
            default:
            {
                logError("Expected Symbol type but found encoding");
                return null;
            }
               // throw new ProtonException("Expected Symbol type but found encoding: " ~ encodingCode);
        }
    }


    public String readString()
    {
        return readString(null);
    }


    public String readString(String defaultValue)
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.STR8:
                return cast(String)((cast(TypeConstructor!String) _constructors[EncodingCodes.STR8 & 0xff]).readValue());
                //return defaultValue;
            case EncodingCodes.STR32:
                return cast(String)((cast(TypeConstructor!String) _constructors[EncodingCodes.STR32 & 0xff]).readValue());
                //return defaultValue;
            case EncodingCodes.NULL:
                return defaultValue;
            default:
            {
                logError("Expected String type but found encoding");
                return null;
            }
              //  throw new ProtonException("Expected String type but found encoding: " ~ encodingCode);
        }
    }

    //
    //@SuppressWarnings("rawtypes")
    //public List readList()
    //{
    //    byte encodingCode = _buffer.get();
    //
    //    switch (encodingCode)
    //    {
    //        case EncodingCodes.LIST0:
    //            return Collections.EMPTY_LIST;
    //        case EncodingCodes.LIST8:
    //            return cast(List) _constructors[EncodingCodes.LIST8 & 0xff].readValue();
    //        case EncodingCodes.LIST32:
    //            return cast(List) _constructors[EncodingCodes.LIST32 & 0xff].readValue();
    //        case EncodingCodes.NULL:
    //            return null;
    //        default:
    //            throw new ProtonException("Expected List type but found encoding: " ~ encodingCode);
    //    }
    //}
    //
    //
    //public <T> void readList(ListProcessor!(T) processor)
    //{
    //    //TODO.
    //}

    //
    //@SuppressWarnings("rawtypes")
    public Object readMap()
    {
        byte encodingCode = _buffer.get();

        switch (encodingCode)
        {
            case EncodingCodes.MAP8:
                return cast(Object)(cast(ITypeConstructor)(_constructors[EncodingCodes.MAP8 & 0xff])).readValue();
            case EncodingCodes.MAP32:
                return cast(Object)(cast(ITypeConstructor)(_constructors[EncodingCodes.MAP32 & 0xff])).readValue();
            case EncodingCodes.NULL:
                return null;
            default:
            {
                logError("Expected Map type but found encoding");
                return null;
            }
               // throw new ProtonException("Expected Map type but found encoding: " ~ encodingCode);
        }
    }
    //
    //
    //public <T> T[] readArray(Class!(T) clazz)
    //{
    //    return null;  //TODO.
    //}

    //
    //public Object[] readArray()
    //{
    //    return (Object[]) readConstructor().readValue();
    //
    //}

    //
    //public bool[] readBooleanArray()
    //{
    //    return (bool[]) ((ArrayType.ArrayEncoding)readConstructor()).readValueArray();
    //}
    //
    //
    //public byte[] readByteArray()
    //{
    //    return (byte[]) ((ArrayType.ArrayEncoding)readConstructor()).readValueArray();
    //}
    //
    //
    //public short[] readShortArray()
    //{
    //    return (short[]) ((ArrayType.ArrayEncoding)readConstructor()).readValueArray();
    //}
    //
    //
    //public int[] readIntegerArray()
    //{
    //    return (int[]) ((ArrayType.ArrayEncoding)readConstructor()).readValueArray();
    //}
    //
    //
    //public long[] readLongArray()
    //{
    //    return (long[]) ((ArrayType.ArrayEncoding)readConstructor()).readValueArray();
    //}
    //
    //
    //public float[] readFloatArray()
    //{
    //    return (float[]) ((ArrayType.ArrayEncoding)readConstructor()).readValueArray();
    //}
    //
    //
    //public double[] readDoubleArray()
    //{
    //    return (double[]) ((ArrayType.ArrayEncoding)readConstructor()).readValueArray();
    //}
    //
    //
    //public char[] readCharacterArray()
    //{
    //    return (char[]) ((ArrayType.ArrayEncoding)readConstructor()).readValueArray();
    //}
    //
    //
    //public <T> T[] readMultiple(Class!(T) clazz)
    //{
    //    Object val = readObject();
    //    if(val is null)
    //    {
    //        return null;
    //    }
    //    else if(val.getClass().isArray())
    //    {
    //        if(clazz.isAssignableFrom(val.getClass().getComponentType()))
    //        {
    //            return (T[]) val;
    //        }
    //        else
    //        {
    //            throw unexpectedType(val, Array.newInstance(clazz, 0).getClass());
    //        }
    //    }
    //    else if(clazz.isAssignableFrom(val.getClass()))
    //    {
    //        T[] array = (T[]) Array.newInstance(clazz, 1);
    //        array[0] = (T) val;
    //        return array;
    //    }
    //    else
    //    {
    //        throw unexpectedType(val, Array.newInstance(clazz, 0).getClass());
    //    }
    //}
    //
    //
    //public Object[] readMultiple()
    //{
    //    Object val = readObject();
    //    if(val is null)
    //    {
    //        return null;
    //    }
    //    else if(val.getClass().isArray())
    //    {
    //        return (Object[]) val;
    //    }
    //    else
    //    {
    //        Object[] array = (Object[]) Array.newInstance(val.getClass(), 1);
    //        array[0] = val;
    //        return array;
    //    }
    //}
    //
    //
    //public byte[] readByteMultiple()
    //{
    //    return new byte[0];  //TODO.
    //}
    //
    //
    //public short[] readShortMultiple()
    //{
    //    return new short[0];  //TODO.
    //}
    //
    //
    //public int[] readIntegerMultiple()
    //{
    //    return new int[0];  //TODO.
    //}
    //
    //
    //public long[] readLongMultiple()
    //{
    //    return new long[0];  //TODO.
    //}
    //
    //
    //public float[] readFloatMultiple()
    //{
    //    return new float[0];  //TODO.
    //}
    //
    //
    //public double[] readDoubleMultiple()
    //{
    //    return new double[0];  //TODO.
    //}
    //
    //
    //public char[] readCharacterMultiple()
    //{
    //    return new char[0];  //TODO.
    //}


    public Object readObject()
    {
        //implementationMissing(false);
        //return null;
        bool arrayType = false;
        byte code = _buffer.get(_buffer.position());
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

        ITypeConstructor constructor = readConstructor();
        if(constructor is null)
        {
            //throw new DecodeException("Unknown constructor");
            logError("Unknown constructor");
            return null;
        }
        return constructor.readValue();
      //  return constructor.readValue();
        //if (arrayType) {
        //    return ((ArrayType.ArrayEncoding)constructor).readValueArray();
        //} else {
        //    return constructor.readValue();
        //}
    }


    public Object readObject(Object defaultValue)
    {
        Object val = readObject();
        return val is null ? defaultValue : val;
    }

    void register(V)(PrimitiveType!(V) t)
    {
        AMQPType!V type = cast(AMQPType!V)t;
        if (type is null)
        {
            logError("register error");
        }
        //Collection!(PrimitiveTypeEncoding!(V)) encodings = type.getAllEncodings();
        Collection!(TypeEncoding!(V)) encodings = type.getAllEncodings();

        foreach(TypeEncoding!(V) ec ; encodings)
        {
            PrimitiveTypeEncoding!(V) encoding = cast(PrimitiveTypeEncoding!(V))ec;
            if (encoding is null)
            {
                logError("PrimitiveTypeEncoding error");
            }
            if (encoding.getEncodingCode() == EncodingCodes.LIST8)
            {
                _constructors[(cast(int) EncodingCodes.ARRAY8) & 0xFF ] = encoding;
            }
            if (encoding.getEncodingCode() == EncodingCodes.LIST32)
            {
                _constructors[(cast(int) EncodingCodes.ARRAY32) & 0xFF ] = encoding;
            }
            _constructors[(cast(int) encoding.getEncodingCode()) & 0xFF ] = encoding;
        }

    }

    byte readRawByte()
    {
        return _buffer.get();
    }

    int readRawInt()
    {
        return _buffer.getInt();
    }

    long readRawLong()
    {
        return _buffer.getLong();
    }

    short readRawShort()
    {
        return _buffer.getShort();
    }

    float readRawFloat()
    {
        return _buffer.getFloat();
    }

    double readRawDouble()
    {
        return _buffer.getDouble();
    }

    void readRaw(byte[] data, int offset, int length)
    {
        _buffer.get(data, offset, length);
    }

    V readRaw(V)(TypeDecoder!(V) decoder, int size)
    {
        V decode = decoder.decode(this, _buffer.slice().limit(size));
        _buffer.position(_buffer.position()+size);
        return decode;
    }


    public void setByteBuffer(ByteBuffer buffer)
    {
        _buffer = new ByteBufferReader(buffer);
    }

    public ByteBuffer getByteBuffer()
    {
        return _buffer.byteBuffer();
    }

    public void setBuffer(ReadableBuffer buffer)
    {
        _buffer = buffer;
    }

    public ReadableBuffer getBuffer()
    {
        return _buffer;
    }

    //CharsetDecoder getCharsetDecoder()
    //{
    //    return _charsetDecoder;
    //}

    interface TypeDecoder(V)
    {
        V decode(DecoderImpl decoder, ReadableBuffer buf);
    }

    class UnknownDescribedType : DescribedType
    {
        private Object _descriptor;
        private Object _described;

        this(Object descriptor, Object described)
        {
            _descriptor = descriptor;
            _described = described;
        }


        public Object getDescriptor()
        {
            return _descriptor;
        }


        public Object getDescribed()
        {
            return _described;
        }


        //
        //public bool equals(Object obj)
        //{
        //
        //    return obj instanceof DescribedType
        //           && _descriptor is null ? ((DescribedType) obj).getDescriptor() is null
        //                                 : _descriptor.equals(((DescribedType) obj).getDescriptor())
        //           && _described is null ?  ((DescribedType) obj).getDescribed() is null
        //                                 : _described.equals(((DescribedType) obj).getDescribed());
        //
        //}

    }


    public int getByteBufferRemaining() {
        return _buffer.remaining();
    }
}
