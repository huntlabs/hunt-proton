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

module hunt.proton.codec.DecodeException;
import hunt.Exceptions;

class DecodeException : RuntimeException
{

    this(string message)
    {
        super(message);
    }

    this(string message, Throwable cause)
    {
        super(message, cause);
    }

    this(Throwable cause)
    {
        super(cause);
    }
}