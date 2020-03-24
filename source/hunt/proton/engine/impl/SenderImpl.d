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

module hunt.proton.engine.impl.SenderImpl;

import hunt.proton.codec.ReadableBuffer;
import hunt.proton.engine.EndpointState;
import hunt.proton.engine.Sender;
import hunt.proton.engine.impl.LinkImpl;
import hunt.proton.engine.impl.TransportSender;
import hunt.proton.engine.impl.SessionImpl;
import hunt.Exceptions;
import hunt.proton.engine.impl.DeliveryImpl;
import hunt.logging;
class SenderImpl  : LinkImpl , Sender
{
    private int _offered;
    private TransportSender _transportLink;

    this(SessionImpl session, string name)
    {
        super(session, name);
    }

    override
    public void offer(int credits)
    {
        _offered = credits;
    }

    override
    public int send(byte[] bytes, int offset, int length)
    {
        if (getLocalState() == EndpointState.CLOSED)
        {
            throw new IllegalStateException("send not allowed after the sender is closed.");
        }
        DeliveryImpl current = current();
        if (current is null || current.getLink() != this)
        {
            throw new IllegalArgumentException();//TODO.
        }
        int sent = current.send(bytes, offset, length);
        if (sent > 0) {
            getSession().incrementOutgoingBytes(sent);
        }
        return sent;
    }

    override
    public int send(ReadableBuffer buffer)
    {
        if (getLocalState() == EndpointState.CLOSED)
        {
            throw new IllegalStateException("send not allowed after the sender is closed.");
        }
        DeliveryImpl current = current();
        if (current is null || current.getLink() != this)
        {
            throw new IllegalArgumentException();
        }
        int sent = current.send(buffer);
        if (sent > 0) {
            getSession().incrementOutgoingBytes(sent);
        }
        return sent;
    }

    override
    public int sendNoCopy(ReadableBuffer buffer)
    {
        if (getLocalState() == EndpointState.CLOSED)
        {
            throw new IllegalStateException("send not allowed after the sender is closed.");
        }
        DeliveryImpl current = current();
        if (current is null || current.getLink() != this)
        {
            throw new IllegalArgumentException();
        }
        int sent = current.sendNoCopy(buffer);
        if (sent > 0) {
            getSession().incrementOutgoingBytes(sent);
        }
        return sent;
    }

    override
    public void abort()
    {
        //TODO.
    }

    override
    void doFree()
    {
        getSession().freeSender(this);
        super.doFree();
    }

    override
    public bool advance()
    {
        DeliveryImpl delivery = current();
        if (delivery !is null) {
            delivery.setComplete();
        }

        bool advance = super.advance();
        if(advance && _offered > 0)
        {
            _offered--;
        }
        if(advance)
        {
            decrementCredit();
            delivery.addToTransportWorkList();
            getSession().incrementOutgoingDeliveries(1);
        }

        return advance;
    }

    bool hasOfferedCredits()
    {
        return _offered > 0;
    }

    override
    TransportSender getTransportLink()
    {
        return _transportLink;
    }

    void setTransportLink(TransportSender transportLink)
    {
        _transportLink = transportLink;
    }


    override
    public void setCredit(int credit)
    {
        super.setCredit(credit);
       /* while(getQueued()>0 && getCredit()>0)
        {
            advance();
        }*/
    }

    override
    public int getRemoteCredit()
    {
        // Credit is decremented as soon as advance is called on a send,
        // so we need only consider the credit count, not the queued count.
        return getCredit();
    }
}
