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


module hunt.proton.amqp.transport.Close;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.transport.FrameBody;
import hunt.proton.amqp.transport.ErrorCondition;

class Close : FrameBody
{
    private ErrorCondition _error;

    this() {}

    this(Close other)
    {
        if (other._error !is null)
        {
            this._error = new ErrorCondition();
            this._error.copyFrom(other.getError());
        }
    }

    public ErrorCondition getError()
    {
        return _error;
    }

    public void setError(ErrorCondition error)
    {
        _error = error;
    }

    //override
    public void invoke(E)(FrameBodyHandler!E handler, Binary payload, E context)
    {
        handler.handleClose(this, payload, context);
    }


    public FrameBody copy()
    {
        return new Close(this);
    }
}
