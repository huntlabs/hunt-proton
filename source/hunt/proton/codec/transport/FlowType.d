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


module hunt.proton.codec.transport.FlowType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.Flow;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import std.concurrency : initOnce;
import hunt.logging;
import hunt.Object;
import hunt.Boolean;

class FlowWrapper : AbstractList!Object
{


    private Flow _flow;

    this(Flow flow)
    {
        _flow = flow;
    }

    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _flow.getNextIncomingId();
            case 1:
            return _flow.getIncomingWindow();
            case 2:
            return _flow.getNextOutgoingId();
            case 3:
            return _flow.getOutgoingWindow();
            case 4:
            return _flow.getHandle();
            case 5:
            return _flow.getDeliveryCount();
            case 6:
            return _flow.getLinkCredit();
            case 7:
            return _flow.getAvailable();
            case 8:
            return _flow.getDrain();
            case 9:
            return _flow.getEcho();
            case 10:
            return cast(Object) _flow.getProperties();
            default:
            return null;
        }

        //   throw new IllegalStateException("Unknown index " ~ index);

    }

    override
    public int size()
    {
        return _flow.getProperties() !is null
        ? 11
        : _flow.getEcho().booleanValue
        ? 10
        : _flow.getDrain().booleanValue
        ? 9
        : _flow.getAvailable() !is null
        ? 8
        : _flow.getLinkCredit() !is null
        ? 7
        : _flow.getDeliveryCount() !is null
        ? 6
        : _flow.getHandle() !is null
        ? 5
        : 4;

    }
}

class FlowType : AbstractDescribedType!(Flow,List!Object) , DescribedTypeConstructor!(Flow)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000013L), Symbol.valueOf("amqp:flow:list"),
    //};
    //
    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000013L);

       static Object[]  DESCRIPTORS() {
           __gshared Object[]  inst;
           return initOnce!inst([UnsignedLong.valueOf(0x0000000000000013L), Symbol.valueOf("amqp:flow:list")]);
       }

    static UnsignedLong  DESCRIPTOR() {
         __gshared UnsignedLong  inst;
         return initOnce!inst(UnsignedLong.valueOf(0x0000000000000013L));
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
    protected List!Object wrap(Flow val)
    {
        return new FlowWrapper(val);
    }



    public Flow newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        Flow o = new Flow();

        if(l.size() <= 3)
        {
            logError("The outgoing-window field cannot be omitted");
          //  throw new DecodeException("The outgoing-window field cannot be omitted");
        }

        switch(11 - l.size())
        {

            case 0:
                o.setProperties( cast(IObject) l.get( 10 ) );
                goto case;
            case 1:
                Boolean echo = cast(Boolean) l.get(9);
                o.setEcho(echo is null ? null : echo);
                goto case;
            case 2:
                Boolean drain = cast(Boolean) l.get(8);
                o.setDrain(drain is null ? null : drain );
                goto case;
            case 3:
                o.setAvailable( cast(UnsignedInteger) l.get( 7 ) );
                goto case;
            case 4:
                o.setLinkCredit( cast(UnsignedInteger) l.get( 6 ) );
                goto case;
            case 5:
                o.setDeliveryCount( cast(UnsignedInteger) l.get( 5 ) );
                goto case;
            case 6:
                o.setHandle( cast(UnsignedInteger) l.get( 4 ) );
                goto case;
            case 7:
                o.setOutgoingWindow( cast(UnsignedInteger) l.get( 3 ) );
                goto case;
            case 8:
                o.setNextOutgoingId( cast(UnsignedInteger) l.get( 2 ) );
                goto case;
            case 9:
                o.setIncomingWindow( cast(UnsignedInteger) l.get( 1 ) );
                goto case;
            case 10:
                o.setNextIncomingId( cast(UnsignedInteger) l.get( 0 ) );
                break;
            default:
                break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Flow);
    }

    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        FlowType type = new FlowType(encoder);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
