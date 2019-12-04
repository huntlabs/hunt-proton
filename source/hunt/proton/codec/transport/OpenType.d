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


module hunt.proton.codec.transport.OpenType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.UnsignedShort;
import hunt.proton.amqp.transport.Open;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import std.concurrency : initOnce;
import hunt.Exceptions;
import hunt.logging;
import hunt.String;

class OpenWrapper : AbstractList!Object
{

    private Open _open;

    this(Open open)
    {
        _open = open;
    }

    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _open.getContainerId();
            case 1:
            return _open.getHostname();
            case 2:
            return _open.getMaxFrameSize();
            case 3:
            return _open.getChannelMax();
            case 4:
            return _open.getIdleTimeOut();
            case 5:
            return cast(Object)_open.getOutgoingLocales();
            case 6:
            return cast(Object)_open.getIncomingLocales();
            case 7:
            return cast(Object)_open.getOfferedCapabilities();
            case 8:
            return cast(Object)_open.getDesiredCapabilities();
            case 9:
            return cast(Object)_open.getProperties();
            default:
            return null;
        }

        //   throw new IllegalStateException("Unknown index " ~ index);

    }

    override
    public int size()
    {
        return _open.getProperties() !is null
        ? 10
        : _open.getDesiredCapabilities() !is null
        ? 9
        : _open.getOfferedCapabilities() !is null
        ? 8
        : _open.getIncomingLocales() !is null
        ? 7
        : _open.getOutgoingLocales() !is null
        ? 6
        : _open.getIdleTimeOut() !is null
        ? 5
        : (_open.getChannelMax() !is null && _open.getChannelMax() != (UnsignedShort.MAX_VALUE))
        ? 4
        : (_open.getMaxFrameSize() !is null && _open.getMaxFrameSize() != (UnsignedInteger.MAX_VALUE))
        ? 3
        : _open.getHostname() !is null
        ? 2
        : 1;

    }

}

class OpenType : AbstractDescribedType!(Open,List!Object) , DescribedTypeConstructor!(Open)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000010L), Symbol.valueOf("amqp:open:list"),
    //};

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000010L);

   static Object[]  DESCRIPTORS() {
       __gshared Object[]  inst;
       return initOnce!inst([UnsignedLong.valueOf(0x0000000000000010L), Symbol.valueOf("amqp:open:list")]);
   }

  static UnsignedLong  DESCRIPTOR() {
      __gshared UnsignedLong  inst;
      return initOnce!inst(UnsignedLong.valueOf(0x0000000000000010L));
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
    protected List!Object wrap(Open val)
    {
        return new OpenWrapper(val);
    }




    public Open newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        Open o = new Open();

        if(l.isEmpty())
        {
           // throw new DecodeException("The container-id field cannot be omitted");
            logError("The container-id field cannot be omitted");
        }

        switch(10 - l.size())
        {

            case 0:
                o.setProperties( cast(Map!(Symbol,Object)) l.get( 9 ) );
                goto case;
            case 1:
                //Object val1 = l.get( 8 );
                o.setDesiredCapabilities( cast(List!Symbol) l.get( 8 ) );
                goto case;
            case 2:
                o.setOfferedCapabilities(cast(List!Symbol)l.get( 7 ) );
                goto case;
            case 3:
                o.setIncomingLocales( cast(List!Symbol) l.get(6) );
                goto case;
            case 4:
                o.setOutgoingLocales( cast(List!Symbol) l.get(5) );
                goto case;
            case 5:
                o.setIdleTimeOut( cast(UnsignedInteger) l.get( 4 ) );
                goto case;
            case 6:
                UnsignedShort channelMax = cast(UnsignedShort) l.get(3);
                o.setChannelMax(channelMax is null ? UnsignedShort.MAX_VALUE : channelMax);
                goto case;
            case 7:
                UnsignedInteger maxFrameSize = cast(UnsignedInteger) l.get(2);
                o.setMaxFrameSize(maxFrameSize is null ? UnsignedInteger.MAX_VALUE : maxFrameSize);
                goto case;
            case 8:
                o.setHostname( cast(String) l.get( 1 ) );
                goto case;
            case 9:
                o.setContainerId( cast(String) l.get( 0 ) );
                break;
            default:
                break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Open);
    }


    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        OpenType type = new OpenType(encoder);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }

}
