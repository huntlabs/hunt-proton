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

module hunt.proton.codec.AbstractPrimitiveType;

import hunt.proton.codec.PrimitiveType;
import hunt.proton.codec.TypeEncoding;


abstract class AbstractPrimitiveType(T) : PrimitiveType!(T)
{
    public void write(Object val)
    {
        T t = cast(T)val;
        assert(t !is null);
       // TypeEncoding!(T) encoding = getEncoding(t);
        ITypeEncoding encoding = getEncoding(val);
        encoding.writeConstructor();
        encoding.writeValue(val);
    }
}
