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
module hunt.proton.codec.messaging.FastPathDataType;

import hunt.Exceptions;
import hunt.collection.Collection;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Data;
import hunt.proton.codec.AMQPType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.FastPathDescribedTypeConstructor;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.WritableBuffer;
import hunt.proton.codec.messaging.DataType;
import std.concurrency : initOnce;
import hunt.logging;
import std.conv : to;

class FastPathDataType : AMQPType!(Data), FastPathDescribedTypeConstructor!(Data) {

    private static byte DESCRIPTOR_CODE = 0x75;

    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:data:binary"),
    //};

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:data:binary")]);
    }

    private DataType dataType;

    this(EncoderImpl encoder) {
        this.dataType = new DataType(encoder);
    }

    public EncoderImpl getEncoder() {
        return dataType.getEncoder();
    }

    public DecoderImpl getDecoder() {
        return dataType.getDecoder();
    }

    override
    public bool encodesJavaPrimitive() {
        return false;
    }

    override
    public TypeInfo getTypeClass() {
        return dataType.getTypeClass();
    }

    override
    public ITypeEncoding getEncoding(Object val) {
        return dataType.getEncoding(cast(Data)val);
    }

    override
    public TypeEncoding!(Data) getCanonicalEncoding() {
        return dataType.getCanonicalEncoding();
    }

    override
    public  Collection!(TypeEncoding!(Data)) getAllEncodings() {
        return dataType.getAllEncodings();
    }

    override
    public Data readValue() {
        ReadableBuffer buffer = getDecoder().getBuffer();
        byte encodingCode = buffer.get();

        int size = 0;

        switch (encodingCode) {
            case EncodingCodes.VBIN8:
                size = buffer.get() & 0xFF;
                break;
            case EncodingCodes.VBIN32:
                size = buffer.getInt();
                break;
            case EncodingCodes.NULL:
                return new Data(null);
            default:
            {
                logError("Expected Binary type but found encoding: %d",encodingCode);
                break;
            }
                //throw new ProtonException("Expected Binary type but found encoding: " ~ encodingCode);
        }

        if (size > buffer.remaining()) {
            throw new IllegalArgumentException("Binary data size " ~ to!string(size) ~ " is specified to be greater than the " ~
                                               "amount of data available ("~ to!string(buffer.remaining())~")");
        }

        byte[] data = new byte[size];
        buffer.get(data, 0, size);

        return new Data(new Binary(data));
    }

    override
    public void skipValue() {
        implementationMissing(false);
      //  getDecoder().readConstructor().skipValue();
    }

    override
    public void write(Object v) {
        Data data = cast(Data)v;
        WritableBuffer buffer = getEncoder().getBuffer();
        buffer.put(EncodingCodes.DESCRIBED_TYPE_INDICATOR);
        buffer.put(EncodingCodes.SMALLULONG);
        buffer.put(DESCRIPTOR_CODE);
        getEncoder().writeBinary(data.getValue());
    }

    public static void register(Decoder decoder, EncoderImpl encoder) {
        FastPathDataType type = new FastPathDataType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS) {
           // decoder.register(descriptor, (FastPathDescribedTypeConstructor<?>) type);
             decoder.registerFastPath(descriptor,  type);
        }
        encoder.register(type);
    }
}
