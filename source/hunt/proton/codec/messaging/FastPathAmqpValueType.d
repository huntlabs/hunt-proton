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
module hunt.proton.codec.messaging.FastPathAmqpValueType;

import hunt.collection.Collection;
import hunt.proton.codec.messaging.AmqpValueType;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.AmqpValue;
import hunt.proton.codec.AMQPType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.FastPathDescribedTypeConstructor;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.WritableBuffer;
import hunt.proton.codec.TypeConstructor;
import hunt.proton.codec.StringType;

import std.concurrency : initOnce;
import hunt.Exceptions;
import hunt.String;
import hunt.logging;

class FastPathAmqpValueType : AMQPType!(AmqpValue), FastPathDescribedTypeConstructor!(AmqpValue) {

    private static byte DESCRIPTOR_CODE = 0x77;

    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:amqp-value:*"),
    //};

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:amqp-value:*")]);
    }

    private AmqpValueType valueType;

    this(EncoderImpl encoder) {
        this.valueType = new AmqpValueType(encoder);
    }

    public EncoderImpl getEncoder() {
        return valueType.getEncoder();
    }

    public DecoderImpl getDecoder() {
        return valueType.getDecoder();
    }

    override
    public bool encodesJavaPrimitive() {
        return false;
    }

    override
    public TypeInfo getTypeClass() {
        return typeid(AmqpValue);
    }

    override
    public ITypeEncoding getEncoding(Object value) {
        return valueType.getEncoding(cast(AmqpValue)value);
    }

    override
    public TypeEncoding!(AmqpValue) getCanonicalEncoding() {
        return valueType.getCanonicalEncoding();
    }

    override
    public  Collection!(TypeEncoding!(AmqpValue)) getAllEncodings() {
        return valueType.getAllEncodings();
    }

    override
    public AmqpValue readValue() {
        //return new AmqpValue((cast(TypeConstructor!String)(getDecoder().readObject())).readValue());
       // return new AmqpValue((cast(StringEncoding)(getDecoder().readObject())).readValue());
        return new AmqpValue(getDecoder().readObject());
    }

    override
    public void skipValue() {
        implementationMissing(false);
       // getDecoder().readConstructor().skipValue();
    }

    override
    public void write(Object v) {
        AmqpValue value = cast(AmqpValue)v;
        WritableBuffer buffer = getEncoder().getBuffer();
        buffer.put(EncodingCodes.DESCRIBED_TYPE_INDICATOR);
        buffer.put(EncodingCodes.SMALLULONG);
        buffer.put(DESCRIPTOR_CODE);
        getEncoder().writeObject(value.getValue());
    }

    public static void register(Decoder decoder, EncoderImpl encoder) {
        FastPathAmqpValueType type = new FastPathAmqpValueType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS) {
            decoder.registerFastPath(descriptor, type);
        }
        encoder.register(type);
    }
}
