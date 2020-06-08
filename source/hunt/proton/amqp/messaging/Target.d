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

import hunt.Object;
import hunt.String;

class Target : Terminus ,hunt.proton.amqp.transport.Target.Target
{
    this (Target other) {
        super(other);
    }

    this() {

    }

    // override string toString()
    // {
    //     return super.toString;
    // }
    override string toString()
    {
        String address = getAddress();
        IObject nodeProperties = getDynamicNodeProperties();

        return "Target{" ~
               "address='" ~ (address is null ? "null" : address.toString()) ~ '\'' ~
               ", durable=" ~ getDurable().toString() ~
               ", expiryPolicy=" ~ getExpiryPolicy().toString() ~
               ", timeout=" ~ getTimeout().toString() ~
               ", dynamic=" ~ getDynamic().toString() ~
               ", dynamicNodeProperties=" ~ (nodeProperties is null ? "null" : nodeProperties.toString()) ~
               ", capabilities=" ~ (getCapabilities() is null ? "null" : getCapabilities().toString()) ~
               '}';
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
  