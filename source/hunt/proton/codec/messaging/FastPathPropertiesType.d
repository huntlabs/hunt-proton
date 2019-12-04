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

module hunt.proton.codec.messaging.FastPathPropertiesType;

import hunt.collection.Collection;

import hunt.proton.codec.messaging.PropertiesType;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Properties;
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
import std.concurrency : initOnce;
import hunt.logging;
import std.conv : to;
import hunt.String;

class FastPathPropertiesType : AMQPType!(Properties), FastPathDescribedTypeConstructor!(Properties) {

    private static byte DESCRIPTOR_CODE = 0x73;

    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:properties:list"),
    //};

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:properties:list")]);
    }


    private PropertiesType propertiesType;

    this(EncoderImpl encoder) {
        this.propertiesType = new PropertiesType(encoder);
    }

    public EncoderImpl getEncoder() {
        return propertiesType.getEncoder();
    }

    public DecoderImpl getDecoder() {
        return propertiesType.getDecoder();
    }

    override
    public Properties readValue() {
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
                logError("Incorrect type found in Properties encoding: %d", typeCode);
                break;
            }
               // throw new DecodeException("Incorrect type found in Properties encoding: " ~ typeCode);
        }

        Properties properties = new Properties();

        for (int index = 0; index < count; ++index) {
            switch (index) {
                case 0:
                    properties.setMessageId(cast(String)decoder.readObject());
                    break;
                case 1:
                    properties.setUserId(decoder.readBinary(null));
                    break;
                case 2:
                    properties.setTo(decoder.readString(null));
                    break;
                case 3:
                    properties.setSubject(decoder.readString(null));
                    break;
                case 4:
                    properties.setReplyTo(decoder.readString(null));
                    break;
                case 5:
                    properties.setCorrelationId(cast(String)decoder.readObject());
                    break;
                case 6:
                    properties.setContentType(decoder.readSymbol(null));
                    break;
                case 7:
                    properties.setContentEncoding(decoder.readSymbol(null));
                    break;
                case 8:
                    properties.setAbsoluteExpiryTime(decoder.readTimestamp(null));
                    break;
                case 9:
                    properties.setCreationTime(decoder.readTimestamp(null));
                    break;
                case 10:
                    properties.setGroupId(decoder.readString(null));
                    break;
                case 11:
                    properties.setGroupSequence(decoder.readUnsignedInteger(null));
                    break;
                case 12:
                    properties.setReplyToGroupId(decoder.readString(null));
                    break;
                default:
                    throw new IllegalStateException("To many entries in Properties encoding");
            }
        }

        return properties;
    }

    override
    public void skipValue() {
       // implementationMissing(false);
        getDecoder().readConstructor().skipValue();
    }

    override
    public bool encodesJavaPrimitive() {
        return false;
    }

    override
    public TypeInfo getTypeClass() {
        return typeid(Properties);
    }

    override
    public ITypeEncoding getEncoding(Object properties) {
        return propertiesType.getEncoding(cast(Properties)properties);
    }

    override
    public TypeEncoding!(Properties) getCanonicalEncoding() {
        return propertiesType.getCanonicalEncoding();
    }

    override
    public  Collection!(TypeEncoding!(Properties)) getAllEncodings() {
        return propertiesType.getAllEncodings();
    }

    override
    public void write(Object v) {
        Properties value = cast(Properties) v;
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

    private byte deduceEncodingCode(Properties value, int elementCount) {
        if (elementCount == 0) {
            return EncodingCodes.LIST0;
        } else {
            return EncodingCodes.LIST32;
        }
    }

    private void writeElement(Properties properties, int index) {
        switch (index) {
            case 0:
                getEncoder().writeObject(properties.getMessageId());
                break;
            case 1:
                getEncoder().writeBinary(properties.getUserId());
                break;
            case 2:
                getEncoder().writeString(properties.getTo());
                break;
            case 3:
                getEncoder().writeString(properties.getSubject());
                break;
            case 4:
                getEncoder().writeString(properties.getReplyTo());
                break;
            case 5:
                getEncoder().writeObject(properties.getCorrelationId());
                break;
            case 6:
                getEncoder().writeSymbol(properties.getContentType());
                break;
            case 7:
                getEncoder().writeSymbol(properties.getContentEncoding());
                break;
            case 8:
                getEncoder().writeTimestamp(properties.getAbsoluteExpiryTime());
                break;
            case 9:
                getEncoder().writeTimestamp(properties.getCreationTime());
                break;
            case 10:
                getEncoder().writeString(properties.getGroupId());
                break;
            case 11:
                getEncoder().writeUnsignedInteger(properties.getGroupSequence());
                break;
            case 12:
                getEncoder().writeString(properties.getReplyToGroupId());
                break;
            default:
                throw new IllegalArgumentException("Unknown Properties value index: " ~ to!string(index));
        }
    }

    private int getElementCount(Properties properties) {
        if (properties.getReplyToGroupId() !is null) {
            return 13;
        } else if (properties.getGroupSequence() !is null) {
            return 12;
        } else if (properties.getGroupId() !is null) {
            return 11;
        } else if (properties.getCreationTime() !is null) {
            return 10;
        } else if (properties.getAbsoluteExpiryTime() !is null) {
            return 9;
        } else if (properties.getContentEncoding() !is null) {
            return 8;
        } else if (properties.getContentType() !is null) {
            return 7;
        } else if (properties.getCorrelationId() !is null) {
            return 6;
        } else if (properties.getReplyTo() !is null) {
            return 5;
        } else if (properties.getSubject() !is null) {
            return 4;
        } else if (properties.getTo() !is null) {
            return 3;
        } else if (properties.getUserId() !is null) {
            return 2;
        } else if (properties.getMessageId() !is null) {
            return 1;
        }

        return 0;
    }

    public static void register(Decoder decoder, EncoderImpl encoder) {
        FastPathPropertiesType type = new FastPathPropertiesType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS) {
            decoder.registerFastPath(descriptor,  type);
        }
        encoder.register(type);
    }
}
