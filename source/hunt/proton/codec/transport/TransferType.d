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


module hunt.proton.codec.transport.TransferType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedByte;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.amqp.transport.ReceiverSettleMode;
import hunt.proton.amqp.transport.Transfer;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Boolean;
import std.concurrency : initOnce;
import hunt.logging;

class TransferWrapper : AbstractList!Object
{

    private Transfer _transfer;

    this(Transfer transfer)
    {
        _transfer = transfer;
    }

    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _transfer.getHandle();
            case 1:
            return _transfer.getDeliveryId();
            case 2:
            return _transfer.getDeliveryTag();
            case 3:
            return _transfer.getMessageFormat();
            case 4:
            return _transfer.getSettled();
            case 5:
            return _transfer.getMore();
            case 6:
            return _transfer.getRcvSettleMode() is null ? null : _transfer.getRcvSettleMode().getValue();
            case 7:
            return cast(Object)_transfer.getState();
            case 8:
            return _transfer.getResume();
            case 9:
            return _transfer.getAborted();
            case 10:
            return _transfer.getBatchable();
            default:
            return null;
        }

        // throw new IllegalStateException("Unknown index " ~ index);

    }

    override
    public int size()
    {
        return _transfer.getBatchable().booleanValue
        ? 11
        : _transfer.getAborted().booleanValue
        ? 10
        : _transfer.getResume().booleanValue
        ? 9
        : _transfer.getState() !is null
        ? 8
        : _transfer.getRcvSettleMode() !is null
        ? 7
        : _transfer.getMore().booleanValue
        ? 6
        : _transfer.getSettled() !is null
        ? 5
        : _transfer.getMessageFormat() !is null
        ? 4
        : _transfer.getDeliveryTag() !is null
        ? 3
        : _transfer.getDeliveryId() !is null
        ? 2
        : 1;

    }

}


class TransferType : AbstractDescribedType!(Transfer,List!Object) , DescribedTypeConstructor!(Transfer)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000014L), Symbol.valueOf("amqp:transfer:list"),
    //};
    //
    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000014L);

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000014L), Symbol.valueOf("amqp:transfer:list")]);
    }

         static UnsignedLong  DESCRIPTOR() {
             __gshared UnsignedLong  inst;
             return initOnce!inst(UnsignedLong.valueOf(0x0000000000000014L));
         }

    this(EncoderImpl encoder)
    {
        super(encoder);
    }


    override
    public UnsignedLong getDescriptor()
    {
        return DESCRIPTOR;
    }

    override
    protected List!Object wrap(Transfer val)
    {
        return new TransferWrapper(val);
    }



        public Transfer newInstance(Object described)
        {
            List!Object l = cast(List!Object) described;

            Transfer o = new Transfer();

            if(l.isEmpty())
            {
                logError("The handle field cannot be omitted");
                return null;
               // throw new DecodeException("The handle field cannot be omitted");
            }

            switch(11 - l.size())
            {

                case 0:
                    Boolean batchable = cast(Boolean) l.get(10);
                    o.setBatchable(batchable is null ? null : batchable);
                    goto case;
                case 1:
                    Boolean aborted = cast(Boolean) l.get(9);
                    o.setAborted(aborted is null ? null : aborted);
                    goto case;
                case 2:
                    Boolean resume = cast(Boolean) l.get(8);
                    o.setResume(resume is null ? null : resume);
                    goto case;
                case 3:
                    o.setState( cast(DeliveryState) l.get( 7 ) );
                    goto case;
                case 4:
                    UnsignedByte receiverSettleMode = cast(UnsignedByte) l.get(6);
                    o.setRcvSettleMode(receiverSettleMode is null ? null : ReceiverSettleMode.valueOf(receiverSettleMode));
                    goto case;
                case 5:
                    Boolean more = cast(Boolean) l.get(5);
                    o.setMore(more is null ? null : more );
                    goto case;
                case 6:
                    o.setSettled( cast(Boolean) l.get( 4 ) );
                    goto case;
                case 7:
                    o.setMessageFormat( cast(UnsignedInteger) l.get( 3 ) );
                    goto case;
                case 8:
                    o.setDeliveryTag( cast(Binary) l.get( 2 ) );
                    goto case;
                case 9:
                    o.setDeliveryId( cast(UnsignedInteger) l.get( 1 ) );
                    goto case;
                case 10:
                    o.setHandle( cast(UnsignedInteger) l.get( 0 ) );
                    break;
                default:
                    break;
            }


            return o;
        }

        public TypeInfo getTypeClass()
        {
            return typeid(Transfer);
        }

    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        TransferType type = new TransferType(encoder);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
