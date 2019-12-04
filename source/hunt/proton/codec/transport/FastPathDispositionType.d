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
module hunt.proton.codec.transport.FastPathDispositionType;

import hunt.collection.Collection;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Accepted;
import hunt.proton.amqp.messaging.Released;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.amqp.transport.Disposition;
import hunt.proton.amqp.transport.Role;
import hunt.proton.codec.AMQPType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.FastPathDescribedTypeConstructor;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.WritableBuffer;
import std.concurrency : initOnce;
import hunt.logging;
import hunt.proton.codec.transport.DispositionType;
import hunt.Boolean;
import hunt.Exceptions;
import std.conv : to;

class FastPathDispositionType : AMQPType!(Disposition), FastPathDescribedTypeConstructor!(Disposition) {

    private static byte DESCRIPTOR_CODE = 0x15;
    private static byte ACCEPTED_DESCRIPTOR_CODE = 0x24;

    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:disposition:list"),
    //};

     static Object[]  DESCRIPTORS() {
         __gshared Object[]  inst;
         return initOnce!inst([UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:disposition:list")]);
     }

    static byte[]  ACCEPTED_ENCODED_BYTES() {
        __gshared byte[]  inst;
        return initOnce!inst([ EncodingCodes.DESCRIBED_TYPE_INDICATOR,
        EncodingCodes.SMALLULONG,
        ACCEPTED_DESCRIPTOR_CODE,
        EncodingCodes.LIST0]);
    }


    //private static byte[] ACCEPTED_ENCODED_BYTES = [
    //    EncodingCodes.DESCRIBED_TYPE_INDICATOR,
    //    EncodingCodes.SMALLULONG,
    //    ACCEPTED_DESCRIPTOR_CODE,
    //    EncodingCodes.LIST0
    //];

    private DispositionType dispositionType;

    this(EncoderImpl encoder) {
        this.dispositionType = new DispositionType(encoder);
    }

    public EncoderImpl getEncoder() {
        return dispositionType.getEncoder();
    }

    public DecoderImpl getDecoder() {
        return dispositionType.getDecoder();
    }

    override
    public bool encodesJavaPrimitive() {
        return false;
    }

    override
    public TypeInfo getTypeClass() {
        return typeid(Disposition);
    }

    override
    public ITypeEncoding getEncoding(Object disposition) {
        return dispositionType.getEncoding(cast(Disposition)disposition);
    }

    override
    public TypeEncoding!(Disposition) getCanonicalEncoding() {
        return dispositionType.getCanonicalEncoding();
    }

    override
    public Collection!(TypeEncoding!(Disposition)) getAllEncodings() {
        return dispositionType.getAllEncodings();
    }

    override
    public Disposition readValue() {
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
                logError("Incorrect type found in Disposition encoding: %d",typeCode);
                return null;
            }
        }

        Disposition disposition = new Disposition();

        for (int index = 0; index < count; ++index) {
            switch (index) {
                case 0:
                    disposition.setRole(Boolean.TRUE == (decoder.readBoolean()) ? Role.RECEIVER : Role.SENDER);
                    break;
                case 1:
                    disposition.setFirst(decoder.readUnsignedInteger(null));
                    break;
                case 2:
                    disposition.setLast(decoder.readUnsignedInteger(null));
                    break;
                case 3:
                    disposition.setSettled(decoder.readBoolean(Boolean.FALSE()));
                    break;
                case 4:
                    disposition.setState(cast(DeliveryState) decoder.readObject());
                    break;
                case 5:
                    disposition.setBatchable(decoder.readBoolean(Boolean.FALSE()));
                    break;
                default:
                    throw new IllegalStateException("To many entries in Disposition encoding");
            }
        }

        return disposition;
    }

    override
    public void skipValue() {
        getDecoder().readConstructor().skipValue();
    }

    override
    public void write(Object v) {

        Disposition disposition = cast(Disposition)v;

        WritableBuffer buffer = getEncoder().getBuffer();
        int count = getElementCount(disposition);
        byte encodingCode = deduceEncodingCode(disposition, count);

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
            writeElement(disposition, i);
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

    private void writeElement(Disposition disposition, int index) {
        switch (index) {
            case 0:
                getEncoder().writeBoolean(disposition.getRole().getValue());
                break;
            case 1:
                getEncoder().writeUnsignedInteger(disposition.getFirst());
                break;
            case 2:
                getEncoder().writeUnsignedInteger(disposition.getLast());
                break;
            case 3:
                getEncoder().writeBoolean(disposition.getSettled());
                break;
            case 4:
                if (Accepted.getInstance().getType == disposition.getState().getType) {
                    getEncoder().getBuffer().put(ACCEPTED_ENCODED_BYTES, 0, cast(int)ACCEPTED_ENCODED_BYTES.length);
                } else {
                  //  getEncoder().writeObject(disposition.getState());
                    implementationMissing(false);
                }
                break;
            case 5:
                getEncoder().writeBoolean(disposition.getBatchable());
                break;
            default:
                throw new IllegalArgumentException("Unknown Disposition value index: " ~ to!string(index));
        }
    }

    private int getElementCount(Disposition disposition) {
        if (disposition.getBatchable().booleanValue()) {
            return 6;
        } else if (disposition.getState() !is null) {
            return 5;
        } else if (disposition.getSettled().booleanValue) {
            return 4;
        } else if (disposition.getLast() !is null) {
            return 3;
        } else {
            return 2;
        }
    }

    private byte deduceEncodingCode(Disposition value, int elementCount) {
        if (value.getState() is null) {
            return EncodingCodes.LIST8;
        } else if (value.getState().getType() == Accepted.getInstance().getType() || value.getState().getType() == Released.getInstance().getType()) { //TODO
            return EncodingCodes.LIST8;
        } else {
            return EncodingCodes.LIST32;
        }
    }

    public static void register(Decoder decoder, EncoderImpl encoder) {
        FastPathDispositionType type = new FastPathDispositionType(encoder);
        foreach(Object descriptor ; DESCRIPTORS) {
            decoder.registerFastPath(descriptor,  type);
        }
        encoder.register(type);
    }
}
