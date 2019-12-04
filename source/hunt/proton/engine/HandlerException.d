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

module hunt.proton.engine.HandlerException;
import hunt.proton.engine.Handler;
import hunt.Exceptions;

class HandlerException : RuntimeException {

    private static  long serialVersionUID = 5300211824119834005L;

    private Handler handler;

    this(Handler handler, Throwable cause) {
        super(cause);
        this.handler = handler;
    }

    public Handler getHandler() {
        return handler;
    }
}
