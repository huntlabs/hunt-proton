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
module hunt.proton.engine.impl.AmqpHeader;

interface AmqpHeader
{
    public static byte[] HEADER =
            [ 'A', 'M', 'Q', 'P', 0, 1, 0, 0 ];

    public static byte[] SASL_HEADER =
            [ 'A', 'M', 'Q', 'P', 3, 1, 0, 0 ];
}
