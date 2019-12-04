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


module hunt.proton.codec.messaging.HeaderType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.Object;
import hunt.Boolean;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedByte;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Header;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Exceptions;
import std.concurrency : initOnce;
import std.conv : to;

class HeaderWrapper : AbstractList!Object
{
    private Header _impl;

    this(Header impl)
    {
        _impl = impl;
    }


    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _impl.getDurable();
            case 1:
            return _impl.getPriority();
            case 2:
            return _impl.getTtl();
            case 3:
            return _impl.getFirstAcquirer();
            case 4:
            return _impl.getDeliveryCount();
            default:
            return null;
        }

        //   throw new IllegalStateException("Unknown index " ~ to!string(index));

    }

    override
    public int size()
    {
        return _impl.getDeliveryCount() !is null
        ? 5
        : _impl.getFirstAcquirer() !is null
        ? 4
        : _impl.getTtl() !is null
        ? 3
        : _impl.getPriority() !is null
        ? 2
        : _impl.getDurable() !is null
        ? 1
        : 0;

    }


}


class HeaderType : AbstractDescribedType!(Header,List!Object) , DescribedTypeConstructor!(Header)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000070L), Symbol.valueOf("amqp:header:list"),
    //};

    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000070L);

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000070L), Symbol.valueOf("amqp:header:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000070L));
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
    protected List!Object wrap(Header val)
    {
        return new HeaderWrapper(val);
    }



    public Header newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        Header o = new Header();


        switch(5 - l.size())
        {

            case 0:
                o.setDeliveryCount( cast(UnsignedInteger) l.get( 4 ) );
                goto case;
            case 1:
                o.setFirstAcquirer( (cast(Boolean) l.get( 3 )).booleanValue() );
                goto case;
            case 2:
                o.setTtl( cast(UnsignedInteger) l.get( 2 ) );
                goto case;
            case 3:
                o.setPriority( cast(UnsignedByte) l.get( 1 ) );
                goto case;
            case 4:
                o.setDurable( (cast(Boolean) l.get( 0 )).booleanValue() );
                break;
            default:
                break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Header);
    }

    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        HeaderType type = new HeaderType(encoder);
    //    implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
