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


module hunt.proton.codec.transport.DispositionType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.amqp.transport.Disposition;
import hunt.proton.amqp.transport.Role;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import std.concurrency : initOnce;
import hunt.Boolean;
import hunt.logging;

class DispositionWrapper : AbstractList!Object
{

    private Disposition _disposition;

    this(Disposition disposition)
    {
        _disposition = disposition;
    }

    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return new Boolean( _disposition.getRole().getValue());
            case 1:
            return _disposition.getFirst();
            case 2:
            return _disposition.getLast();
            case 3:
            return _disposition.getSettled();
            case 4:
            return  cast(Object)(_disposition.getState());
            case 5:
            return _disposition.getBatchable();
            default:
            return null;
        }

        // throw new IllegalStateException("Unknown index " ~ index);

    }

    override
    public int size()
    {
        return _disposition.getBatchable().booleanValue()
        ? 6
        : _disposition.getState() !is null
        ? 5
        : _disposition.getSettled().booleanValue()
        ? 4
        : _disposition.getLast() !is null
        ? 3
        : 2;

    }
}

class DispositionType : AbstractDescribedType!(Disposition,List!Object) , DescribedTypeConstructor!(Disposition)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000015L), Symbol.valueOf("amqp:disposition:list"),
    //};
    //
    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000015L);

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000015L), Symbol.valueOf("amqp:disposition:list")]);
    }

         static UnsignedLong  DESCRIPTOR() {
             __gshared UnsignedLong  inst;
             return initOnce!inst(UnsignedLong.valueOf(0x0000000000000015L));
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
    protected List!Object wrap(Disposition val)
    {
        return new DispositionWrapper(val);
    }




        public Disposition newInstance(Object described)
        {
            List!Object l = cast(List!Object) described;

            Disposition o = new Disposition();

            if(l.isEmpty())
            {
               // throw new DecodeException("The first field cannot be omitted");
                logError("The first field cannot be omitted");
                return null;
            }

            switch(6 - l.size())
            {

                case 0:
                    Boolean batchable = cast(Boolean) l.get(5);
                    o.setBatchable(batchable is null ? null : batchable);
                    goto case;
                case 1:
                    o.setState( cast(DeliveryState) l.get( 4 ) );
                    goto case;
                case 2:
                    Boolean settled = cast(Boolean) l.get(3);
                    o.setSettled(settled is null ? null : settled);
                    goto case;
                case 3:
                    o.setLast( cast(UnsignedInteger) l.get( 2 ) );
                    goto case;
                case 4:
                    o.setFirst( cast(UnsignedInteger) l.get( 1 ) );
                    goto case;
                case 5:
                    Boolean tmp =  cast(Boolean) l.get( 0 );
                    o.setRole( tmp.booleanValue() ? Role.RECEIVER : Role.SENDER );
                    break;
                default:
                    break;
            }


            return o;
        }

        public TypeInfo getTypeClass()
        {
            return typeid(Disposition);
        }




    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        DispositionType type = new DispositionType(encoder);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }


}
