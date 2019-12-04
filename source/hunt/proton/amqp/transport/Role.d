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


module hunt.proton.amqp.transport.Role;

import hunt.Enum;
import  std.concurrency : initOnce;
import hunt.Boolean;

class Role : AbstractEnum!int {

    int _val ;

    static Role  SENDER() {
        __gshared Role  inst;
        return initOnce!inst(new Role("SENDER",0));
    }

    static Role  RECEIVER() {
        __gshared Role  inst;
        return initOnce!inst(new Role("RECEIVER",1));
    }

    this(string name , int r)
    {
        super(name,r);
        this._val = r;
    }

    public Boolean getValue()
    {
        return new Boolean (this.name() == "RECEIVER");
    }

    public int getVal()
    {
        return this._val;
    }

    //int opCmp(int o)
    //{
    //    return this._val - o;
    //}



    // SENDER, RECEIVER
}



