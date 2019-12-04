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


module hunt.proton.codec.transport.AttachType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedByte;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.Attach;
import hunt.proton.amqp.transport.ReceiverSettleMode;
import hunt.proton.amqp.transport.Role;
import hunt.proton.amqp.transport.SenderSettleMode;
import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.transport.Target;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.logging;
import hunt.Boolean;
import hunt.String;
import std.concurrency : initOnce;
class AttachWrapper : AbstractList!Object
{

    private Attach _attach;

    this(Attach attach)
    {
        _attach = attach;
    }

    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _attach.getName();
            case 1:
            return _attach.getHandle();
            case 2:
            return _attach.getRole().getValue();
            case 3:
            return _attach.getSndSettleMode().getValue();
            case 4:
            return _attach.getRcvSettleMode().getValue();
            case 5:
            return  cast(Object)(_attach.getSource());
            case 6:
            return cast(Object)(_attach.getTarget());
            case 7:
            return cast(Object)(_attach.getUnsettled());
            case 8:
            return _attach.getIncompleteUnsettled();
            case 9:
            return _attach.getInitialDeliveryCount();
            case 10:
            return _attach.getMaxMessageSize();
            case 11:
            return cast(Object)(_attach.getOfferedCapabilities());
            case 12:
            return cast(Object)(_attach.getDesiredCapabilities());
            case 13:
            return cast(Object)(_attach.getProperties());
            default:
            return null;
        }

        // throw new IllegalStateException("Unknown index " ~ index);

    }

    override
    public int size()
    {
        return _attach.getProperties() !is null
        ? 14
        : _attach.getDesiredCapabilities() !is null
        ? 13
        : _attach.getOfferedCapabilities() !is null
        ? 12
        : _attach.getMaxMessageSize() !is null
        ? 11
        : _attach.getInitialDeliveryCount() !is null
        ? 10
        : _attach.getIncompleteUnsettled().booleanValue
        ? 9
        : _attach.getUnsettled() !is null
        ? 8
        : _attach.getTarget() !is null
        ? 7
        : _attach.getSource() !is null
        ? 6
        : (_attach.getRcvSettleMode() !is null && _attach.getRcvSettleMode()!= (ReceiverSettleMode.FIRST))
        ? 5
        : (_attach.getSndSettleMode() !is null && _attach.getSndSettleMode()!= (SenderSettleMode.MIXED))
        ? 4
        : 3;

    }

}


class AttachType : AbstractDescribedType!(Attach,List!Object) , DescribedTypeConstructor!(Attach)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000012L), Symbol.valueOf("amqp:attach:list"),
    //};
    //
    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000012L);

      static Object[]  DESCRIPTORS() {
          __gshared Object[]  inst;
          return initOnce!inst([UnsignedLong.valueOf(0x0000000000000012L), Symbol.valueOf("amqp:attach:list")]);
      }

         static UnsignedLong  DESCRIPTOR() {
             __gshared UnsignedLong  inst;
             return initOnce!inst(UnsignedLong.valueOf(0x0000000000000012L));
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
    protected List!Object wrap(Attach val)
    {
        return new AttachWrapper(val);
    }



    public Attach newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        Attach o = new Attach();

        if(l.size() <= 2)
        {
            logError("The role field cannot be omitted");
            return null;
            //throw new DecodeException("The role field cannot be omitted");
        }

        switch(14 - l.size())
        {

            case 0:
                o.setProperties( cast(Map!(Symbol,Object)) l.get( 13 ) );
                goto case;
            case 1:
                o.setDesiredCapabilities( cast(List!Symbol)  l.get( 12 ) );
                goto case;
            case 2:
                o.setOfferedCapabilities( cast(List!Symbol) l.get( 11 ) );
                goto case;
            case 3:
                o.setMaxMessageSize( cast(UnsignedLong) l.get( 10 ) );
                goto case;
            case 4:
                o.setInitialDeliveryCount( cast(UnsignedInteger) l.get( 9 ) );
                goto case;
            case 5:
                Boolean incompleteUnsettled = cast(Boolean) l.get(8);
                o.setIncompleteUnsettled(incompleteUnsettled is null ? null : incompleteUnsettled);
                goto case;
            case 6:
                o.setUnsettled( cast(Map!(Symbol,Object)) l.get( 7 ) );
                goto case;
            case 7:
                o.setTarget( cast(Target) l.get( 6 ) );
                goto case;
            case 8:
                o.setSource( cast(Source) l.get( 5 ) );
                goto case;
            case 9:
                UnsignedByte rcvSettleMode = cast(UnsignedByte) l.get(4);
                o.setRcvSettleMode(rcvSettleMode is null ? ReceiverSettleMode.FIRST : ReceiverSettleMode.valueOf(rcvSettleMode));
                goto case;
            case 10:
                UnsignedByte sndSettleMode = cast(UnsignedByte) l.get(3);
                o.setSndSettleMode(sndSettleMode is null ? SenderSettleMode.MIXED : SenderSettleMode.valueOf(sndSettleMode));
                goto case;
            case 11:
                Boolean tmp = cast(Boolean) l.get( 2 );
                o.setRole(tmp.booleanValue() ? Role.RECEIVER : Role.SENDER);
                goto case;
            case 12:
                o.setHandle( cast(UnsignedInteger) l.get( 1 ) );
                goto case;
            case 13:
                o.setName( cast(String) l.get( 0 ) );
                 break;
            default:
                break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Attach);
    }


    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        AttachType type = new AttachType(encoder);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
