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


module hunt.proton.amqp.security.SaslCode;

import hunt.proton.amqp.UnsignedByte;
import hunt.Enum;
import std.concurrency : initOnce;
import hunt.util.ObjectUtils;
class SaslCode : AbstractEnum!int
{
    //__gshared SaslCode OK;
    //__gshared SaslCode AUTH;
    //__gshared SaslCode SYS;
    //__gshared SaslCode SYS_PERM;
    //__gshared SaslCode SYS_TEMP;


    static SaslCode  OK() {
        __gshared SaslCode  inst;
        return initOnce!inst(new SaslCode("OK" , 0));
    }

    static SaslCode  AUTH() {
        __gshared SaslCode  inst;
        return initOnce!inst(new SaslCode("AUTH" , 1));
    }

    static SaslCode  SYS() {
        __gshared SaslCode  inst;
        return initOnce!inst(new SaslCode("SYS" , 2));
    }

    static SaslCode  SYS_PERM() {
        __gshared SaslCode  inst;
        return initOnce!inst(new SaslCode("SYS_PERM" , 3));
    }

    static SaslCode  SYS_TEMP() {
        __gshared SaslCode  inst;
        return initOnce!inst(new SaslCode("SYS_TEMP" , 4));
    }

    mixin ValuesMemberTempate!(SaslCode);

    //enum {
    //    OK = 0, AUTH, SYS, SYS_PERM, SYS_TEMP
    //}

    this(string name ,int val)
    {
        super(name,val);
    }

    //private int ordinal()
    //{
    //    return value;
    //}
    //
    //
    //shared static  this()
    //{
    //    OK = new SaslCode(0);
    //    AUTH = new SaslCode(1);
    //    SYS = new SaslCode(2);
    //    SYS_PERM = new SaslCode(3);
    //    SYS_TEMP = new SaslCode(4);
    //}

    public UnsignedByte getValue()
    {
        return UnsignedByte.valueOf(cast(byte)(ordinal()));
    }

    static SaslCode valueOf(UnsignedByte v)
    {
       // return SaslCode.values()[v.byteValue()];
        switch(cast(int)v.byteValue())
        {
            case 0:
                return OK;
            case 1:
                return AUTH;
            case 2:
                return SYS;
            case 3:
                return SYS_PERM;
            case 4:
                return SYS_TEMP;
            default:
                return null;
        }
    }

}
