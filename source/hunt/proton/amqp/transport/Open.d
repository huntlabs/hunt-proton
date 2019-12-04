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


module hunt.proton.amqp.transport.Open;


import hunt.proton.amqp.transport.FrameBody;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedShort;
import hunt.Object;
import hunt.logging;
import hunt.collection.Map;
import hunt.collection.LinkedHashMap;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.String;

class Open : FrameBody
{
    private String _containerId;
    private String _hostname;
    private UnsignedInteger _maxFrameSize;
    private UnsignedShort _channelMax;
    private UnsignedInteger _idleTimeOut;
    private List!Symbol _outgoingLocales;
    private List!Symbol _incomingLocales;
    private List!Symbol _offeredCapabilities;
    private List!Symbol _desiredCapabilities;
    private Map!(Symbol,Object) _properties;

    this() {
       _maxFrameSize =  UnsignedInteger.valueOf(0xffffffff);
        _channelMax = UnsignedShort.valueOf(cast(short)65535);
    }

    this(Open other)
    {
        this._containerId = other._containerId;
        this._hostname = other._hostname;
        this._maxFrameSize = other._maxFrameSize;
        this._channelMax = other._channelMax;
        this._idleTimeOut = other._idleTimeOut;
        if (other._outgoingLocales !is null) {
            this._outgoingLocales = other.getOutgoingLocales();
        }
        if (other._incomingLocales !is null) {
            this._incomingLocales = other.getIncomingLocales();
        }
        if (other._offeredCapabilities !is null) {
            this._offeredCapabilities = other.getOfferedCapabilities();
        }
        if (other._desiredCapabilities !is null) {
            this._desiredCapabilities = other.getDesiredCapabilities();
        }
        if (other._properties !is null) {
            this._properties = new LinkedHashMap!(Symbol,Object)(other.getProperties());
        }
    }

    public String getContainerId()
    {
        return _containerId;
    }

    public void setContainerId(String containerId)
    {
        if( containerId is null )
        {
            logError("the container-id field is mandatory");
        }

        _containerId = containerId;
    }

    public String getHostname()
    {
        return _hostname;
    }

    public void setHostname(String hostname)
    {
        _hostname = hostname;
    }

    public UnsignedInteger getMaxFrameSize()
    {
        return _maxFrameSize;
    }

    public void setMaxFrameSize(UnsignedInteger maxFrameSize)
    {
        _maxFrameSize = maxFrameSize;
    }

    public UnsignedShort getChannelMax()
    {
        return _channelMax;
    }

    public void setChannelMax(UnsignedShort channelMax)
    {
        _channelMax = channelMax;
    }

    public UnsignedInteger getIdleTimeOut()
    {
        return _idleTimeOut;
    }

    public void setIdleTimeOut(UnsignedInteger idleTimeOut)
    {
        _idleTimeOut = idleTimeOut;
    }

    public List!Symbol getOutgoingLocales()
    {
        return _outgoingLocales;
    }

    public void setOutgoingLocales(List!Symbol outgoingLocales)
    {
        _outgoingLocales = outgoingLocales;
    }

    public List!Symbol getIncomingLocales()
    {
        return _incomingLocales;
    }

    public void setIncomingLocales(List!Symbol incomingLocales)
    {
        _incomingLocales = incomingLocales;
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


    public void invoke(E)(FrameBodyHandler!E handler, Binary payload, E context)
    {
        handler.handleOpen(this, payload, context);
    }


    public FrameBody copy()
    {
        return new Open(this);
    }
}
