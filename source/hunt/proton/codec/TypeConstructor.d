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

module hunt.proton.codec.TypeConstructor;

interface TypeConstructor(V) : ITypeConstructor
{
   // V readValue();readValue
}

interface ITypeConstructor
{
    void skipValue();

    bool encodesJavaPrimitive();

    TypeInfo getTypeClass();
    Object  readValue();
}