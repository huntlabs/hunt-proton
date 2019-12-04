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

module hunt.proton.codec.AMQPType;

import hunt.collection.Collection;
import hunt.proton.codec.TypeEncoding;

interface IAMQPType{
    TypeInfo getTypeClass();
    void write(Object val);
    ITypeEncoding getEncoding (Object val);
}

interface AMQPType(V) : IAMQPType
{

    TypeInfo getTypeClass();

    //TypeEncoding!(V) getEncoding(V val);

    TypeEncoding!(V) getCanonicalEncoding();

     Collection!(TypeEncoding!(V)) getAllEncodings();

}
