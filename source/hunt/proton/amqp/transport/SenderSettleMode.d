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


module hunt.proton.amqp.transport.SenderSettleMode;

import hunt.proton.amqp.UnsignedByte;
import hunt.logging;

import std.concurrency : initOnce;
class SenderSettleMode
{
    //static SenderSettleMode UNSETTLED;
    //static SenderSettleMode SETTLED;
    //static SenderSettleMode MIXED;

    private UnsignedByte value;
    private int likeEnum ;


    this(int likeEnum)
    {
        this.likeEnum = likeEnum;
        this.value = UnsignedByte.valueOf(cast(byte)likeEnum);
    }

    static SenderSettleMode  UNSETTLED() {
        __gshared SenderSettleMode  inst;
        return initOnce!inst(new SenderSettleMode(0));
    }

    static SenderSettleMode  SETTLED() {
        __gshared SenderSettleMode  inst;
        return initOnce!inst(new SenderSettleMode(1));
    }

    static SenderSettleMode  MIXED() {
        __gshared SenderSettleMode  inst;
        return initOnce!inst(new SenderSettleMode(2));
    }

    //static this ()
    //{
    //    UNSETTLED = new SenderSettleMode(0);
    //    SETTLED = new SenderSettleMode(1);
    //    MIXED = new SenderSettleMode(2);
    //}
    override
    bool opEquals (Object o)
    {
        SenderSettleMode other = cast(SenderSettleMode)o;
        if (other !is null)
        {
            return this.getValue == other.getValue;
        }
        return false;
    }

    int getEnum()
    {
        return likeEnum;
    }

    public static SenderSettleMode valueOf(UnsignedByte value) {

        switch (value.intValue()) {

            case 0:
                return SenderSettleMode.UNSETTLED;
            case 1:
                return SenderSettleMode.SETTLED;
            case 2:
                return SenderSettleMode.MIXED;
            default:
            {
                logError("The value can be only 0 (for UNSETTLED), 1 (for SETTLED) and 2 (for MIXED)");
                return null;
            }

        }
    }

    public UnsignedByte getValue() {
        return this.value;
    }
}
