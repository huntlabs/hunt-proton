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


module hunt.proton.amqp.messaging.TerminusDurability;

import hunt.proton.amqp.UnsignedInteger;

class TerminusDurability
{
    //enum{
    //    NONE = 0,
    //    CONFIGURATION,
    //    UNSETTLED_STATE
    //}
    //

    private int _val;

    this(int value)
    {
        _val = value;
    }

     shared static  this() {
         NONE = new TerminusDurability(0);
         CONFIGURATION = new TerminusDurability(1);
         UNSETTLED_STATE = new TerminusDurability(2);
     }

    __gshared TerminusDurability NONE ;
    __gshared TerminusDurability CONFIGURATION ;
    __gshared TerminusDurability UNSETTLED_STATE;
    //__gshared TerminusExpiryPolicy CONNECTION_CLOSE ;
    //__gshared TerminusExpiryPolicy NEVER ;

    public UnsignedInteger getValue()
    {
        return UnsignedInteger.valueOf(ordinal());
    }

    public int ordinal()
    {
        return _val;
    }

    public static TerminusDurability get(UnsignedInteger value)
    {
        switch (value.intValue())
        {
            case 0:
                return NONE;
            case 1:
                return CONFIGURATION;
            case 2:
                return UNSETTLED_STATE;
            default:
                return null;
        }
    }

}
