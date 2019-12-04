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


module hunt.proton.codec.messaging.PropertiesType;

import hunt.collection.AbstractList;
import hunt.time.LocalDateTime;
import hunt.Object;
import hunt.collection.List;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Properties;
import hunt.proton.codec.AbstractDescribedType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.proton.codec.EncoderImpl;
import hunt.Exceptions;
import hunt.String;
import std.concurrency : initOnce;
import std.conv : to;

alias Date = LocalDateTime;

class PropertiesWrapper : AbstractList!Object
{

    private Properties _impl;

    this(Properties propertiesType)
    {
        _impl = propertiesType;
    }

    override
    public Object get(int index)
    {

        switch(index)
        {
            case 0:
            return _impl.getMessageId();
            case 1:
            return _impl.getUserId();
            case 2:
            return _impl.getTo();
            case 3:
            return _impl.getSubject();
            case 4:
            return _impl.getReplyTo();
            case 5:
            return _impl.getCorrelationId();
            case 6:
            return _impl.getContentType();
            case 7:
            return _impl.getContentEncoding();
            case 8:
            return _impl.getAbsoluteExpiryTime();
            case 9:
            return _impl.getCreationTime();
            case 10:
            return _impl.getGroupId();
            case 11:
            return _impl.getGroupSequence();
            case 12:
            return _impl.getReplyToGroupId();
            default:
            break;
        }

        throw new IllegalStateException("Unknown index " ~ to!string(index));

    }

    override
    public int size()
    {
        return _impl.getReplyToGroupId() !is null
        ? 13
        : _impl.getGroupSequence() !is null
        ? 12
        : _impl.getGroupId() !is null
        ? 11
        : _impl.getCreationTime() !is null
        ? 10
        : _impl.getAbsoluteExpiryTime() !is null
        ? 9
        : _impl.getContentEncoding() !is null
        ? 8
        : _impl.getContentType() !is null
        ? 7
        : _impl.getCorrelationId() !is null
        ? 6
        : _impl.getReplyTo() !is null
        ? 5
        : _impl.getSubject() !is null
        ? 4
        : _impl.getTo() !is null
        ? 3
        : _impl.getUserId() !is null
        ? 2
        : _impl.getMessageId() !is null
        ? 1
        : 0;

    }

}

class PropertiesType  : AbstractDescribedType!(Properties,List!Object) , DescribedTypeConstructor!(Properties)
{
    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(0x0000000000000073L), Symbol.valueOf("amqp:properties:list"),
    //};

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(0x0000000000000073L), Symbol.valueOf("amqp:properties:list")]);
    }

    static UnsignedLong  DESCRIPTOR() {
        __gshared UnsignedLong  inst;
        return initOnce!inst(UnsignedLong.valueOf(0x0000000000000073L));
    }

   // private static UnsignedLong DESCRIPTOR = UnsignedLong.valueOf(0x0000000000000073L);

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
    protected List!Object wrap(Properties val)
    {
        return new PropertiesWrapper(val);
    }



        public Properties newInstance(Object described)
        {
            List!Object l = cast(List!Object) described;

            Properties o = new Properties();


            switch(13 - l.size())
            {

                case 0:
                    o.setReplyToGroupId( cast(String) l.get( 12 ) );
                    goto case;
                case 1:
                    o.setGroupSequence( cast(UnsignedInteger) l.get( 11 ) );
                    goto case;
                case 2:
                    o.setGroupId( cast(String) l.get( 10 ) );
                    goto case;
                case 3:
                    o.setCreationTime( cast(Date) l.get( 9 ) );
                    goto case;
                case 4:
                    o.setAbsoluteExpiryTime( cast(Date) l.get( 8 ) );
                    goto case;
                case 5:
                    o.setContentEncoding( cast(Symbol) l.get( 7 ) );
                    goto case;
                case 6:
                    o.setContentType( cast(Symbol) l.get( 6 ) );
                    goto case;
                case 7:
                    o.setCorrelationId( cast(String) l.get( 5 ) );
                    goto case;
                case 8:
                    o.setReplyTo( cast(String) l.get( 4 ) );
                    goto case;
                case 9:
                    o.setSubject( cast(String) l.get( 3 ) );
                    goto case;
                case 10:
                    o.setTo( cast(String) l.get( 2 ) );
                    goto case;
                case 11:
                    o.setUserId( cast(Binary) l.get( 1 ) );
                    goto case;
                case 12:
                    o.setMessageId(cast(String) l.get( 0 ) );
                    break;
                default:
                    break;
            }


            return o;
        }

        public TypeInfo getTypeClass()
        {
            return typeid(Properties);
        }

    public static void register(Decoder decoder, EncoderImpl encoder)
    {
        PropertiesType type = new PropertiesType(encoder);
        //implementationMissing(false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerDynamic(descriptor, type);
        }
        encoder.register(type);
    }
}
