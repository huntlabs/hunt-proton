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

module hunt.proton.codec.PrimitiveTypeEncoding;

import hunt.proton.codec.PrimitiveType;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.TypeConstructor;

interface IPrimitiveTypeEncoding
{
    byte getEncodingCode();

    void writeConstructor();

    int getConstructorSize();
}

interface PrimitiveTypeEncoding(T) : TypeEncoding!(T), TypeConstructor!(T) ,IPrimitiveTypeEncoding
{
    PrimitiveType!(T) getType();
}
