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


module hunt.proton.codec.messaging.ModifiedType;

import hunt.Object;
import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Modified;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Exceptions;
import hunt.String;
import hunt.Boolean;
import std.concurrency : initOnce;
import std.conv : to;

class ModifiedWrapper : AbstractList!Object
{
    private Modified _impl;

    this(Modified impl)
    {
        _impl = impl;
    }

    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _impl.getDeliveryFailed();
            case 1:
            return _impl.getUndeliverableHere();
            case 2:
            return cast(Object)_impl.getMessageAnnotations();
            default:
            return null;
        }

        // throw new IllegalStateException("Unknown index " ~ to!string(index));

    }

    override
    public int size()
    {
        return _impl.getMessageAnnotations() !is null
        ? 3
        : _impl.getUndeliverableHere() !is null
        ? 2
        : _impl.getDeliveryFailed() !is null
        ? 1
        : 0;

    }

}



class ModifiedType  : AbstractDescribedType!(Modified,List!Object) , DescribedTypeConstructor!(Modified)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000027L), Symbol.valueOf("amqp:modified:list"),
    //};

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000027L);


    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000027L), Symbol.valueOf("amqp:modified:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000027L));
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
    protected List!Object wrap(Modified val)
    {
        return new ModifiedWrapper(val);
    }



    public Modified newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        Modified o = new Modified();


        switch(3 - l.size())
        {

            case 0:
                o.setMessageAnnotations( cast(Map!(Symbol,Object)) l.get( 2 ) );
                goto case;
            case 1:
                o.setUndeliverableHere( cast(Boolean) l.get( 1 ) );
                goto case;
            case 2:
                o.setDeliveryFailed( cast(Boolean) l.get( 0 ) );
                break;
            default:
                break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Modified);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        ModifiedType type = new ModifiedType(encoder);
       // implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
  