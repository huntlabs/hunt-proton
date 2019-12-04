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
module hunt.proton.codec.transport.FastPathFlowType;

import hunt.collection.Collection;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.Flow;
import hunt.proton.codec.AMQPType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.FastPathDescribedTypeConstructor;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.WritableBuffer;
import  hunt.proton.codec.transport.FlowType;
import std.concurrency : initOnce;
import hunt.Exceptions;
import hunt.logging;
import hunt.Boolean;
import std.conv : to;

class FastPathFlowType : AMQPType!(Flow), FastPathDescribedTypeConstructor!(Flow) {

    private static byte DESCRIPTOR_CODE = 0x13;

    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:flow:list"),
    //};
  static Object[]  DESCRIPTORS() {
      __gshared Object[]  inst;
      return initOnce!inst([UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:flow:list")]);
  }


    private FlowType flowType;

    this(EncoderImpl encoder) {
        this.flowType = new FlowType(encoder);
    }

    public EncoderImpl getEncoder() {
        return flowType.getEncoder();
    }

    public DecoderImpl getDecoder() {
        return flowType.getDecoder();
    }

    override
    public bool encodesJavaPrimitive() {
        return false;
    }

    override
    public TypeInfo getTypeClass() {
        return typeid(Flow);
    }

    override
    public ITypeEncoding getEncoding(Object flow) {
        return flowType.getEncoding(cast(Flow)flow);
    }

    override
    public TypeEncoding!(Flow) getCanonicalEncoding() {
        return flowType.getCanonicalEncoding();
    }

    override
    public Collection!(TypeEncoding!(Flow)) getAllEncodings() {
        return flowType.getAllEncodings();
    }

    override
    public Flow readValue() {
        DecoderImpl decoder = getDecoder();
        byte typeCode = decoder.getBuffer().get();

        int size = 0;
        int count = 0;

        switch (typeCode) {
            case EncodingCodes.LIST0:
                // TODO - Technically invalid however old decoder also allowed this.
                break;
            case EncodingCodes.LIST8:
                size = (cast(int)decoder.getBuffer().get()) & 0xff;
                count = (cast(int)decoder.getBuffer().get()) & 0xff;
                break;
            case EncodingCodes.LIST32:
                size = decoder.getBuffer().getInt();
                count = decoder.getBuffer().getInt();
                break;
            default:
            {
                logError("Incorrect type found in Flow encoding %d", typeCode);
                break;
            }
                //throw new DecodeException("Incorrect type found in Flow encoding: " ~ typeCode);
        }

        Flow flow = new Flow();

        for (int index = 0; index < count; ++index) {
            switch (index) {
                case 0:
                    flow.setNextIncomingId(decoder.readUnsignedInteger(null));
                    break;
                case 1:
                    flow.setIncomingWindow(decoder.readUnsignedInteger(null));
                    break;
                case 2:
                    flow.setNextOutgoingId(decoder.readUnsignedInteger(null));
                    break;
                case 3:
                    flow.setOutgoingWindow(decoder.readUnsignedInteger(null));
                    break;
                case 4:
                    flow.setHandle(decoder.readUnsignedInteger(null));
                    break;
                case 5:
                    flow.setDeliveryCount(decoder.readUnsignedInteger(null));
                    break;
                case 6:
                    flow.setLinkCredit(decoder.readUnsignedInteger(null));
                    break;
                case 7:
                    flow.setAvailable(decoder.readUnsignedInteger(null));
                    break;
                case 8:
                    flow.setDrain(new Boolean(decoder.readBoolean(false)));
                    break;
                case 9:
                    flow.setEcho(new Boolean( decoder.readBoolean(false)));
                    break;
                case 10:
                    implementationMissing(false);
                    //flow.setProperties(decoder.readMap());
                    break;
                default:
                    throw new IllegalStateException("To many entries in Flow encoding");
            }
        }

        return flow;
    }

    override
    public void skipValue() {
        getDecoder().readConstructor().skipValue();
    }

    override
    public void write(Object v) {

        Flow flow = cast(Flow)v;

        WritableBuffer buffer = getEncoder().getBuffer();
        int count = getElementCount(flow);
        byte encodingCode = deduceEncodingCode(flow, count);

        buffer.put(EncodingCodes.DESCRIBED_TYPE_INDICATOR);
        buffer.put(EncodingCodes.SMALLULONG);
        buffer.put(DESCRIPTOR_CODE);
        buffer.put(encodingCode);

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
            writeElement(flow, i);
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

    private void writeElement(Flow flow, int index) {
        switch (index) {
            case 0:
                getEncoder().writeUnsignedInteger(flow.getNextIncomingId());
                break;
            case 1:
                getEncoder().writeUnsignedInteger(flow.getIncomingWindow());
                break;
            case 2:
                getEncoder().writeUnsignedInteger(flow.getNextOutgoingId());
                break;
            case 3:
                getEncoder().writeUnsignedInteger(flow.getOutgoingWindow());
                break;
            case 4:
                getEncoder().writeUnsignedInteger(flow.getHandle());
                break;
            case 5:
                getEncoder().writeUnsignedInteger(flow.getDeliveryCount());
                break;
            case 6:
                getEncoder().writeUnsignedInteger(flow.getLinkCredit());
                break;
            case 7:
                getEncoder().writeUnsignedInteger(flow.getAvailable());
                break;
            case 8:
                getEncoder().writeBoolean(flow.getDrain());
                break;
            case 9:
                getEncoder().writeBoolean(flow.getEcho());
                break;
            case 10:
                implementationMissing( false);
                //getEncoder().writeMap(flow.getProperties());
                break;
            default:
                throw new IllegalArgumentException("Unknown Flow value index: " ~ to!string (index));
        }
    }

    private int getElementCount(Flow flow) {
        if (flow.getProperties() !is null) {
            return 11;
        } else if (flow.getEcho().booleanValue()) {
            return 10;
        } else if (flow.getDrain().booleanValue()) {
            return 9;
        } else if (flow.getAvailable() !is null) {
            return 8;
        } else if (flow.getLinkCredit() !is null) {
            return 7;
        } else if (flow.getDeliveryCount() !is null) {
            return 6;
        } else if (flow.getHandle() !is null) {
            return 5;
        } else {
            return 4;
        }
    }

    private byte deduceEncodingCode(Flow value, int elementCount) {
        if (value.getProperties() is null) {
            return EncodingCodes.LIST8;
        } else {
            return EncodingCodes.LIST32;
        }
    }

    public static void register(Decoder decoder, EncoderImpl encoder) {
        FastPathFlowType type = new FastPathFlowType(encoder);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerFastPath(descriptor, type);
        }
        encoder.register(type);
    }
}
