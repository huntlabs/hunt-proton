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


module hunt.proton.amqp.transaction.Discharge;

import hunt.proton.amqp.Binary;
import hunt.logging;
import hunt.Boolean;

class Discharge
{

    private Binary _txnId;
    private Boolean _fail;

    public Binary getTxnId()
    {
        return _txnId;
    }

    public void setTxnId(Binary txnId)
    {
        if( txnId is null )
        {
            logError("the txn-id field is mandatory");
        }

        _txnId = txnId;
    }

    public Boolean getFail()
    {
        return _fail;
    }

    public void setFail(Boolean fail)
    {
        _fail = fail;
    }

}
  