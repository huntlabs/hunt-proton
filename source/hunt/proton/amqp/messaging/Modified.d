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

module hunt.proton.amqp.messaging.Modified;

import hunt.collection.Map;
import hunt.Object;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.amqp.messaging.Outcome;

import std.concurrency: initOnce;
import hunt.Boolean;

class Modified : DeliveryState, Outcome
{
  //  public static Symbol DESCRIPTOR_SYMBOL = Symbol.valueOf("amqp:modified:list");


    static Symbol DESCRIPTOR_SYMBOL()
    {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("amqp:modified:list"));
    }


    private Boolean _deliveryFailed;
    private Boolean _undeliverableHere;
    private Map!(Symbol, Object) _messageAnnotations;

    public Boolean getDeliveryFailed()
    {
        return _deliveryFailed;
    }

    public void setDeliveryFailed(Boolean deliveryFailed)
    {
        _deliveryFailed =   deliveryFailed;
    }

    public Boolean getUndeliverableHere()
    {
        return _undeliverableHere;
    }

    public void setUndeliverableHere(Boolean undeliverableHere)
    {
        _undeliverableHere =  undeliverableHere;
    }

    public Map!(Symbol, Object) getMessageAnnotations()
    {
        return _messageAnnotations;
    }

    public void setMessageAnnotations(Map!(Symbol, Object) messageAnnotations)
    {
        _messageAnnotations = messageAnnotations;
    }

    override
    public DeliveryStateType getType() {
        return DeliveryStateType.Modified;
    }
}
