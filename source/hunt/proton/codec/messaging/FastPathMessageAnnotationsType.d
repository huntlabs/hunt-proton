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
module hunt.proton.codec.messaging.FastPathMessageAnnotationsType;

import hunt.collection.Collection;
import hunt.collection.LinkedHashMap;
import hunt.collection.Map;

import hunt.proton.codec.messaging.MessageAnnotationsType;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.MessageAnnotations;
import hunt.proton.codec.AMQPType;
import hunt.proton.codec.ArrayType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.FastPathDescribedTypeConstructor;
import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.SymbolType;
import hunt.proton.codec.TypeConstructor;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.WritableBuffer;
import std.concurrency : initOnce;
import hunt.Exceptions;
import hunt.proton.codec.SymbolMapType;
import hunt.logging;
import std.conv:to;

class FastPathMessageAnnotationsType : AMQPType!(MessageAnnotations), FastPathDescribedTypeConstructor!(MessageAnnotations) {

    private static byte DESCRIPTOR_CODE = 0x72;

    //private static Object[] DESCRIPTORS = {
    //    UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:message-annotations:map"),
    //};

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:message-annotations:map")]);
    }

    private MessageAnnotationsType annotationsType;
    private SymbolType symbolType;

    this(EncoderImpl encoder) {
        this.annotationsType = new MessageAnnotationsType(encoder);
        this.symbolType = cast(SymbolType) encoder.getTypeFromClass(typeid(Symbol));
    }

    public EncoderImpl getEncoder() {
        return annotationsType.getEncoder();
    }

    public DecoderImpl getDecoder() {
        return annotationsType.getDecoder();
    }

    override
    public bool encodesJavaPrimitive() {
        return false;
    }

    override
    public TypeInfo getTypeClass() {
        return typeid(MessageAnnotations);
    }

    override
    public ITypeEncoding getEncoding(Object val) {
        return annotationsType.getEncoding(cast(MessageAnnotations)val);
    }

    override
    public TypeEncoding!(MessageAnnotations) getCanonicalEncoding() {
        return annotationsType.getCanonicalEncoding();
    }

    override
    public  Collection!(TypeEncoding!(MessageAnnotations)) getAllEncodings() {
        return annotationsType.getAllEncodings();
    }

    override
    public Object readValue() {
        DecoderImpl decoder = getDecoder();
        ReadableBuffer buffer = decoder.getBuffer();

        int size;
        int count;

        byte encodingCode = buffer.get();

        switch (encodingCode) {
            case EncodingCodes.MAP8:
                size = buffer.get() & 0xFF;
                count = buffer.get() & 0xFF;
                break;
            case EncodingCodes.MAP32:
                size = buffer.getInt();
                count = buffer.getInt();
                break;
            case EncodingCodes.NULL:
                return new MessageAnnotations(null);
            default:
            {
                logError("Expected Map type but found encoding:");
                return null;
            }
               // throw new ProtonException("Expected Map type but found encoding: " ~ encodingCode);
        }

        if (count > buffer.remaining()) {
            throw new IllegalArgumentException("Map element count "~ to!string(count) ~" is specified to be greater than the amount of data available ("~
                                               to!string(decoder.getByteBufferRemaining())~")");
        }

        ITypeConstructor  valueConstructor = null;

        Map!(Symbol, Object) map = new LinkedHashMap!(Symbol,Object)(count);
        for(int i = 0; i < count / 2; i++) {
            Symbol key = decoder.readSymbol(null);
            if (key is null) {
                logError("String key in DeliveryAnnotations cannot be null");
                return null;
              //  throw new DecodeException("String key in DeliveryAnnotations cannot be null");
            }

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

            Object value;

            //if (arrayType) {
            //    value = ((ArrayType.ArrayEncoding) valueConstructor).readValueArray();
            //} else {
                value = valueConstructor.readValue();
           // }

            map.put(key, value);
        }

        return new MessageAnnotations(map);
    }

    override
    public void skipValue() {
        getDecoder().readConstructor().skipValue();
        //implementationMissing(false);
    }

    override
    public void write(Object v) {

        MessageAnnotations val = cast(MessageAnnotations)v;
      //  implementationMissing(false);

        WritableBuffer buffer = getEncoder().getBuffer();

        buffer.put(EncodingCodes.DESCRIBED_TYPE_INDICATOR);
        buffer.put(EncodingCodes.SMALLULONG);
        buffer.put(DESCRIPTOR_CODE);

        SymbolMapType mapType = cast(SymbolMapType) getEncoder().getType(cast(Object)val.getValue());

        mapType.setKeyEncoding(symbolType);
        try {
            mapType.write(cast(Object)val.getValue());
        } finally {
            mapType.setKeyEncoding(null);
        }
    }

    public static void register(Decoder decoder, EncoderImpl encoder) {
        FastPathMessageAnnotationsType type = new FastPathMessageAnnotationsType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS) {
            decoder.registerFastPath(descriptor, type);
        }
        encoder.register(type);
    }

    private static ITypeConstructor findNextDecoder(DecoderImpl decoder, ReadableBuffer buffer, ITypeConstructor previousConstructor) {
        if (previousConstructor is null) {
            return decoder.readConstructor();
        } else {
            byte encodingCode = buffer.get(buffer.position());
            if (encodingCode == EncodingCodes.DESCRIBED_TYPE_INDICATOR ) {
                previousConstructor = decoder.readConstructor();
            } else {
                IPrimitiveTypeEncoding primitiveConstructor = cast(IPrimitiveTypeEncoding) previousConstructor;
                if (encodingCode != primitiveConstructor.getEncodingCode()) {
                    previousConstructor = decoder.readConstructor();
                } else {
                    // consume the encoding code byte for real
                    encodingCode = buffer.get();
                }
            }
        }

        if (previousConstructor is null) {
            logError("Unknown constructor found in Map encoding:");
            return null;
           // throw new DecodeException("Unknown constructor found in Map encoding: ");
        }

        return previousConstructor;
    }
}
