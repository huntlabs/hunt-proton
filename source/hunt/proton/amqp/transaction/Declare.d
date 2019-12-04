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


module hunt.proton.amqp.transaction.Declare;


import hunt.proton.amqp.transaction.GlobalTxId;

class Declare
{

    private GlobalTxId _globalId;

    public GlobalTxId getGlobalId()
    {
        return _globalId;
    }

    public void setGlobalId(GlobalTxId globalId)
    {
        _globalId = globalId;
    }

}
  