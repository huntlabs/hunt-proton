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
module hunt.proton.codec.messaging.FastPathAmqpSequenceType;

import hunt.collection.Collection;
import hunt.proton.codec.messaging.AmqpSequenceType;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.AmqpSequence;
import hunt.proton.codec.AMQPType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.FastPathDescribedTypeConstructor;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.WritableBuffer;

import std.concurrency : initOnce;
import hunt.Exceptions;
import hunt.collection.List;

class FastPathAmqpSequenceType : AMQPType!(AmqpSequence), FastPathDescribedTypeConstructor!(AmqpSequence) {

    private static byte DESCRIPTOR_CODE = 0x76;

    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:amqp-sequence:list"),
    //};

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:amqp-sequence:list")]);
    }


    private AmqpSequenceType sequenceType;

    this(EncoderImpl encoder) {
        this.sequenceType = new AmqpSequenceType(encoder);
    }

    public EncoderImpl getEncoder() {
        return sequenceType.getEncoder();
    }

    public DecoderImpl getDecoder() {
        return sequenceType.getDecoder();
    }

    override
    public bool encodesJavaPrimitive() {
        return false;
    }

    override
    public TypeInfo getTypeClass() {
        return typeid(AmqpSequence);
    }

    override
    public ITypeEncoding getEncoding(Object val) {
        return sequenceType.getEncoding(cast(AmqpSequence)val);
    }

    override
    public TypeEncoding!(AmqpSequence) getCanonicalEncoding() {
        return sequenceType.getCanonicalEncoding();
    }

    override
    public  Collection!(TypeEncoding!(AmqpSequence)) getAllEncodings() {
        return sequenceType.getAllEncodings();
    }

    override
    public AmqpSequence readValue() {
        implementationMissing(false);
      //  return new AmqpSequence(getDecoder().readList());
        return null;
    }

    override
    public void skipValue() {
        implementationMissing(false);
      //  getDecoder().readConstructor().skipValue();
    }

    override
    public void write(Object v) {
        AmqpSequence sequence = cast(AmqpSequence)v;
        WritableBuffer buffer = getEncoder().getBuffer();
        buffer.put(EncodingCodes.DESCRIBED_TYPE_INDICATOR);
        buffer.put(EncodingCodes.SMALLULONG);
        buffer.put(DESCRIPTOR_CODE);
        getEncoder().writeObject(cast(Object)sequence.getValue());
    }

    public static void register(Decoder decoder, EncoderImpl encoder) {
        FastPathAmqpSequenceType type = new FastPathAmqpSequenceType(encoder);
        //implementationMissing(false);
        foreach (Object descriptor ; DESCRIPTORS) {
            decoder.registerFastPath(descriptor,  type);
        }
        encoder.register(type);
    }
}
