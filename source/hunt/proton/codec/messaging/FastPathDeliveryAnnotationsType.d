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
module hunt.proton.codec.messaging.FastPathDeliveryAnnotationsType;

import hunt.collection.Collection;
import hunt.collection.LinkedHashMap;
import hunt.collection.Map;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.DeliveryAnnotations;
import hunt.proton.codec.AMQPType;
import hunt.proton.codec.ArrayType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.FastPathDescribedTypeConstructor;
import hunt.proton.codec.MapType;
import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.SymbolType;
import hunt.proton.codec.TypeConstructor;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.WritableBuffer;
import hunt.proton.codec.messaging.DeliveryAnnotationsType;
import std.concurrency : initOnce;
import hunt.Exceptions;


class FastPathDeliveryAnnotationsType : AMQPType!(DeliveryAnnotations), FastPathDescribedTypeConstructor!(DeliveryAnnotations) {

    private static byte DESCRIPTOR_CODE = 0x71;

    //private static Object[] DESCRIPTORS = {
    //    UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:delivery-annotations:map"),
    //};


    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:delivery-annotations:map")]);
    }

    private DeliveryAnnotationsType annotationsType;
    private SymbolType symbolType;

    this(EncoderImpl encoder) {
        this.annotationsType = new DeliveryAnnotationsType(encoder);
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
        return typeid(DeliveryAnnotations);
    }

    override
    public ITypeEncoding getEncoding(Object val) {
        return annotationsType.getEncoding(cast(DeliveryAnnotations)val);
    }

    override
    public TypeEncoding!(DeliveryAnnotations) getCanonicalEncoding() {
        return annotationsType.getCanonicalEncoding();
    }

    override
    public  Collection!(TypeEncoding!(DeliveryAnnotations)) getAllEncodings() {
        return annotationsType.getAllEncodings();
    }

    override
    public DeliveryAnnotations readValue() {
        implementationMissing(false);
        return null;
        //DecoderImpl decoder = getDecoder();
        //ReadableBuffer buffer = decoder.getBuffer();
        //
        //int size;
        //int count;
        //
        //byte encodingCode = buffer.get();
        //
        //switch (encodingCode) {
        //    case EncodingCodes.MAP8:
        //        size = buffer.get() & 0xFF;
        //        count = buffer.get() & 0xFF;
        //        break;
        //    case EncodingCodes.MAP32:
        //        size = buffer.getInt();
        //        count = buffer.getInt();
        //        break;
        //    case EncodingCodes.NULL:
        //        return new DeliveryAnnotations(null);
        //    default:
        //        throw new ProtonException("Expected Map type but found encoding: " ~ encodingCode);
        //}
        //
        //if (count > buffer.remaining()) {
        //    throw new IllegalArgumentException("Map element count " ~ count ~ " is specified to be greater than the " ~
        //                                       "amount of data available (" ~ buffer.remaining() ~ ")");
        //}
        //
        //TypeConstructor<?> valueConstructor = null;
        //
        //Map!(Symbol, Object) map = new LinkedHashMap<>(count);
        //for(int i = 0; i < count / 2; i++) {
        //    Symbol key = decoder.readSymbol(null);
        //    if (key is null) {
        //        throw new DecodeException("String key in DeliveryAnnotations cannot be null");
        //    }
        //
        //    bool arrayType = false;
        //    byte code = buffer.get(buffer.position());
        //    switch (code)
        //    {
        //        case EncodingCodes.ARRAY8:
        //        case EncodingCodes.ARRAY32:
        //            arrayType = true;
        //    }
        //
        //    valueConstructor = findNextDecoder(decoder, buffer, valueConstructor);
        //
        //    Object value;
        //
        //    if (arrayType) {
        //        value = ((ArrayType.ArrayEncoding) valueConstructor).readValueArray();
        //    } else {
        //        value = valueConstructor.readValue();
        //    }
        //
        //    map.put(key, value);
        //}
        //
        //return new DeliveryAnnotations(map);
    }

    override
    public void skipValue() {
        implementationMissing(false);
      //  getDecoder().readConstructor().skipValue();
    }

    override
    public void write(Object v) {
        DeliveryAnnotations val = cast(DeliveryAnnotations)v;
        implementationMissing(false);
        //WritableBuffer buffer = getEncoder().getBuffer();
        //
        //buffer.put(EncodingCodes.DESCRIBED_TYPE_INDICATOR);
        //buffer.put(EncodingCodes.SMALLULONG);
        //buffer.put(DESCRIPTOR_CODE);
        //
        //MapType mapType = (MapType) getEncoder().getType(val.getValue());
        //
        //mapType.setKeyEncoding(symbolType);
        //try {
        //    mapType.write(val.getValue());
        //} finally {
        //    mapType.setKeyEncoding(null);
        //}
    }

    public static void register(Decoder decoder, EncoderImpl encoder) {
        FastPathDeliveryAnnotationsType type = new FastPathDeliveryAnnotationsType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS) {
            decoder.registerFastPath(descriptor, type);
        }
        encoder.register(type);
    }

    //private static TypeConstructor<?> findNextDecoder(DecoderImpl decoder, ReadableBuffer buffer, TypeConstructor<?> previousConstructor) {
    //    if (previousConstructor is null) {
    //        return decoder.readConstructor();
    //    } else {
    //        byte encodingCode = buffer.get(buffer.position());
    //        if (encodingCode == EncodingCodes.DESCRIBED_TYPE_INDICATOR || !(previousConstructor instanceof PrimitiveTypeEncoding<?>)) {
    //            previousConstructor = decoder.readConstructor();
    //        } else {
    //            PrimitiveTypeEncoding<?> primitiveConstructor = (PrimitiveTypeEncoding<?>) previousConstructor;
    //            if (encodingCode != primitiveConstructor.getEncodingCode()) {
    //                previousConstructor = decoder.readConstructor();
    //            } else {
    //                // consume the encoding code byte for real
    //                encodingCode = buffer.get();
    //            }
    //        }
    //    }
    //
    //    if (previousConstructor is null) {
    //        throw new DecodeException("Unknown constructor found in Map encoding: ");
    //    }
    //
    //    return previousConstructor;
    //}
}
