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

module hunt.proton.codec.impl.TimestampElement;

import std.datetime.date;
import hunt.collection.ByteBuffer;
import std.conv;
import hunt.proton.codec.impl.AtomicElement;
import hunt.proton.codec.impl.Element;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.AbstractElement;
//import hunt.util.DateTime;
import hunt.time.LocalDateTime;


import hunt.proton.codec.Data;

alias Date = LocalDateTime;

class TimestampElement : AtomicElement!Date
{

   // private Date _value;
    private Date _value;

    this(IElement parent, IElement prev, Date d)
    {
        super(parent, prev);
        _value = d;
    }

    public int size()
    {
        return isElementOfArray() ? 8 : 9;
    }

    public Object getValue()
    {
        return _value;
    }

    public Data.DataType getDataType()
    {
        return Data.DataType.TIMESTAMP;
    }

    public int encode(ByteBuffer b)
    {
        int size = size();
        if(size > b.remaining())
        {
            return 0;
        }
        if(size == 9)
        {
            b.put(cast(byte)0x83);
        }
        b.putLong(_value.toEpochMilli());
        return size;
    }
}
