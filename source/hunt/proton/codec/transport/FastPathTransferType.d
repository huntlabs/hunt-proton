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
module hunt.proton.codec.transport.FastPathTransferType;

import hunt.collection.Collection;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedByte;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.amqp.transport.ReceiverSettleMode;
import hunt.proton.amqp.transport.Transfer;
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
import hunt.proton.codec.transport.TransferType;
import hunt.Exceptions;
import hunt.Boolean;
import std.conv : to;
/**
 * Fast TrasnferType encoder
 */
class FastPathTransferType : AMQPType!(Transfer), FastPathDescribedTypeConstructor!(Transfer) {

    private static byte DESCRIPTOR_CODE = 0x14;

    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:transfer:list"),
    //};

     static Object[]  DESCRIPTORS() {
         __gshared Object[]  inst;
         return initOnce!inst([UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:transfer:list")]);
     }

    private TransferType transferType;

    this(EncoderImpl encoder) {
        this.transferType = new TransferType(encoder);
    }

    public EncoderImpl getEncoder() {
        return transferType.getEncoder();
    }

    public DecoderImpl getDecoder() {
        return transferType.getDecoder();
    }

    override
    public Object readValue() {
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
                logError("Incorrect type found in Transfer encoding: %d",typeCode);
                return null;
            }
              //  throw new DecodeException("Incorrect type found in Transfer encoding: " ~ typeCode);
        }

        Transfer transfer = new Transfer();

        for (int index = 0; index < count; ++index) {
            switch (index) {
                case 0:
                    transfer.setHandle(decoder.readUnsignedInteger(null));
                    break;
                case 1:
                    transfer.setDeliveryId(decoder.readUnsignedInteger(null));
                    break;
                case 2:
                    transfer.setDeliveryTag(decoder.readBinary(null));
                    break;
                case 3:
                    transfer.setMessageFormat(decoder.readUnsignedInteger(null));
                    break;
                case 4:
                    transfer.setSettled(decoder.readBoolean(null));
                    break;
                case 5:
                    transfer.setMore(decoder.readBoolean(Boolean.FALSE));
                    break;
                case 6:
                    UnsignedByte rcvSettleMode = decoder.readUnsignedByte();
                    transfer.setRcvSettleMode(rcvSettleMode is null ? null : ReceiverSettleMode.valueOf(rcvSettleMode));
                    break;
                case 7:
                    transfer.setState(cast(DeliveryState) decoder.readObject());
                    break;
                case 8:
                    transfer.setResume(decoder.readBoolean(Boolean.FALSE));
                    break;
                case 9:
                    transfer.setAborted(decoder.readBoolean(Boolean.FALSE));
                    break;
                case 10:
                    transfer.setBatchable(decoder.readBoolean(Boolean.FALSE));
                    break;
                default:
                    throw new IllegalStateException("To many entries in Transfer encoding");
            }
        }

        return transfer;
    }

    override
    public void skipValue() {
        getDecoder().readConstructor().skipValue();
    }

    override
    public bool encodesJavaPrimitive() {
        return false;
    }

    override
    public TypeInfo getTypeClass() {
        return typeid(Transfer);
    }

    override
    public ITypeEncoding getEncoding(Object transfer) {
        return transferType.getEncoding(cast(Transfer)transfer);
    }

    override
    public TypeEncoding!(Transfer) getCanonicalEncoding() {
        return transferType.getCanonicalEncoding();
    }

    override
    public Collection!(TypeEncoding!(Transfer))getAllEncodings() {
        return transferType.getAllEncodings();
    }

    override
    public void write(Object v) {

        Transfer value = cast(Transfer)v;

        WritableBuffer buffer = getEncoder().getBuffer();
        int count = getElementCount(value);
        byte encodingCode = deduceEncodingCode(value, count);

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

    private void writeElement(Transfer transfer, int index) {
        switch (index) {
            case 0:
                getEncoder().writeUnsignedInteger(transfer.getHandle());
                break;
            case 1:
                getEncoder().writeUnsignedInteger(transfer.getDeliveryId());
                break;
            case 2:
                getEncoder().writeBinary(transfer.getDeliveryTag());
                break;
            case 3:
                getEncoder().writeUnsignedInteger(transfer.getMessageFormat());
                break;
            case 4:
                getEncoder().writeBoolean(transfer.getSettled());
                break;
            case 5:
                getEncoder().writeBoolean(transfer.getMore());
                break;
            case 6:
                ReceiverSettleMode rcvSettleMode = transfer.getRcvSettleMode();
                getEncoder().writeObject(rcvSettleMode is null ? null : rcvSettleMode.getValue());
                break;
            case 7:
                getEncoder().writeObject(cast(Object)(transfer.getState()));
               // implementationMissing(false);
                break;
            case 8:
                getEncoder().writeBoolean(transfer.getResume());
                break;
            case 9:
                getEncoder().writeBoolean(transfer.getAborted());
                break;
            case 10:
                getEncoder().writeBoolean(transfer.getBatchable());
                break;
            default:
                throw new IllegalArgumentException("Unknown Transfer value index: " ~ to!string(index));
        }
    }

    private byte deduceEncodingCode(Transfer value, int elementCount) {
        if (value.getState() !is null) {
            return EncodingCodes.LIST32;
        } else if (value.getDeliveryTag() !is null && value.getDeliveryTag().getLength() > 200) {
            return EncodingCodes.LIST32;
        } else {
            return EncodingCodes.LIST8;
        }
    }

    private int getElementCount(Transfer transfer) {
        if (transfer.getBatchable().booleanValue) {
            return 11;
        } else if (transfer.getAborted().booleanValue) {
            return 10;
        } else if (transfer.getResume().booleanValue) {
            return 9;
        } else if (transfer.getState() !is null) {
            return 8;
        } else if (transfer.getRcvSettleMode() !is null) {
            return 7;
        } else if (transfer.getMore().booleanValue) {
            return 6;
        } else if (transfer.getSettled() !is null) {
            return 5;
        } else if (transfer.getMessageFormat() !is null) {
            return 4;
        } else if (transfer.getDeliveryTag() !is null) {
            return 3;
        } else if (transfer.getDeliveryId() !is null) {
            return 2;
        } else {
            return 1;
        }
    }

    public static void register(Decoder decoder, EncoderImpl encoder) {
        FastPathTransferType type = new FastPathTransferType(encoder);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerFastPath(descriptor,  type);
        }
        encoder.register(type);
    }
}
