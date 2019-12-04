/*
 * hunt-proton: AMQP Protocol library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net
 *
 * Licensed under the Apache-2.0 License.
 *
 */
module hunt.proton.engine.TransportResult;

interface TransportResult
{
    enum Status
    {
        OK,
        ERROR
    }

    Status getStatus();

    string getErrorDescription();

    Exception getException();

    /**
     * @throws TransportException if the result's state is not ok.
     */
    void checkIsOk();

    bool isOk();

}
