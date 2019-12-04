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

module hunt.proton.codec.PrimitiveType;

import hunt.collection.Collection;
import hunt.proton.codec.AMQPType;
import hunt.proton.codec.PrimitiveTypeEncoding;

interface PrimitiveType(V) : AMQPType!(V)
{

   // PrimitiveTypeEncoding!(V) getEncoding(V val);

    PrimitiveTypeEncoding!(V) getCanonicalEncoding();

   // Collection!(PrimitiveTypeEncoding!(V)) getAllEncodings();

}
