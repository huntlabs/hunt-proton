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

module hunt.proton.engine.impl.ReceiverImpl;

import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.WritableBuffer;
import hunt.proton.engine.Receiver;
import hunt.proton.engine.impl.LinkImpl;
import hunt.proton.engine.impl.DeliveryImpl;
import hunt.proton.engine.impl.TransportReceiver;
import hunt.proton.engine.impl.SessionImpl;
import hunt.Exceptions;


class ReceiverImpl : LinkImpl , Receiver
{
    private bool _drainFlagMode = true;

    override
    public bool advance()
    {
        DeliveryImpl current = current();
        if(current !is null)
        {
            current.setDone();
        }
        bool advance = super.advance();
        if(advance)
        {
            decrementQueued();
            decrementCredit();
            getSession().incrementIncomingBytes(-current.pending());
            getSession().incrementIncomingDeliveries(-1);
            if (getSession().getTransportSession().getIncomingWindowSize() == (UnsignedInteger.ZERO)) {
                modified();
            }
        }
        return advance;
    }

    private TransportReceiver _transportReceiver;
    private int _unsentCredits;


    this(SessionImpl session, string name)
    {
        super(session, name);
    }

    override
    public void flow(int credits)
    {
        addCredit(credits);
        _unsentCredits += credits;
        modified();
        if (!_drainFlagMode)
        {
            setDrain(false);
            _drainFlagMode = false;
        }
    }

    int clearUnsentCredits()
    {
        int credits = _unsentCredits;
        _unsentCredits = 0;
        return credits;
    }

    override
    public int recv(byte[] bytes, int offset, int size)
    {
        if (_current is null) {
            throw new IllegalStateException("no current delivery");
        }

        int consumed = _current.recv(bytes, offset, size);
        if (consumed > 0) {
            getSession().incrementIncomingBytes(-consumed);
            if (getSession().getTransportSession().getIncomingWindowSize() == (UnsignedInteger.ZERO)) {
                modified();
            }
        }
        return consumed;
    }

    override
    public int recv(WritableBuffer buffer)
    {
        if (_current is null) {
            throw new IllegalStateException("no current delivery");
        }

        int consumed = _current.recv(buffer);
        if (consumed > 0) {
            getSession().incrementIncomingBytes(-consumed);
            if (getSession().getTransportSession().getIncomingWindowSize() == (UnsignedInteger.ZERO)) {
                modified();
            }
        }
        return consumed;
    }

    override
    public ReadableBuffer recv()
    {
        if (_current is null) {
            throw new IllegalStateException("no current delivery");
        }

        ReadableBuffer consumed = _current.recv();
        if (consumed.remaining() > 0) {
            getSession().incrementIncomingBytes(-consumed.remaining());
            if (getSession().getTransportSession().getIncomingWindowSize() == (UnsignedInteger.ZERO)) {
                modified();
            }
        }
        return consumed;
    }

    override
    void doFree()
    {
        getSession().freeReceiver(this);
        super.doFree();
    }

    bool hasIncoming()
    {
        return false;  //TODO - Implement
    }

    void setTransportLink(TransportReceiver transportReceiver)
    {
        _transportReceiver = transportReceiver;
    }

    override
    TransportReceiver getTransportLink()
    {
        return _transportReceiver;
    }

    override
    public void drain(int credit)
    {
        setDrain(true);
        flow(credit);
        _drainFlagMode = false;
    }

    override
    public bool draining()
    {
        return getDrain() && (getCredit() > getQueued());
    }

    override
    public void setDrain(bool drain)
    {
        super.setDrain(drain);
        modified();
        _drainFlagMode = true;
    }

    override
    public int getRemoteCredit()
    {
        // Credit is only decremented once advance is called on a received message,
        // so we also need to consider the queued count.
        return getCredit() - getQueued();
    }
}
