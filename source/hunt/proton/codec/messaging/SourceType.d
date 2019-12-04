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


module hunt.proton.codec.messaging.SourceType;

import hunt.String;
import hunt.Object;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.Boolean;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Outcome;
import hunt.proton.amqp.messaging.Source;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.amqp.messaging.TerminusDurability;
import hunt.proton.amqp.messaging.TerminusExpiryPolicy;
import hunt.Exceptions;


import std.concurrency : initOnce;
import std.conv : to;


class SourceWrapper : AbstractList!Object
{
    private Source _impl;

    this(Source impl)
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
            return _impl.getDistributionMode();
            case 7:
            return cast(Object)(_impl.getFilter());
            case 8:
            return cast(Object)(_impl.getDefaultOutcome());
            case 9:
            return cast(Object)(_impl.getOutcomes());
            case 10:
            return cast(Object)(_impl.getCapabilities());
            default:
            return null;
        }

        //   throw new IllegalStateException("Unknown index " ~ to!string(index));

    }

    override
    public int size()
    {
        return _impl.getCapabilities() !is null
        ? 11
        : _impl.getOutcomes() !is null
        ? 10
        : _impl.getDefaultOutcome() !is null
        ? 9
        : _impl.getFilter() !is null
        ? 8
        : _impl.getDistributionMode() !is null
        ? 7
        : _impl.getDynamicNodeProperties() !is null
        ? 6
        : _impl.getDynamic().booleanValue
        ? 5
        : (_impl.getTimeout() !is null && _impl.getTimeout() != (UnsignedInteger.ZERO))
        ? 4
        : _impl.getExpiryPolicy() !is TerminusExpiryPolicy.SESSION_END
        ? 3
        : _impl.getDurable() !is TerminusDurability.NONE
        ? 2
        : _impl.getAddress() !is null
        ? 1
        : 0;

    }

}


class SourceType : AbstractDescribedType!(Source,List!Object) , DescribedTypeConstructor!(Source)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000028L), Symbol.valueOf("amqp:source:list"),
    //};

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000028L);


    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000028L), Symbol.valueOf("amqp:source:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000028L));
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
    protected List!Object wrap(Source val)
    {
        return new SourceWrapper(val);
    }



    public Source newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        Source o = new Source();


        switch(11 - l.size())
        {

            case 0:
            {
                Object val0 = l.get( 10 );
                //if( val0 is null || val0.getClass().isArray() )
                //{
                //    o.setCapabilities( cast(Symbol[]) val0 );
                //}
                {
                    o.setCapabilities( val0 is null ? null: cast(List!Symbol) val0 );
                }
                goto case;
            }


            case 1:
            {
                Object val1 = l.get( 9 );
                //if( val1 is null || val1.getClass().isArray() )
                //{
                //    o.setOutcomes( cast(Symbol[]) val1 );
                //}
                {
                    o.setOutcomes( val1 is null ? null: cast(List!Symbol) val1 );
                }
                goto case;
            }

            case 2:
                 Object val2 = l.get( 8 );
                o.setDefaultOutcome( val2 is null ? null : cast(Outcome)val2 );
                goto case;
            case 3:
                 Object val3 = l.get( 7 );
                o.setFilter(val3 is null? null : cast(Map!(Object,Object)) val3 );
                goto case;
            case 4:
                Object val4 = l.get( 6 );
                o.setDistributionMode( val4 is null ? null : cast(Symbol)val4 );
                goto case;
            case 5:
                Object val5 =  l.get( 5 );
                o.setDynamicNodeProperties(val5 is null ? null:  cast(IObject)val5  );
                goto case;
            case 6:
            {
                Object val6 = l.get( 4);
                Boolean dynamic = val6 is null? null : cast(Boolean) val6;
                o.setDynamic( dynamic is null ? new Boolean( false) : dynamic);
                goto case;
            }

            case 7:
            {
                Object val7 = l.get( 3);

                UnsignedInteger timeout = val7 is null? null :  cast(UnsignedInteger) val7;
                o.setTimeout( timeout is null ? UnsignedInteger.ZERO : timeout);
                goto case;
            }
            case 8:
            {
                Object val8 = l.get( 2);
                Symbol expiryPolicy = val8 is null ? null: cast(Symbol) val8;
                o.setExpiryPolicy( expiryPolicy is null ? TerminusExpiryPolicy.SESSION_END : TerminusExpiryPolicy.valueOf( expiryPolicy));
                goto case;
            }
            case 9:
            {
                Object val9 =  l.get( 1);
                UnsignedInteger durable = val9 is null ? null:  cast(UnsignedInteger)val9 ;
                o.setDurable( durable is null ? TerminusDurability.NONE : TerminusDurability.get( durable));
                goto case;
            }
            case 10:
                Object val10 = l.get( 0 );

                o.setAddress(val10 is null ? null: cast(String) val10);
                break;
            default:
                break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Source);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        SourceType type = new SourceType(encoder);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
       // implementationMissing(false);
    }


}
  