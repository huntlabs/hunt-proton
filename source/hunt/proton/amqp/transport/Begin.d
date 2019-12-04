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


module hunt.proton.amqp.transport.Begin;

import hunt.Object;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedShort;
import hunt.proton.amqp.transport.FrameBody;
import hunt.logging;
import hunt.collection.Map;
import hunt.collection.LinkedHashMap;
import hunt.collection.List;


class Begin : FrameBody
{
    private UnsignedShort _remoteChannel;
    private UnsignedInteger _nextOutgoingId;
    private UnsignedInteger _incomingWindow;
    private UnsignedInteger _outgoingWindow;
    private UnsignedInteger _handleMax ;
    private List!Symbol _offeredCapabilities;
    private List!Symbol _desiredCapabilities;
    private Map!(Symbol,Object) _properties;

    this() {
        _handleMax = UnsignedInteger.valueOf(0xffffffff);
        _properties = null;
    }

    this(Begin other)
    {
        this._remoteChannel = other._remoteChannel;
        this._nextOutgoingId = other._nextOutgoingId;
        this._incomingWindow = other._incomingWindow;
        this._outgoingWindow = other._outgoingWindow;
        this._handleMax = other._handleMax;
        if (other._offeredCapabilities !is null) {
            this._offeredCapabilities = other.getOfferedCapabilities();
        }
        if (other._desiredCapabilities !is null) {
            this._desiredCapabilities = other.getDesiredCapabilities();
        }
        if (other._properties !is null) {
            this._properties = new LinkedHashMap!(Symbol,Object)(other._properties);
        }
    }

    public UnsignedShort getRemoteChannel()
    {
        return _remoteChannel;
    }

    public void setRemoteChannel(UnsignedShort remoteChannel)
    {
        _remoteChannel = remoteChannel;
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

    public UnsignedInteger getHandleMax()
    {
        return _handleMax;
    }

    public void setHandleMax(UnsignedInteger handleMax)
    {
        _handleMax = handleMax;
    }

    public List!Symbol getOfferedCapabilities()
    {
        return _offeredCapabilities;
    }

    public void setOfferedCapabilities(List!Symbol offeredCapabilities)
    {
        _offeredCapabilities = offeredCapabilities;
    }

    public List!Symbol getDesiredCapabilities()
    {
        return _desiredCapabilities;
    }

    public void setDesiredCapabilities(List!Symbol desiredCapabilities)
    {
        _desiredCapabilities = desiredCapabilities;
    }

    public Map!(Symbol,Object) getProperties()
    {
        return _properties;
    }

    public void setProperties(Map!(Symbol,Object) properties)
    {
        _properties = properties;
    }

    //override
    public void invoke(E)(FrameBodyHandler!E handler, Binary payload, E context)
    {
        handler.handleBegin(this, payload, context);
    }

    public FrameBody copy()
    {
        return new Begin(this);
    }
}
