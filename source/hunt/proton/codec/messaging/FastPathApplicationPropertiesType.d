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
module hunt.proton.codec.messaging.FastPathApplicationPropertiesType;

import hunt.collection.Collection;
import hunt.collection.Map;

import hunt.collection.LinkedHashMap;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.ApplicationProperties;
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
import hunt.proton.codec.StringType;
import hunt.proton.codec.TypeConstructor;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.WritableBuffer;
import hunt.proton.codec.messaging.ApplicationPropertiesType;
import hunt.proton.codec.MapType;
import hunt.String;
import hunt.Exceptions;
import hunt.logging;
import std.conv : to;

import std.concurrency : initOnce;

class FastPathApplicationPropertiesType : AMQPType!(ApplicationProperties), FastPathDescribedTypeConstructor!(ApplicationProperties) {

    private static byte DESCRIPTOR_CODE = 0x74;

    //private static Object[] DESCRIPTORS = {
    //    UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:application-properties:map"),
    //};

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:application-properties:map")]);
    }


    private ApplicationPropertiesType propertiesType;
    private StringType stringType;

    this(EncoderImpl encoder) {
        this.propertiesType = new ApplicationPropertiesType(encoder);
        this.stringType = cast(StringType) encoder.getTypeFromClass(typeid(String));
    }

    public EncoderImpl getEncoder() {
        return propertiesType.getEncoder();
    }

    public DecoderImpl getDecoder() {
        return propertiesType.getDecoder();
    }

    override
    public bool encodesJavaPrimitive() {
        return false;
    }

    override
    public TypeInfo getTypeClass() {
        return typeid(ApplicationProperties);
    }

    override
    public ITypeEncoding getEncoding(Object val) {
        return propertiesType.getEncoding(cast(ApplicationProperties)val);
    }

    override
    public TypeEncoding!(ApplicationProperties) getCanonicalEncoding() {
        return propertiesType.getCanonicalEncoding();
    }

    override
    public  Collection!(TypeEncoding!(ApplicationProperties)) getAllEncodings() {
        return propertiesType.getAllEncodings();
    }

    override
    public ApplicationProperties readValue() {
       // implementationMissing(false);
        //return null;
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
                return new ApplicationProperties(null);
            default:
            {
                logError("Expected Map type but found encoding : %d", encodingCode);
                break;
            }
              //  throw new ProtonException("Expected Map type but found encoding: " ~ encodingCode);
        }

        if (count > buffer.remaining()) {
            throw new IllegalArgumentException("Map element count " ~ to!string(count) ~ " is specified to be greater than the " ~
                                               "amount of data available ("~ to!string(buffer.remaining()) ~ ")");
        }

        ITypeConstructor  valueConstructor = null;

        Map!(String, Object) map = new LinkedHashMap!(String,Object)(count);

        for (int i = 0; i < count / 2; i++) {
            String key = decoder.readString(null);
            if (key is null) {
                logError("String key in ApplicationProperties cannot be null");
             //   throw new DecodeException("String key in ApplicationProperties cannot be null");
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

            valueConstructor =  findNextDecoder(decoder, buffer, valueConstructor);

            Object value;

            //if (arrayType) {
            //    value = ((ArrayType.ArrayEncoding) valueConstructor).readValueArray();
            //} else {

            value = valueConstructor.readValue();
          //  }

            map.put(key, value);
        }

        return new ApplicationProperties(map);
    }

    override
    public void skipValue() {
        implementationMissing(false);
       // getDecoder().readConstructor().skipValue();
    }

    override
    public void write(Object v) {
        ApplicationProperties val = cast(ApplicationProperties)v;

        WritableBuffer buffer = getEncoder().getBuffer();
        buffer.put(EncodingCodes.DESCRIBED_TYPE_INDICATOR);
        buffer.put(EncodingCodes.SMALLULONG);
        buffer.put(DESCRIPTOR_CODE);


        MapType mapType = cast(MapType) getEncoder().getType(cast(Object)val.getValue());

        mapType.setKeyEncoding(stringType);
      //  try {
            mapType.write(cast(Object)val.getValue());
       // }
        //finally {
        //    mapType.setKeyEncoding(null);
        //}
    }

    public static void register(Decoder decoder, EncoderImpl encoder) {
        FastPathApplicationPropertiesType type = new FastPathApplicationPropertiesType(encoder);
        //implementationMissing(false);
        foreach (Object descriptor ; DESCRIPTORS) {
            decoder.registerFastPath(descriptor, type);
        }
        encoder.register(type);
    }

    private static ITypeConstructor findNextDecoder(DecoderImpl decoder, ReadableBuffer buffer, ITypeConstructor previousConstructor) {
        if (previousConstructor is null) {
            return decoder.readConstructor();
        } else {
            byte encodingCode = buffer.get(buffer.position());
            if (encodingCode == EncodingCodes.DESCRIBED_TYPE_INDICATOR) {
                previousConstructor = decoder.readConstructor();
            } else {
                IPrimitiveTypeEncoding primitiveConstructor = cast(IPrimitiveTypeEncoding)previousConstructor;
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
         //   throw new DecodeException("Unknown constructor found in Map encoding: ");
        }

        return previousConstructor;
    }
}
