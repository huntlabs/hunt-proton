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


module hunt.proton.codec.transport.DetachType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.Detach;
import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import std.concurrency : initOnce;
import hunt.logging;
import hunt.Boolean;

class DetachWrapper : AbstractList!Object
{

    private Detach _detach;

    this(Detach detach)
    {
        _detach = detach;
    }

    override
    Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _detach.getHandle();
            case 1:
            return _detach.getClosed();
            case 2:
            return _detach.getError();
            default:
            return null;
        }

        //     throw new IllegalStateException("Unknown index " ~ index);

    }

    override
    int size()
    {
        return _detach.getError() !is null
        ? 3
        : _detach.getClosed().booleanValue()
        ? 2
        : 1;

    }
}

class DetachType : AbstractDescribedType!(Detach,List!Object) , DescribedTypeConstructor!(Detach)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000016L), Symbol.valueOf("amqp:detach:list"),
    //};
    //
    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000016L);


     static Object[]  DESCRIPTORS() {
         __gshared Object[]  inst;
         return initOnce!inst([UnsignedLong.valueOf(0x0000000000000016L), Symbol.valueOf("amqp:detach:list")]);
     }

         static UnsignedLong  DESCRIPTOR() {
             __gshared UnsignedLong  inst;
             return initOnce!inst(UnsignedLong.valueOf(0x0000000000000016L));
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
    protected List!Object wrap(Detach val)
    {
        return new DetachWrapper(val);
    }



    Detach newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;
        
        version(HUNT_AMQP_DEBUG) {
            size_t index = 0;
            foreach (Object obj; l) {
                if(obj is null) {
                    tracef("Object[%d] is null", index);
                } else {
                    tracef("Object[%d]: %s ,%s", index, typeid(obj), obj.toString());
                }
                index++;
            }
        }

        Detach o = new Detach();

        if(l.isEmpty())
        {
            logError("The handle field cannot be omitted");
            //throw new DecodeException("The handle field cannot be omitted");
        }

        switch(3 - l.size())
        {

            case 0:
                o.setError( cast(ErrorCondition) l.get( 2 ) );
                goto case;
            case 1:
                Boolean closed = cast(Boolean) l.get(1);
                o.setClosed(closed is null ? Boolean.FALSE : closed);
                // o.setClosed(Boolean.TRUE);
                goto case;
            case 2:
                o.setHandle( cast(UnsignedInteger) l.get( 0 ) );
                break;
            default:
                break;
        }


        return o;
    }

    TypeInfo getTypeClass()
    {
        return typeid(Detach);
    }


    static void register(Decoder decoder, EncoderImpl encoder)
    {
        DetachType type = new DetachType(encoder);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }

}
  