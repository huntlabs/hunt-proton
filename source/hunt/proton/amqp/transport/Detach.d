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

module hunt.proton.amqp.transport.Detach;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.transport.FrameBody;
import hunt.proton.amqp.transport.ErrorCondition;
import hunt.logging;
import hunt.Boolean;

class Detach : FrameBody {
    private UnsignedInteger _handle;
    private Boolean _closed;
    private ErrorCondition _error;

    this() {
        _closed = new Boolean(false);
    }

    this(Detach other) {
        this._handle = other.getHandle();
        this._closed = other.getClosed();
        if (other._error !is null) {
            this._error = new ErrorCondition();
            this._error.copyFrom(other.getError());
        }
    }

    UnsignedInteger getHandle() {
        return _handle;
    }

    void setHandle(UnsignedInteger handle) {
        if (handle is null) {
            logError("the handle field is mandatory");
        }

        _handle = handle;
    }

    Boolean getClosed() {
        return _closed;
    }

    void setClosed(Boolean closed) {
        _closed = closed;
    }

    ErrorCondition getError() {
        return _error;
    }

    void setError(ErrorCondition error) {
        _error = error;
    }

    //override
    void invoke(E)(FrameBodyHandler!E handler, Binary payload, E context) {
        handler.handleDetach(this, payload, context);
    }

    FrameBody copy() {
        return new Detach(this);
    }
}
