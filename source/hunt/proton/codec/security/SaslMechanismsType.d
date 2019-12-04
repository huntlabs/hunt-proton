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


module hunt.proton.codec.security.SaslMechanismsType;

import hunt.collection.Collections;
import hunt.collection.List;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.security.SaslMechanisms;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.DecodeException;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.logging;
import hunt.Object;
import std.concurrency : initOnce;
import hunt.collection.ArrayList;
import hunt.Exceptions;

class SaslMechanismsType : AbstractDescribedType!(SaslMechanisms,List!(Object)) , DescribedTypeConstructor!(SaslMechanisms)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000040L), Symbol.valueOf("amqp:sasl-mechanisms:list"),
    //};

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000040L);

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000040L), Symbol.valueOf("amqp:sasl-mechanisms:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000040L));
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
    protected List!(Object) wrap(SaslMechanisms val)
    {
         List!(Object) lst = new ArrayList!(Object);
         foreach (Symbol v ; val.getSaslServerMechanisms())
         {
                lst.add(v);
         }
         return lst;
        //return Collections.singletonList!(Symbol)(val.getSaslServerMechanisms());
    }

    public SaslMechanisms newInstance(Object described)
    {
        List!Object l = cast(List!Object) described;

        SaslMechanisms o = new SaslMechanisms();

        if(l.isEmpty())
        {
            logError("The sasl-server-mechanisms field cannot be omitted");
           // throw new DecodeException("The sasl-server-mechanisms field cannot be omitted");
        }

        List!Symbol tmp = new ArrayList!Symbol;

        Object val0 = l.get( 0 );
        List!Object ls = cast(List!Object) val0;
        if(ls !is null)
        {
            foreach(Object m ; ls)
            {
              Symbol s = cast(Symbol)m;
              if (s !is null)
              {
                  tmp.add(s);
              }
            }
        }else
        {
          tmp.add(cast(Symbol) val0);
        }
        //if( val0 == null || val0.getClass().isArray() )
        //{
        //    o.setSaslServerMechanisms( (Symbol[]) val0 );
        //}
        //else
        //{
        //    o.setSaslServerMechanisms( (Symbol) val0 );
        //}


     //   tmp.add(Symbol.valueOf("ANONYMOUS"));



        //foreach(Object ob;l)
        //{
        //    Symbol v = cast(Symbol)ob;
        //    if (v is null)
        //    {
        //        logError("5555555555555555555555555555");
        //    }
        //    tmp.add(v);
        //}

       // Object val0 = l.get( 0 );
        //if( val0 is null || val0.getClass().isArray() )
        //{
        //    o.setSaslServerMechanisms( (Symbol[]) val0 );
        //}
        //else
        //{
        o.setSaslServerMechanisms( tmp );
//        }

        return o;
    }

    public TypeInfo getTypeClass()
    {
        return typeid(SaslMechanisms);
    }



    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        SaslMechanismsType type = new SaslMechanismsType(encoder);
       // implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }


}
