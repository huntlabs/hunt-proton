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


module hunt.proton.amqp.messaging.AmqpSequence;

import hunt.collection.List;
import hunt.Object;
import hunt.proton.amqp.messaging.Section;

class AmqpSequence : Section
{
    private List!Object _value;

    this(List!Object value)
    {
        _value = value;
    }

    public List!Object getValue()
    {
        return _value;
    }

    override
    public SectionType getType() {
        return SectionType.AmqpSequence;
    }
}
