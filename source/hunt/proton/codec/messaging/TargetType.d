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


module hunt.proton.codec.messaging.TargetType;

import hunt.collection.AbstractList;

import hunt.collection.List;
import hunt.collection.Map;
import hunt.Object;
import hunt.Boolean;
import hunt.String;
import hunt.Exceptions;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Target;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.amqp.messaging.TerminusDurability;
import hunt.proton.amqp.messaging.TerminusExpiryPolicy;
import std.concurrency : initOnce;
import std.conv : to;

class TargetWrapper : AbstractList!Object
{
    private Target _impl;

    this(Target impl)
    {
        _impl = impl;
    }

    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _impl.getAddress();
            case 1:
            return _impl.getDurable().getValue();
            case 2:
            return _impl.getExpiryPolicy().getPolicy();
            case 3:
            return _impl.getTimeout();
            case 4:
            return _impl.getDynamic();
            case 5:
            return cast(Object)(_impl.getDynamicNodeProperties());
            case 6:
            return cast(Object)_impl.getCapabilities();
            default:
            return null;
        }

        //   throw new IllegalStateException("Unknown index " ~ to!string(index));

    }

    override
    public int size()
    {
        return _impl.getCapabilities() !is null
        ? 7
        : _impl.getDynamicNodeProperties() !is null
        ? 6
        : _impl.getDynamic().booleanValue
        ? 5
        : (_impl.getTimeout() !is null && _impl.getTimeout() != (UnsignedInteger.ZERO))
        ? 4
        : _impl.getExpiryPolicy() !is (TerminusExpiryPolicy.SESSION_END)
        ? 3
        : _impl.getDurable() !is (TerminusDurability.NONE)
        ? 2
        : _impl.getAddress() !is null
        ? 1
        : 0;

    }
}

class TargetType : AbstractDescribedType!(Target,List!Object) , DescribedTypeConstructor!(Target)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000029L), Symbol.valueOf("amqp:target:list"),
    //};

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000029L);


    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000029L), Symbol.valueOf("amqp:target:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000029L));
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
    protected List!Object wrap(Target val)
    {
        return new TargetWrapper(val);
    }




    public Target newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        Target o = new Target();


        switch(7 - l.size())
        {

            case 0:
                Object val0 = l.get( 6 );
                //if( val0 is null || val0.getClass().isArray() )
                //{
                //    o.setCapabilities( (Symbol[]) val0 );
                //}
                //else
                {
                    o.setCapabilities( cast(List!Symbol) val0 );
                }
                goto case;
            case 1:
                o.setDynamicNodeProperties( cast(IObject) l.get( 5 ) );
                goto case;
            case 2:
                Boolean dynamic = cast(Boolean) l.get(4);
                o.setDynamic(dynamic is null ? new Boolean( false) : dynamic);
                goto case;
            case 3:
                UnsignedInteger timeout = cast(UnsignedInteger) l.get(3);
                o.setTimeout(timeout is null ? UnsignedInteger.ZERO : timeout);
                goto case;
            case 4:
                Symbol expiryPolicy = cast(Symbol) l.get(2);
                o.setExpiryPolicy(expiryPolicy is null ? TerminusExpiryPolicy.SESSION_END : TerminusExpiryPolicy.valueOf(expiryPolicy));
                goto case;
            case 5:
                UnsignedInteger durable = cast(UnsignedInteger) l.get(1);
                o.setDurable(durable is null ? TerminusDurability.NONE : TerminusDurability.get(durable));
                goto case;
            case 6:
                o.setAddress( cast(String) l.get( 0 ) );
                break;
            default:
                break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Target);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        TargetType type = new TargetType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }

}
  