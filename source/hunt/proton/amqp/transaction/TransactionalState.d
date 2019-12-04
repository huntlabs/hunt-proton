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


module hunt.proton.amqp.transaction.TransactionalState;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.messaging.Outcome;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.logging;

class TransactionalState : DeliveryState
{
    private Binary _txnId;
    private Outcome _outcome;

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

    public Outcome getOutcome()
    {
        return _outcome;
    }

    public void setOutcome(Outcome outcome)
    {
        _outcome = outcome;
    }

    override
    public DeliveryStateType getType() {
        return DeliveryStateType.Transactional;
    }
}
