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


module hunt.proton.codec.transport.ErrorConditionType;

import hunt.collection.AbstractList;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import std.concurrency : initOnce;
import hunt.logging;
import hunt.Object;
import hunt.String;

class ErrorConditionWrapper : AbstractList!Object
{

    private ErrorCondition _errorCondition;

    this(ErrorCondition errorCondition)
    {
        _errorCondition = errorCondition;
    }

    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _errorCondition.getCondition();
            case 1:
            return _errorCondition.getDescription();
            case 2:
            return cast(Object)(_errorCondition.getInfo());
            default:
            {
                logError("Unknown index %d",index);
                return  null;
            }


        }

        // throw new IllegalStateException("Unknown index " ~ index);

    }

    override
    public int size()
    {
        return _errorCondition.getInfo() !is null
        ? 3
        : _errorCondition.getDescription() !is null
        ? 2
        : 1;

    }

}


class ErrorConditionType : AbstractDescribedType!(ErrorCondition,List!Object) , DescribedTypeConstructor!(ErrorCondition)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x000000000000001dL), Symbol.valueOf("amqp:error:list"),
    //};
    //
    //private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x000000000000001dL);


     static Object[]  DESCRIPTORS() {
         __gshared Object[]  inst;
         return initOnce!inst([UnsignedLong.valueOf(0x000000000000001dL), Symbol.valueOf("amqp:error:list")]);
     }

         static UnsignedLong  DESCRIPTOR() {
             __gshared UnsignedLong  inst;
             return initOnce!inst(UnsignedLong.valueOf(0x000000000000001dL));
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
    protected List!Object wrap(ErrorCondition val)
    {
        return new ErrorConditionWrapper(val);
    }


    public ErrorCondition newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        ErrorCondition o = new ErrorCondition();

        if(l.isEmpty())
        {
            logError("The condition field cannot be omitted");
            return  null;

         //   throw new DecodeException("The condition field cannot be omitted");
        }

        switch(3 - l.size())
        {

            case 0:
                o.setInfo( cast(IObject) l.get( 2 ) );
                goto case;
            case 1:
                o.setDescription( cast(String) l.get( 1 ) );
                goto case;
            case 2:
                o.setCondition( cast(Symbol) l.get( 0 ) );
                break;
            default:
                 break;
        }


        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(ErrorCondition);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        ErrorConditionType type = new ErrorConditionType(encoder);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }

}
  