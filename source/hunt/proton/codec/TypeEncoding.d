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

module hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.AMQPType;


interface ITypeEncoding
{
    void writeConstructor();

    int getConstructorSize();
    bool isFixedSizeVal();
    bool encodesJavaPrimitive();
    int getValueSize(Object val);
    void writeValue(Object val);
    int opCmp(ITypeEncoding o);
}

interface TypeEncoding(V) : ITypeEncoding
{
    AMQPType!(V) getType();
    bool encodesSuperset(TypeEncoding!(V) encoder);
}
