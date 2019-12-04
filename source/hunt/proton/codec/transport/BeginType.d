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


module hunt.proton.codec.transport.BeginType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.UnsignedShort;
import hunt.proton.amqp.transport.Begin;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.logging;
import std.concurrency : initOnce;

class BeginWrapper : AbstractList!Object
{

    private Begin _begin;

    this(Begin begin)
    {
        _begin = begin;
    }

    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _begin.getRemoteChannel();
            case 1:
            return _begin.getNextOutgoingId();
            case 2:
            return _begin.getIncomingWindow();
            case 3:
            return _begin.getOutgoingWindow();
            case 4:
            return _begin.getHandleMax();
            case 5:
            return cast(Object)(_begin.getOfferedCapabilities());
            case 6:
            return cast(Object)(_begin.getDesiredCapabilities());
            case 7:
            return cast(Object)(_begin.getProperties());
            default:
            return null;
        }

        //throw new IllegalStateException("Unknown index " ~ index);

    }

    override
    public int size()
    {
        return _begin.getProperties() !is null
        ? 8
        : _begin.getDesiredCapabilities() !is null
        ? 7
        : _begin.getOfferedCapabilities() !is null
        ? 6
        : (_begin.getHandleMax() !is null && _begin.getHandleMax() != (UnsignedInteger.MAX_VALUE))
        ? 5
        : 4;

    }
}

class BeginType : AbstractDescribedType!(Begin,List!Object) , DescribedTypeConstructor!(Begin)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000011L), Symbol.valueOf("amqp:begin:list"),
    //};
    //
    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000011L);

      static Object[]  DESCRIPTORS() {
          __gshared Object[]  inst;
          return initOnce!inst([UnsignedLong.valueOf(0x0000000000000011L), Symbol.valueOf("amqp:begin:list")]);
      }

         static UnsignedLong  DESCRIPTOR() {
             __gshared UnsignedLong  inst;
             return initOnce!inst(UnsignedLong.valueOf(0x0000000000000011L));
         }

    this(EncoderImpl encoder)
    {
        super(encoder);
    }

    override
    protected UnsignedLong getDescriptor()
    {
        return DESCRIPTOR;
    }

    override
    protected List!Object wrap(Begin val)
    {
        return new BeginWrapper(val);
    }



    public Begin newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        Begin o = new Begin();

        if(l.size() <= 3)
        {
            logError("The outgoing-window field cannot be omitted");
            return null;
           // throw new DecodeException("The outgoing-window field cannot be omitted");
        }

        switch(8 - l.size())
        {

            case 0:
                o.setProperties( cast(Map!(Symbol,Object)) l.get( 7 ) );
                goto case;
            case 1:
                o.setDesiredCapabilities( cast(List!Symbol) l.get( 6 ) );
                goto case;
            case 2:
                o.setOfferedCapabilities( cast(List!Symbol) l.get( 5 ) );
                goto case;
            case 3:
                UnsignedInteger handleMax = cast(UnsignedInteger) l.get(4);
                o.setHandleMax(handleMax is null ? UnsignedInteger.MAX_VALUE : handleMax);
                goto case;
            case 4:
                o.setOutgoingWindow( cast(UnsignedInteger) l.get( 3 ) );
                goto case;
            case 5:
                o.setIncomingWindow( cast(UnsignedInteger) l.get( 2 ) );
                goto case;
            case 6:
                o.setNextOutgoingId( cast(UnsignedInteger) l.get( 1 ) );
                goto case;
            case 7:
                o.setRemoteChannel( cast(UnsignedShort) l.get( 0 ) );
                break;
            default:
                break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Begin);
    }


    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        BeginType type = new BeginType(encoder);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }

}
  