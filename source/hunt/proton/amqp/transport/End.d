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


module hunt.proton.amqp.transport.End;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.transport.FrameBody;
import hunt.proton.amqp.transport.ErrorCondition;

class End : FrameBody
{
    private ErrorCondition _error;

    this() {}

    this(End other)
    {
        if (other._error !is null)
        {
            this._error = new ErrorCondition();
            this._error.copyFrom(other._error);
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


    public void invoke(E)(FrameBodyHandler!E handler, Binary payload, E context)
    {
        handler.handleEnd(this, payload, context);
    }

    //public void invoke(E)(SaslFrameBodyHandler!E handler, Binary payload, E context)
    //{
    //    handler.handleMechanisms(this, payload, context);
    //}


    public FrameBody copy()
    {
        return new End(this);
    }
}
