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


module hunt.proton.amqp.messaging.MessageAnnotations;

import hunt.collection.Map;
import hunt.proton.amqp.messaging.Section;
import hunt.proton.amqp.Symbol;


class MessageAnnotations : Section
{
    private Map!(Symbol, Object) _value;

    this(Map!(Symbol, Object) value)
    {
        _value = value;
    }

    public Map!(Symbol, Object) getValue()
    {
        return _value;
    }

    override
    public SectionType getType() {
        return SectionType.MessageAnnotations;
    }
}
