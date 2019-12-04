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


module hunt.proton.amqp.transport.Attach;


import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.FrameBody;
import hunt.proton.amqp.transport.Role;
import hunt.proton.amqp.transport.SenderSettleMode;
import hunt.proton.amqp.transport.ReceiverSettleMode;
import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.transport.Target;
import hunt.Object;
import hunt.logging;
import hunt.collection.Map;
import hunt.collection.LinkedHashMap;
import hunt.String;
import hunt.Boolean;
import hunt.collection.List;
import std.conv:to;

class Attach : FrameBody
{
    private String _name;
    private UnsignedInteger _handle;
    private Role _role ;//= Role.SENDER;
    private SenderSettleMode _sndSettleMode ;
    private ReceiverSettleMode _rcvSettleMode ;
    private Source _source;
    private Target _target;
    private Map!(Symbol,Object) _unsettled;
    private Boolean _incompleteUnsettled;
    private UnsignedInteger _initialDeliveryCount;
    private UnsignedLong _maxMessageSize;
    private List!Symbol _offeredCapabilities;
    private List!Symbol _desiredCapabilities;
    private Map!(Symbol,Object) _properties;


    override
    public string toString()
    {
        string att = "Attach{";

       return att ~ "name=" ~ _name.value ~
        ", handle=" ~ (to!string(_handle.intValue)) ~
        ", role=" ~ (to!string(_role.ordinal)) ~
        ", sndSettleMode=" ~ (to!string(_sndSettleMode.getValue.intValue)) ~
        ", rcvSettleMode=" ~ (to!string(_rcvSettleMode.getValue.intValue) )~
        ", source="  ~ _source.toString ~
        ", target="  ~ _target.toString ~
        ", unsettled=" ~ (_unsettled is null ? "null" : "") ~
        ", incompleteUnsettled=" ~  (_incompleteUnsettled is null ? "null" : to!string(_incompleteUnsettled.booleanValue())) ~
        ", initialDeliveryCount=" ~ ( _initialDeliveryCount is null ? "null": to!string(_initialDeliveryCount.intValue)) ~
        ", maxMessageSize=" ~ (_maxMessageSize is null ? "null" :  to!string(_maxMessageSize.longValue())) ~
        ", offeredCapabilities=" ~ (_offeredCapabilities is null ? "null" : "") ~
        ", desiredCapabilities=" ~ (_desiredCapabilities is null ? "null" : "") ~
        ", properties=" ~ (_properties is null? "null":"") ~
        '}';
    }


    this() {
        _sndSettleMode = SenderSettleMode.MIXED;
        _rcvSettleMode = ReceiverSettleMode.FIRST;
        _role = Role.SENDER;
        _desiredCapabilities = null;
        _offeredCapabilities = null;
        _properties = null;
        _unsettled = null;
       _incompleteUnsettled = new Boolean(false);
    }

    this(Attach other)
    {
        this._name = other.getName();
        this._handle = other.getHandle();
        this._role = other.getRole();
        this._sndSettleMode = other.getSndSettleMode();
        this._rcvSettleMode = other.getRcvSettleMode();
        if (other._source !is null) {
            this._source = other.getSource().copy();
        }
        if (other._target !is null) {
            this._target = other.getTarget().copy();
        }
        if (other._unsettled !is null) {
            this._unsettled = new LinkedHashMap!(Symbol,Object)(other.getUnsettled());
        }
        this._incompleteUnsettled = other.getIncompleteUnsettled();
        this._initialDeliveryCount = other.getInitialDeliveryCount();
        this._maxMessageSize = other.getMaxMessageSize();
        if (other.getOfferedCapabilities() !is null) {
            this._offeredCapabilities = other.getOfferedCapabilities();
        }
        if (other.getDesiredCapabilities() !is null) {
            this._desiredCapabilities = other.getDesiredCapabilities();
        }
        if (other.getProperties() !is null) {
            this._properties = new LinkedHashMap!(Symbol,Object)(other.getProperties());
        }
    }

    public String getName()
    {
        return _name;
    }

    public void setName(String name)
    {
        if( name is null )
        {
            logError("the name field is mandatory");
        }

        _name = name;
    }

    public UnsignedInteger getHandle()
    {
        return _handle;
    }

    public void setHandle(UnsignedInteger handle)
    {
        if( handle is null )
        {
            logError("the handle field is mandatory");
        }

        _handle = handle;
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

    public SenderSettleMode getSndSettleMode()
    {
        return _sndSettleMode;
    }

    public void setSndSettleMode(SenderSettleMode sndSettleMode)
    {
        _sndSettleMode = sndSettleMode is null ? SenderSettleMode.MIXED : sndSettleMode;
    }

    public ReceiverSettleMode getRcvSettleMode()
    {
        return _rcvSettleMode;
    }

    public void setRcvSettleMode(ReceiverSettleMode rcvSettleMode)
    {
        _rcvSettleMode = rcvSettleMode is null ? ReceiverSettleMode.FIRST : rcvSettleMode;
    }

    public Source getSource()
    {
        return _source;
    }

    public void setSource(Source source)
    {
        _source = source;
    }

    public Target getTarget()
    {
        return _target;
    }

    public void setTarget(Target target)
    {
        _target = target;
    }

    public Map!(Symbol,Object) getUnsettled()
    {
        return _unsettled;
    }

    public void setUnsettled(Map!(Symbol,Object) unsettled)
    {
        _unsettled = unsettled;
    }

    public Boolean getIncompleteUnsettled()
    {
        return _incompleteUnsettled;
    }

    public void setIncompleteUnsettled(Boolean incompleteUnsettled)
    {
        _incompleteUnsettled = incompleteUnsettled;
    }

    public UnsignedInteger getInitialDeliveryCount()
    {
        return _initialDeliveryCount;
    }

    public void setInitialDeliveryCount(UnsignedInteger initialDeliveryCount)
    {
        _initialDeliveryCount = initialDeliveryCount;
    }

    public UnsignedLong getMaxMessageSize()
    {
        return _maxMessageSize;
    }

    public void setMaxMessageSize(UnsignedLong maxMessageSize)
    {
        _maxMessageSize = maxMessageSize;
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
        handler.handleAttach(this, payload, context);
    }


    public FrameBody copy()
    {
        return new Attach(this);
    }
}
