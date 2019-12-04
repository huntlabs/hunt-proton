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


module hunt.proton.amqp.transport.Flow;

import hunt.proton.amqp.transport.FrameBody;
import hunt.logging;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.UnsignedInteger;
import hunt.Object;
import hunt.collection.Map;
import hunt.collection.LinkedHashMap;
import hunt.Boolean;

class Flow : FrameBody
{
    private UnsignedInteger _nextIncomingId;
    private UnsignedInteger _incomingWindow;
    private UnsignedInteger _nextOutgoingId;
    private UnsignedInteger _outgoingWindow;
    private UnsignedInteger _handle;
    private UnsignedInteger _deliveryCount;
    private UnsignedInteger _linkCredit;
    private UnsignedInteger _available;
    private Boolean _drain;
    private Boolean _echo;
    private IObject _properties;

    this() {
        _drain = new Boolean(false);
        _echo = new Boolean(false);
    }

    this(Flow other)
    {
        this._nextIncomingId = other._nextIncomingId;
        this._incomingWindow = other._incomingWindow;
        this._nextOutgoingId = other._nextOutgoingId;
        this._outgoingWindow = other._outgoingWindow;
        this._handle = other._handle;
        this._deliveryCount = other._deliveryCount;
        this._linkCredit = other._linkCredit;
        this._available = other._available;
        this._drain = other._drain;
        this._echo = other._echo;
        if (other._properties !is null)
        {
            this._properties = other._properties;
        }
    }

    public UnsignedInteger getNextIncomingId()
    {
        return _nextIncomingId;
    }

    public void setNextIncomingId(UnsignedInteger nextIncomingId)
    {
        _nextIncomingId = nextIncomingId;
    }

    public UnsignedInteger getIncomingWindow()
    {
        return _incomingWindow;
    }

    public void setIncomingWindow(UnsignedInteger incomingWindow)
    {
        if( incomingWindow is null )
        {
            logError("the incoming-window field is mandatory");
        }

        _incomingWindow = incomingWindow;
    }

    public UnsignedInteger getNextOutgoingId()
    {
        return _nextOutgoingId;
    }

    public void setNextOutgoingId(UnsignedInteger nextOutgoingId)
    {
        if( nextOutgoingId is null )
        {
            logError("the next-outgoing-id field is mandatory");
        }

        _nextOutgoingId = nextOutgoingId;
    }

    public UnsignedInteger getOutgoingWindow()
    {
        return _outgoingWindow;
    }

    public void setOutgoingWindow(UnsignedInteger outgoingWindow)
    {
        if( outgoingWindow is null )
        {
            logError("the outgoing-window field is mandatory");
        }

        _outgoingWindow = outgoingWindow;
    }

    public UnsignedInteger getHandle()
    {
        return _handle;
    }

    public void setHandle(UnsignedInteger handle)
    {
        _handle = handle;
    }

    public UnsignedInteger getDeliveryCount()
    {
        return _deliveryCount;
    }

    public void setDeliveryCount(UnsignedInteger deliveryCount)
    {
        _deliveryCount = deliveryCount;
    }

    public UnsignedInteger getLinkCredit()
    {
        return _linkCredit;
    }

    public void setLinkCredit(UnsignedInteger linkCredit)
    {
        _linkCredit = linkCredit;
    }

    public UnsignedInteger getAvailable()
    {
        return _available;
    }

    public void setAvailable(UnsignedInteger available)
    {
        _available = available;
    }

    public Boolean getDrain()
    {
        return _drain;
    }

    public void setDrain(Boolean drain)
    {
        _drain = drain;
    }

    public Boolean getEcho()
    {
        return _echo;
    }

    public void setEcho(Boolean echo)
    {
        _echo = echo;
    }

    public IObject getProperties()
    {
        return _properties;
    }

    public void setProperties(IObject properties)
    {
        _properties = properties;
    }

    public void invoke(E)(FrameBodyHandler!E handler, Binary payload, E context)
    {
        handler.handleFlow(this, payload, context);
    }


    public FrameBody copy()
    {
        return new Flow(this);
    }
}
