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


module hunt.proton.amqp.transport.Disposition;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.transport.Role;
import hunt.proton.amqp.transport.FrameBody;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.logging;
import hunt.Boolean;

class Disposition : FrameBody
{
    private Role _role ;//= Role.SENDER;
    private UnsignedInteger _first;
    private UnsignedInteger _last;
    private Boolean _settled;
    private DeliveryState _state;
    private Boolean _batchable;

    this() {
        _role = Role.SENDER;
        _settled = new Boolean(false);
        _batchable = new Boolean(false);
    }

    this(Disposition other)
    {
        this._role = other.getRole();
        this._first = other.getFirst();
        this._last = other.getLast();
        this._settled = other.getSettled();
        this._state = other.getState();
        this._batchable = other.getBatchable();
    }

    public Role getRole()
    {
        return _role;
    }

    public void setRole(Role role)
    {
        if(role is null)
        {
            logError("Role cannot be null");
        }
        _role = role;
    }

    public UnsignedInteger getFirst()
    {
        return _first;
    }

    public void setFirst(UnsignedInteger first)
    {
        if( first is null )
        {
            logError("the first field is mandatory");
        }

        _first = first;
    }

    public UnsignedInteger getLast()
    {
        return _last;
    }

    public void setLast(UnsignedInteger last)
    {
        _last = last;
    }

    public Boolean getSettled()
    {
        return _settled;
    }

    public void setSettled(Boolean settled)
    {
        _settled = settled;
    }

    public DeliveryState getState()
    {
        return _state;
    }

    public void setState(DeliveryState state)
    {
        _state = state;
    }

    public Boolean getBatchable()
    {
        return _batchable;
    }

    public void setBatchable(Boolean batchable)
    {
        _batchable = batchable;
    }

    //override
    public void invoke(E)(FrameBodyHandler!E handler, Binary payload, E context)
    {
        handler.handleDisposition(this, payload, context);
    }


    public FrameBody copy()
    {
        return new Disposition(this);
    }
}
