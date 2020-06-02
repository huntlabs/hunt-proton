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
module hunt.proton.codec.messaging.FastPathHeaderType;

import hunt.collection.Collection;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Header;
import hunt.proton.codec.AMQPType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.FastPathDescribedTypeConstructor;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.WritableBuffer;
import hunt.Exceptions;

import hunt.proton.codec.messaging.HeaderType;
import std.concurrency : initOnce;
import hunt.logging;
import std.conv : to;

class FastPathHeaderType : AMQPType!(Header), FastPathDescribedTypeConstructor!(Header) {

    private static byte DESCRIPTOR_CODE = 0x70;

    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:header:list"),
    //};


    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:header:list")]);
    }


    private HeaderType headerType;

    this(EncoderImpl encoder) {
        this.headerType = new HeaderType(encoder);
    }

    public EncoderImpl getEncoder() {
        return headerType.getEncoder();
    }

    public DecoderImpl getDecoder() {
        return headerType.getDecoder();
    }

    override
    public Header readValue() {
        DecoderImpl decoder = getDecoder();
        ReadableBuffer buffer = decoder.getBuffer();
        byte typeCode = decoder.getBuffer().get();

        int size = 0;
        int count = 0;

        switch (typeCode) {
            case EncodingCodes.LIST0:
                break;
            case EncodingCodes.LIST8:
                size = buffer.get() & 0xff;
                count = buffer.get() & 0xff;
                break;
            case EncodingCodes.LIST32:
                size = buffer.getInt();
                count = buffer.getInt();
                break;
            default:
            {
                logError("Incorrect type found in Header encoding: %d",typeCode);
                break;
            }
               // throw new DecodeException("Incorrect type found in Header encoding: " ~ typeCode);
        }

        Header header = new Header();

        for (int index = 0; index < count; ++index) {
            switch (index) {
                case 0:
                    header.setDurable(decoder.readBoolean(null));
                    break;
                case 1:
                    header.setPriority(decoder.readUnsignedByte(null));
                    break;
                case 2:
                    header.setTtl(decoder.readUnsignedInteger(null));
                    break;
                case 3:
                    header.setFirstAcquirer(decoder.readBoolean(null));
                    break;
                case 4:
                    header.setDeliveryCount(decoder.readUnsignedInteger(null));
                    break;
                default:
                    throw new IllegalStateException("To many entries in Header encoding");
            }
        }

        return header;
    }

    override
    public void skipValue() {
        //implementationMissing(false);
       getDecoder().readConstructor().skipValue();
    }

    override
    public bool encodesJavaPrimitive() {
        return false;
    }

    override
    public TypeInfo getTypeClass() {
        return typeid(Header);
    }

    override
    public ITypeEncoding getEncoding(Object header) {
        return headerType.getEncoding(cast(Header)header);
    }

    override
    public TypeEncoding!(Header) getCanonicalEncoding() {
        return headerType.getCanonicalEncoding();
    }

    override
    public  Collection!(TypeEncoding!(Header)) getAllEncodings() {
        return headerType.getAllEncodings();
    }

    override
    public void write(Object  v) {
        Header value = cast(Header)v;
        WritableBuffer buffer = getEncoder().getBuffer();
        int count = getElementCount(value);
        byte encodingCode = deduceEncodingCode(value, count);

        buffer.put(EncodingCodes.DESCRIBED_TYPE_INDICATOR);
        buffer.put(EncodingCodes.SMALLULONG);
        buffer.put(DESCRIPTOR_CODE);
        buffer.put(encodingCode);

        // Optimized step, no other data to be written.
        if (encodingCode == EncodingCodes.LIST0) {
            return;
        }

        int fieldWidth;

        if (encodingCode == EncodingCodes.LIST8) {
            fieldWidth = 1;
        } else {
            fieldWidth = 4;
        }

        int startIndex = buffer.position();

        // Reserve space for the size and write the count of list elements.
        if (fieldWidth == 1) {
            buffer.put(cast(byte) 0);
            buffer.put(cast(byte) count);
        } else {
            buffer.putInt(0);
            buffer.putInt(count);
        }

        // Write the list elements and then compute total size written.
        for (int i = 0; i < count; ++i) {
            writeElement(value, i);
        }

        // Move back and write the size
        int endIndex = buffer.position();
        int writeSize = endIndex - startIndex - fieldWidth;

        buffer.position(startIndex);
        if (fieldWidth == 1) {
            buffer.put(cast(byte) writeSize);
        } else {
            buffer.putInt(writeSize);
        }
        buffer.position(endIndex);
    }

    private void writeElement(Header header, int index) {
        switch (index) {
            case 0:
                getEncoder().writeBoolean(header.getDurable());
                break;
            case 1:
                getEncoder().writeUnsignedByte(header.getPriority());
                break;
            case 2:
                getEncoder().writeUnsignedInteger(header.getTtl());
                break;
            case 3:
                getEncoder().writeBoolean(header.getFirstAcquirer());
                break;
            case 4:
                getEncoder().writeUnsignedInteger(header.getDeliveryCount());
                break;
            default:
                throw new IllegalArgumentException("Unknown Header value index: " ~ to!string(index));
        }
    }

    private int getElementCount(Header header) {
        if (header.getDeliveryCount() !is null) {
            return 5;
        } else if (header.getFirstAcquirer() !is null) {
            return 4;
        } else if (header.getTtl() !is null) {
            return 3;
        } else if (header.getPriority() !is null) {
            return 2;
        } else if (header.getDurable() !is null) {
            return 1;
        } else {
            return 0;
        }
    }

    private byte deduceEncodingCode(Header value, int elementCount) {
        if (elementCount == 0) {
            return EncodingCodes.LIST0;
        } else {
            return EncodingCodes.LIST8;
        }
    }

    public static void register(Decoder decoder, EncoderImpl encoder) {
        FastPathHeaderType type = new FastPathHeaderType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerFastPath(descriptor,  type);
        }
        encoder.register(type);
    }
}
