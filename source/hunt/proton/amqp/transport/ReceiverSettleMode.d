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


module hunt.proton.amqp.transport.ReceiverSettleMode;

import hunt.proton.amqp.UnsignedByte;
import hunt.logging;
import std.concurrency : initOnce;

class ReceiverSettleMode
{
    //static ReceiverSettleMode FIRST;
    //static ReceiverSettleMode SECOND;

    static ReceiverSettleMode  FIRST() {
        __gshared ReceiverSettleMode  inst;
        return initOnce!inst(new ReceiverSettleMode(0));
    }
    static ReceiverSettleMode  SECOND() {
        __gshared ReceiverSettleMode  inst;
        return initOnce!inst(new ReceiverSettleMode(1));
    }

    private UnsignedByte value;
    private int likeEnum ;


    this(int likeEnum)
    {
        this.likeEnum = likeEnum;
        this.value = UnsignedByte.valueOf(cast(byte)likeEnum);
    }


    //static this()
    //{
    //    FIRST = new ReceiverSettleMode(0);
    //    SECOND = new ReceiverSettleMode(1);
    //}

    int getEnum()
    {
        return likeEnum;
    }

    public static ReceiverSettleMode valueOf(UnsignedByte value) {

        switch (value.intValue()) {
            case 0:
                return ReceiverSettleMode.FIRST;
            case 1:
                return ReceiverSettleMode.SECOND;
            default:
            {
                logError("The value can be only 0 (for FIRST) and 1 (for SECOND)");
                return null;
            }

        }
    }

    override bool opEquals(Object o)
    {
        ReceiverSettleMode other = cast(ReceiverSettleMode)o;
        if (other !is null)
        {
            return getEnum() == other.getEnum();
        }
        return false;
    }

    public UnsignedByte getValue() {
        return this.value;
    }
}
