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


module hunt.proton.amqp.messaging.Data;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.messaging.Section;

class Data : Section
{
    private Binary _value;

    this (Binary value)
    {
        _value = value;
    }

    public Binary getValue()
    {
        return _value;
    }


    override
    public SectionType getType() {
        return SectionType.Data;
    }
}
