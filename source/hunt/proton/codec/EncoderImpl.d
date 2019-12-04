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

module hunt.proton.codec.EncoderImpl;

import hunt.proton.codec.AMQPType;
import hunt.proton.codec.DecoderImpl;
import hunt.collection.ByteBuffer;
import hunt.time.LocalDateTime;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.Exceptions;
import hunt.String;

import std.uuid;
import hunt.logging;
import hunt.proton.codec.ByteBufferEncoder;
import hunt.proton.codec.WritableBuffer;
import hunt.proton.codec.EncodingCodes;

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
import hunt.collection.HashMap;
import hunt.collection.ArrayList;

import hunt.proton.codec.NullType;
import hunt.proton.codec.BooleanType;
import hunt.proton.codec.ByteType;
import hunt.proton.codec.UnsignedByteType;
import hunt.proton.codec.IntegerType;
import hunt.proton.codec.ShortType;
import hunt.proton.codec.UnsignedIntegerType;
import hunt.proton.codec.LongType;
import hunt.proton.codec.UnsignedLongType;
import hunt.proton.codec.UnsignedShortType;
import hunt.proton.codec.BigIntegerType;
import hunt.proton.codec.CharacterType;
import hunt.proton.codec.FloatType;
import hunt.proton.codec.DoubleType;
import hunt.proton.codec.TimestampType;
import hunt.proton.codec.UUIDType;
import hunt.proton.codec.Decimal32Type;
import hunt.proton.codec.Decimal64Type;
import hunt.proton.codec.Decimal128Type;
import hunt.proton.codec.BinaryType;
import hunt.proton.codec.SymbolType;
import hunt.proton.codec.StringType;
import hunt.proton.codec.ListType;
import hunt.proton.codec.MapType;
import hunt.proton.codec.ArrayType;
import hunt.proton.codec.BigIntegerType;
import hunt.proton.codec.NullType;
import hunt.proton.codec.SymbolMapType;
import hunt.proton.codec.DynamicDescribedType;
import hunt.proton.codec.ObjectMapType;
import hunt.proton.codec.transport.AttachType;

import hunt.Byte;
import hunt.Short;
import hunt.Long;
import hunt.Integer;
import hunt.Float;
import hunt.Double;
import hunt.Char;
import hunt.Boolean;
import hunt.proton.codec.security.SaslInitType;
import hunt.proton.codec.security.SaslOutcomeType;
import hunt.proton.codec.security.SaslInitType;
import  hunt.proton.codec.messaging.TargetType;
import hunt.proton.codec.messaging.HeaderType;
import hunt.proton.codec.messaging.SourceType;
import hunt.proton.codec.transport.TransferType;
import hunt.proton.codec.transport.DetachType;
import hunt.proton.codec.transport.DispositionType;
import hunt.proton.codec.transaction.DischargeType;
import hunt.proton.codec.transport.ErrorConditionType;
import  hunt.proton.codec.transaction.TransactionalStateType;
import hunt.proton.codec.transport.BeginType;
import hunt.proton.codec.transport.FlowType;
import hunt.proton.codec.messaging.RejectedType;
import hunt.proton.codec.messaging.ModifiedType;
import hunt.proton.codec.transport.OpenType;
import hunt.proton.codec.messaging.ReceivedType;
import hunt.proton.codec.messaging.PropertiesType;
import hunt.Object;


class EncoderImpl : ByteBufferEncoder
{
    private static byte DESCRIBED_TYPE_OP = cast(byte)0;

    private WritableBuffer _buffer;

    private DecoderImpl _decoder;
    private Map!(TypeInfo, IAMQPType) _typeRegistry; // = new HashMap!(TypeInfo, AMQPType!Object)(); IAMQPType
    private Map!(Object, IAMQPType) _describedDescriptorRegistry ;//= new HashMap!(Object, AMQPType!Object)();
    private Map!(TypeInfo, IAMQPType)  _describedTypesClassRegistry;// = new HashMap!(TypeInfo, AMQPType!Object)();

    private NullType              _nullType;
    private BooleanType           _boolType;
    private ByteType              _byteType;
    private UnsignedByteType      _unsignedByteType;
    private ShortType             _shortType;
    private UnsignedShortType     _unsignedShortType;
    private IntegerType           _integerType;
    private UnsignedIntegerType   _unsignedIntegerType;
    private LongType              _longType;
    private UnsignedLongType      _unsignedLongType;
   // private BigIntegerType        _bigIntegerType;

    private CharacterType         _characterType;
    private FloatType             _floatType;
    private DoubleType            _doubleType;
    private TimestampType         _timestampType;
 //   private UUIDType              _uuidType;

    //private Decimal32Type         _decimal32Type;
    //private Decimal64Type         _decimal64Type;
    //private Decimal128Type        _decimal128Type;

    private BinaryType            _binaryType;
    private SymbolType            _symbolType;
    private StringType            _stringType;

    private ListType              _listType;
    private MapType               _mapType;
    private SymbolMapType         _symbolMapType;
    private ObjectMapType         _objectMapType;
 //   private ArrayType             _arrayType;//

    this(DecoderImpl decoder)
    {

        _typeRegistry = new HashMap!(TypeInfo, IAMQPType);
        _describedDescriptorRegistry = new HashMap!(Object, IAMQPType);
        _describedTypesClassRegistry = new HashMap!(TypeInfo, IAMQPType) ;
        _decoder                = decoder;
        _nullType               = new NullType(this, decoder);
        _boolType               = new BooleanType(this, decoder);
        _byteType               = new ByteType(this, decoder);
        _unsignedByteType       = new UnsignedByteType(this, decoder);
        _shortType              = new ShortType(this, decoder);
        _unsignedShortType      = new UnsignedShortType(this, decoder);
        _integerType            = new IntegerType(this, decoder);
        _unsignedIntegerType    = new UnsignedIntegerType(this, decoder);
        _longType               = new LongType(this, decoder);
        _unsignedLongType       = new UnsignedLongType(this, decoder);
       // _bigIntegerType         = new BigIntegerType(this, decoder);

        _characterType          = new CharacterType(this, decoder);
        _floatType              = new FloatType(this, decoder);
        _doubleType             = new DoubleType(this, decoder);
        _timestampType          = new TimestampType(this, decoder);
        //_uuidType               = new UUIDType(this, decoder);
        //
        //_decimal32Type          = new Decimal32Type(this, decoder);
        //_decimal64Type          = new Decimal64Type(this, decoder);
        //_decimal128Type         = new Decimal128Type(this, decoder);


        _binaryType             = new BinaryType(this, decoder);
        _symbolType             = new SymbolType(this, decoder);
        _stringType             = new StringType(this, decoder);

       _listType               = new ListType(this, decoder);
        _mapType                = new MapType(this, decoder);
        _symbolMapType          = new SymbolMapType(this,decoder);
        _objectMapType          = new ObjectMapType(this,decoder);
        //
        //_arrayType              = new ArrayType(this,
        //                                        decoder,
        //                                        _boolType,
        //                                        _byteType,
        //                                        _shortType,
        //                                        _integerType,
        //                                        _longType,
        //                                        _floatType,
        //                                        _doubleType,
        //                                        _characterType);
    }

    override
    public void setByteBuffer(ByteBuffer buf)
    {
        _buffer = new ByteBufferWrapper(buf);
    }

    public void setByteBuffer(WritableBuffer buf)
    {
        _buffer = buf;
    }

    public WritableBuffer getBuffer()
    {
        return _buffer;
    }

    public DecoderImpl getDecoder()
    {
        return _decoder;
    }

    public IAMQPType getType(Object element)
    {
        //return cast(IAMQPType)element;
       return getTypeFromClass((element is null? typeid(Null) : typeid(element)), element);
    }

    public IAMQPType getTypeFromClass(TypeInfo clazz)
    {
        //implementationMissing(false);
        //return null;
        return getTypeFromClass(clazz, null);
    }


    private IAMQPType getTypeFromClass(TypeInfo clazz, Object instance)
    {
        IAMQPType amqpType = _typeRegistry.get(clazz);
       // logInfof("---------------%s",clazz.toString);
        if(amqpType is null)
        {
            amqpType = deduceTypeFromClass(clazz, instance);
        }

        return amqpType;
    }
    //
    private IAMQPType deduceTypeFromClass(TypeInfo clazz, Object instance) {
        IAMQPType amqpType = null;

        //if(clazz.isArray())
        //{
        //    amqpType = _arrayType;
        //}
        //else
        //{
            logInfo("bbbbbb %s",clazz.toString);
            if (typeid(SaslOutcomeWrapper) == clazz)
            {
                amqpType = _listType;
            }
            else if (typeid(SaslInitWrapper) == clazz)//TargetWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(TargetWrapper) == clazz)//HeaderWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(HeaderWrapper) == clazz)//RejectedWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(SourceWrapper) == clazz)//RejectedWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(TransferWrapper) == clazz)//RejectedWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(AttachWrapper) == clazz)//RejectedWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(DetachWrapper) == clazz)//RejectedWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(DispositionWrapper) == clazz)//RejectedWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(DischargeWrapper) == clazz)//RejectedWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(ErrorConditionWrapper) == clazz)//RejectedWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(TransactionalStateWrapper) == clazz)//RejectedWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(BeginWrapper) == clazz)//RejectedWrapper//DischargeWrapper//ErrorConditionWrapper//TransactionalStateWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(FlowWrapper) == clazz)//RejectedWrapper//SourceWrapper//TransferWrapper//AttachWrapper//DetachWrapper//DispositionWrapper//BeginWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(RejectedWrapper) == clazz)//RejectedWrapper//FlowWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(ModifiedWrapper) == clazz)//OpenWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(OpenWrapper) == clazz)//OpenWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(ReceivedWrapper) == clazz)//PropertiesWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(PropertiesWrapper) == clazz)//PropertiesWrapper
            {
                amqpType = _listType;
            }
            else if (typeid(ArrayList!Object) == clazz)
            {
                amqpType = _listType;
            }
            else if(typeid(List!Object) == clazz)
            {
                amqpType = _listType;
            }
            else if(typeid(Map!(String,Object)) == clazz)
            {
                amqpType = _mapType;
            }
            else if(typeid(Map!(Symbol,Object)) == clazz)
            {
                amqpType = _symbolMapType;
            }
            else
            {
                amqpType = _describedTypesClassRegistry.get(clazz);
                if(amqpType is null && instance !is null)
                {
                    Object descriptor = (cast(DescribedType) instance).getDescriptor();
                    amqpType = _describedDescriptorRegistry.get(descriptor);
                    if(amqpType is null)
                    {
                        amqpType = new DynamicDescribedType(this, descriptor);
                        _describedDescriptorRegistry.put(descriptor, amqpType);
                    }
                }

                return amqpType;
            }
       // }
         _typeRegistry.put(clazz, amqpType);

        return amqpType;
    }

    public void register(V)(AMQPType!(V) type)
    {
        register!V(type.getTypeClass(), type);
    }

    void register(T)(TypeInfo clazz, AMQPType!(T) type)
    {
        _typeRegistry.put(clazz, type);
    }
    //
    //public void registerDescribedType(Class clazz, Object descriptor)
    //{
    //    AMQPType<?> type = _describedDescriptorRegistry.get(descriptor);
    //    if(type is null)
    //    {
    //        type = new DynamicDescribedType(this, descriptor);
    //        _describedDescriptorRegistry.put(descriptor, type);
    //    }
    //    _describedTypesClassRegistry.put(clazz, type);
    //}

    override
    public void writeNull()
    {
        _buffer.put(EncodingCodes.NULL);
    }

    override
    public void writeBoolean(bool bl)
    {
        if (bl)
        {
            _buffer.put(EncodingCodes.BOOLEAN_TRUE);
        }
        else
        {
            _buffer.put(EncodingCodes.BOOLEAN_FALSE);
        }
    }

    public void writeBoolean(Boolean bl)
    {
        if(bl is null)
        {
            writeNull();
        }
        else if (bl.booleanValue())
        {
            _buffer.put(EncodingCodes.BOOLEAN_TRUE);
        }
        else
        {
            _buffer.put(EncodingCodes.BOOLEAN_FALSE);
        }
    }

    override
    public void writeUnsignedByte(UnsignedByte ub)
    {
        if(ub is null)
        {
            writeNull();
        }
        else
        {
            _unsignedByteType.fastWrite(this, ub);
        }
    }

    override
    public void writeUnsignedShort(UnsignedShort us)
    {
        if(us is null)
        {
            writeNull();
        }
        else
        {
            _unsignedShortType.fastWrite(this, us);
        }
    }

    override
    public void writeUnsignedInteger(UnsignedInteger ui)
    {
        if(ui is null)
        {
            writeNull();
        }
        else
        {
            _unsignedIntegerType.fastWrite(this, ui);
        }
    }

    override
    public void writeUnsignedLong(UnsignedLong ul)
    {
        if(ul is null)
        {
            writeNull();
        }
        else
        {
            _unsignedLongType.fastWrite(this, ul);
        }
    }

    override
    public void writeByte(byte b)
    {
        _byteType.write(new Byte(b));
    }

    override
    public void writeByte(Byte b)
    {
        if(b is null)
        {
            writeNull();
        }
        else
        {
            writeByte(b.byteValue());
        }
    }

    override
    public void writeShort(short s)
    {
        _shortType.write(s);
    }

    override
    public void writeShort(Short s)
    {
        if(s is null)
        {
            writeNull();
        }
        else
        {
            writeShort(s.shortValue());
        }
    }

    override
    public void writeInteger(int i)
    {
        _integerType.write(i);
    }

    override
    public void writeInteger(Integer i)
    {
        if(i is null)
        {
            writeNull();
        }
        else
        {
            writeInteger(i.intValue());
        }
    }

    override
    public void writeLong(long l)
    {
        _longType.write(l);
    }

    override
    public void writeLong(Long l)
    {

        if(l is null)
        {
            writeNull();
        }
        else
        {
            writeLong(l.longValue());
        }
    }

    override
    public void writeFloat(float f)
    {
        _floatType.write(f);
    }

    override
    public void writeFloat(Float f)
    {
        if(f is null)
        {
            writeNull();
        }
        else
        {
            writeFloat(f.floatValue());
        }
    }

    override
    public void writeDouble(double d)
    {
        _doubleType.write(d);
    }

    override
    public void writeDouble(Double d)
    {
        if(d is null)
        {
            writeNull();
        }
        else
        {
            writeDouble(d.doubleValue());
        }
    }

    override
    public void writeDecimal32(Decimal32 d)
    {
        if(d is null)
        {
            writeNull();
        }
        else
        {
         //   _decimal32Type.write(d);
        }
    }

    override
    public void writeDecimal64(Decimal64 d)
    {
        if(d is null)
        {
            writeNull();
        }
        else
        {
         //   _decimal64Type.write(d);
        }
    }

    override
    public void writeDecimal128(Decimal128 d)
    {
        if(d is null)
        {
            writeNull();
        }
        else
        {
           // _decimal128Type.write(d);
        }
    }

    override
    public void writeCharacter(char c)
    {
        // TODO - java character may be half of a pair, should probably throw exception then
        _characterType.write(c);
    }

    override
    public void writeCharacter(Char c)
    {
        if(c is null)
        {
            writeNull();
        }
        else
        {
            writeCharacter(c.charValue());
        }
    }

    override
    public void writeTimestamp(long timestamp)
    {
      //  implementationMissing(false);
        _timestampType.fastWrite(this, timestamp);
    }

    override
    public void writeTimestamp(Date d)
    {
        if(d is null)
        {
            writeNull();
        }
        else
        {
            //implementationMissing(false);
            _timestampType.fastWrite(this, d.toEpochMilli());
        }
    }

    override
    public void writeUUID(UUID uuid)
    {
        //if(uuid is null)
        //{
        //    writeNull();
        //}
        //else
        //{
        //    _uuidType.fastWrite(this, uuid);
        //}
    }

    override
    public void writeBinary(Binary b)
    {
        if(b is null)
        {
            writeNull();
        }
        else
        {
            _binaryType.fastWrite(this, b);
        }
    }

    override
    public void writeString(String s)
    {
        if(s is null)
        {
            writeNull();
        }
        else
        {
            _stringType.write(s);
        }
    }

    override
    public void writeSymbol(Symbol s)
    {
        if(s is null)
        {
            writeNull();
        }
        else
        {
            _symbolType.fastWrite(this, s);
        }
    }

    override
    public void writeList(Object l)
    {
        if(l is null)
        {
            writeNull();
        }
        else
        {
            _listType.write(l);
        }
    }

    override
    public void writeMap(Object m)
    {

        if(m is null)
        {
            writeNull();
        }
        else
        {
            _objectMapType.write(m);
        }
    }

    override
    public void writeDescribedType(DescribedType d)
    {
        if(d is null)
        {
            writeNull();
        }
        else
        {
            _buffer.put(DESCRIBED_TYPE_OP);
           // implementationMissing(false);
            writeObject(d.getDescriptor());
            writeObject(d.getDescribed());
        }
    }

    //override
    //public void writeArray(bool[] a)
    //{
    //    if(a is null)
    //    {
    //        writeNull();
    //    }
    //    else
    //    {
    //        _arrayType.write(a);
    //    }
    //}

    //override
    //public void writeArray(byte[] a)
    //{
    //    if(a is null)
    //    {
    //        writeNull();
    //    }
    //    else
    //    {
    //        _arrayType.write(a);
    //    }
    //}
    //
    //override
    //public void writeArray(short[] a)
    //{
    //    if(a is null)
    //    {
    //        writeNull();
    //    }
    //    else
    //    {
    //        _arrayType.write(a);
    //    }
    //}

    override
    public void writeArray(int[] a)
    {
        if(a is null)
        {
            writeNull();
        }
        else
        {
          //  _arrayType.write(a);
        }
    }

    override
    public void writeArray(long[] a)
    {
        if(a is null)
        {
            writeNull();
        }
        else
        {
           // _arrayType.write(a);
        }
    }

    override
    public void writeArray(float[] a)
    {
        if(a is null)
        {
            writeNull();
        }
        else
        {
         //   _arrayType.write(a);
        }
    }

    override
    public void writeArray(double[] a)
    {
        if(a is null)
        {
            writeNull();
        }
        else
        {
         //   _arrayType.write(a);
        }
    }

    override
    public void writeArray(char[] a)
    {
        if(a is null)
        {
            writeNull();
        }
        else
        {
           // _arrayType.write(a);
        }
    }

    override
    public void writeArray(Object[] a)
    {
        if(a is null)
        {
            writeNull();
        }
        else
        {
          //  _arrayType.write(a);
        }
    }

    override
    public void writeObject(Object o)
    {
        if (o !is null)
        {
            IAMQPType type = _typeRegistry.get(typeid(o));

            if(type !is null)
            {
                type.write(o);
            }
            else
            {
                writeUnregisteredType(o);
            }
        }
        else
        {
            _buffer.put(EncodingCodes.NULL);
        }
    }





    private void writeUnregisteredType(Object o)
    {


        if(cast(List!Object)o !is null)
        {
            writeList(o);
        }
        else if(cast(Map!(String,Object))o !is null)
        {
            writeMap(o);
        }
        else if( cast(DescribedType)o !is null)
        {
            writeDescribedType(cast(DescribedType)o);
        }
        else
        {
            throw new IllegalArgumentException(
                "Do not know how to write Objects of class ");
        }
    }
    //
    //private void writeArrayType(Object array) {
    //    Class<?> componentType = array.getClass().getComponentType();
    //    if(componentType.isPrimitive())
    //    {
    //        if(componentType == Boolean.TYPE)
    //        {
    //            writeArray((bool[])array);
    //        }
    //        else if(componentType == Byte.TYPE)
    //        {
    //            writeArray((byte[])array);
    //        }
    //        else if(componentType == Short.TYPE)
    //        {
    //            writeArray((short[])array);
    //        }
    //        else if(componentType == Integer.TYPE)
    //        {
    //            writeArray((int[])array);
    //        }
    //        else if(componentType == Long.TYPE)
    //        {
    //            writeArray((long[])array);
    //        }
    //        else if(componentType == Float.TYPE)
    //        {
    //            writeArray((float[])array);
    //        }
    //        else if(componentType == Double.TYPE)
    //        {
    //            writeArray((double[])array);
    //        }
    //        else if(componentType == Character.TYPE)
    //        {
    //            writeArray((char[])array);
    //        }
    //        else
    //        {
    //            throw new IllegalArgumentException("Cannot write arrays of type " ~ componentType.getName());
    //        }
    //    }
    //    else
    //    {
    //        writeArray((Object[]) array);
    //    }
    //}

    public void writeRaw(byte b)
    {
        _buffer.put(b);
    }

    void writeRaw(short s)
    {
        _buffer.putShort(s);
    }

    void writeRaw(int i)
    {
        _buffer.putInt(i);
    }

    void writeRaw(long l)
    {
        _buffer.putLong(l);
    }

    void writeRaw(float f)
    {
        _buffer.putFloat(f);
    }

    void writeRaw(double d)
    {
        _buffer.putDouble(d);
    }

    void writeRaw(byte[] src, int offset, int length)
    {
        _buffer.put(src, offset, length);
    }

    void writeRaw(String str)
    {
        _buffer.put(cast(string)str.getBytes());
    }

    //AMQPType<?> getNullTypeEncoder()
    //{
    //    return _nullType;
    //}
}
