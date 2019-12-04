module hunt.proton.amqp.transport.Target;
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

import hunt.String;

interface Target
{
    String getAddress();

    Target copy();

    string toString();
}
