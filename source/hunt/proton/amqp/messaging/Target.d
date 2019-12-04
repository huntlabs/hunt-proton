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


module hunt.proton.amqp.messaging.Target;

import hunt.proton.amqp.messaging.Terminus;
import hunt.proton.amqp.transport.Target;
import hunt.String;

class Target : Terminus ,hunt.proton.amqp.transport.Target.Target
{
    this (Target other) {
        super(other);
    }

    this() {

    }

    override string toString()
    {
        return super.toString;
    }
    override
    public hunt.proton.amqp.transport.Target.Target copy() {
        return new Target(this);
    }

    override
    String getAddress()
    {
        return super.getAddress();
    }
}
  