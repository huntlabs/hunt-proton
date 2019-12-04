module hunt.proton.ProtonException;

import std.stdio;
import hunt.Exceptions;


class ProtonException : RuntimeException {


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

