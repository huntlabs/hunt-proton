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


module hunt.proton.amqp.messaging.AmqpValue;

import hunt.proton.amqp.messaging.Section;
import hunt.String;

class AmqpValue : Section
{
    private String _value;
    private TypeInfo _type;

    this (Object value)
    {
        _value = cast(String)value;
    }

    public String getValue()
    {
        return _value;
    }

    //public TypeInfo getTypeInfo()
    //{
    //    return _type;
    //}

    override
    public SectionType getType() {
        return SectionType.AmqpValue;
    }
}
