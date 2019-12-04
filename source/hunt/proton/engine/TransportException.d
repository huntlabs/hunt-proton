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

module hunt.proton.engine.TransportException;


import hunt.proton.ProtonException;

class TransportException : ProtonException
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

    //private static String format(String format, Object ... args)
    //{
    //    try
    //    {
    //        return String.format(format, args);
    //    }
    //    catch(IllegalFormatException e)
    //    {
    //        LOGGER.log(Level.SEVERE, "Formating error in string " + format, e);
    //        return format;
    //    }
    //}

    //public TransportException(String format, Object ... args)
    //{
    //    this(format(format, args));
    //}

}
