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
module hunt.proton.codec.messaging.FastPathAcceptedType;

import hunt.collection.Collection;
import hunt.proton.codec.messaging.AcceptedType;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Accepted;
import hunt.proton.codec.AMQPType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.FastPathDescribedTypeConstructor;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.WritableBuffer;
import hunt.logging;
import hunt.Exceptions;
import std.concurrency : initOnce;

class FastPathAcceptedType : AMQPType!(Accepted), FastPathDescribedTypeConstructor!(Accepted) {

    private static byte DESCRIPTOR_CODE = 0x24;

    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:accepted:list"),
    //};

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:accepted:list")]);
    }

    static byte[] ACCEPTED_ENCODED_BYTES()
    {
        __gshared byte[]  inst;
        return initOnce!inst(
            [ EncodingCodes.DESCRIBED_TYPE_INDICATOR,
            EncodingCodes.SMALLULONG,
            DESCRIPTOR_CODE,
            EncodingCodes.LIST0 ]
        );

    }

    //private static byte[] ACCEPTED_ENCODED_BYTES = [
    //    EncodingCodes.DESCRIBED_TYPE_INDICATOR,
    //    EncodingCodes.SMALLULONG,
    //    DESCRIPTOR_CODE,
    //    EncodingCodes.LIST0
    //];

    private AcceptedType acceptedType;

    this(EncoderImpl encoder) {
        this.acceptedType = new AcceptedType(encoder);
    }

    public EncoderImpl getEncoder() {
        return acceptedType.getEncoder();
    }

    public DecoderImpl getDecoder() {
        return acceptedType.getDecoder();
    }

    override
    public bool encodesJavaPrimitive() {
        return false;
    }

    override
    public TypeInfo getTypeClass() {
        return typeid(Accepted);
    }

    override
    public ITypeEncoding getEncoding(Object accepted) {
        return acceptedType.getEncoding(cast(Accepted)accepted);
    }

    override
    public TypeEncoding!(Accepted) getCanonicalEncoding() {
        return acceptedType.getCanonicalEncoding();
    }

    override
    public  Collection!(TypeEncoding!(Accepted)) getAllEncodings() {
        return acceptedType.getAllEncodings();
    }

    override
    public Accepted readValue() {
        DecoderImpl decoder = getDecoder();
        byte typeCode = decoder.getBuffer().get();

        switch (typeCode) {
            case EncodingCodes.LIST0:
                break;
            case EncodingCodes.LIST8:
                decoder.getBuffer().get();
                decoder.getBuffer().get();
                break;
            case EncodingCodes.LIST32:
                decoder.getBuffer().getInt();
                decoder.getBuffer().getInt();
                break;
            default:
            {
                logError("Incorrect type found in Accepted type encoding %d",typeCode);
                break;
            }
               // throw new DecodeException("Incorrect type found in Accepted type encoding: " ~ typeCode);

        }

        return Accepted.getInstance();
    }

    public void skipValue() {
        //implementationMissing(false);
        getDecoder().readConstructor().skipValue();
    }

    override
    public void write(Object v) {
        Accepted accepted = cast(Accepted)v;
        WritableBuffer buffer = getEncoder().getBuffer();
        buffer.put(ACCEPTED_ENCODED_BYTES, 0, cast(int)ACCEPTED_ENCODED_BYTES.length);
    }

    public static void register(Decoder decoder, EncoderImpl encoder) {
        FastPathAcceptedType type = new FastPathAcceptedType(encoder);
       // implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS) {
            decoder.registerFastPath(descriptor,  type);
        }
        encoder.register(type);
    }
}
