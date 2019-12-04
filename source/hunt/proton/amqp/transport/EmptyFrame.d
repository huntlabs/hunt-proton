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
module hunt.proton.amqp.transport.EmptyFrame;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.transport.FrameBody;

import std.concurrency : initOnce;

class EmptyFrame : FrameBody
{
    //public static EmptyFrame INSTANCE = new EmptyFrame();

    //override
    public void invoke(E)(FrameBodyHandler!E handler, Binary payload, E context)
    {
        // NO-OP
    }

    static EmptyFrame  INSTANCE() {
        __gshared EmptyFrame  inst;
        return initOnce!inst(new EmptyFrame());
    }

    public FrameBody copy()
    {
        return new EmptyFrame();
    }
}
