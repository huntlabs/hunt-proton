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


module hunt.proton.amqp.messaging.ApplicationProperties;

import hunt.collection.Map;
import hunt.proton.amqp.messaging.Section;
import hunt.String;

class ApplicationProperties : Section
{
    private Map!(String, Object) _value;

    this(Map!(String, Object) value)
    {
        _value = value;
    }

    public Map!(String, Object) getValue()
    {
        return _value;
    }

    override
    public SectionType getType() {
        return SectionType.ApplicationProperties;
    }
}
