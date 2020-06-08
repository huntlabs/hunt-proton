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

module hunt.proton.amqp.messaging.Terminus;

import hunt.collection.HashMap;
import hunt.collection.Map;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.Object;
import hunt.proton.amqp.messaging.TerminusDurability;
import hunt.proton.amqp.messaging.TerminusExpiryPolicy;
import hunt.String;
import hunt.Boolean;

import hunt.collection.List;
import hunt.collection.ArrayList;
import std.conv:to;
abstract class Terminus
{
    private String _address;
    private TerminusDurability _durable ;//= TerminusDurability.NONE;
    private TerminusExpiryPolicy _expiryPolicy ; //= TerminusExpiryPolicy.SESSION_END;
    private UnsignedInteger _timeout ;// UnsignedInteger.valueOf(0);
    private Boolean _dynamic;
    private IObject _dynamicNodeProperties;
    private List!Symbol _capabilities;

    this(Terminus other) {
        _address = other._address;
        _durable = other._durable;
        _expiryPolicy = other._expiryPolicy;
        _timeout = other._timeout;
        _dynamic = other._dynamic;
        if (other._dynamicNodeProperties !is null) {
            // TODO: Do we need to copy or can we make a simple reference?
            _dynamicNodeProperties = other._dynamicNodeProperties;
        }
        if (other._capabilities !is null) {
            _capabilities = other._capabilities;
        }
    }

    this()
    {
        _durable = TerminusDurability.NONE;
        _expiryPolicy = TerminusExpiryPolicy.SESSION_END;
        _timeout = UnsignedInteger.valueOf(0);
        _dynamic = new Boolean(false);
    }

    public String getAddress()
    {
        return _address;
    }

    public void setAddress(String address)
    {
        _address =  address;
    }

    public TerminusDurability getDurable()
    {
        return _durable;
    }

    public void setDurable(TerminusDurability durable)
    {
        _durable = durable is null ? TerminusDurability.NONE : durable;
    }

    public TerminusExpiryPolicy getExpiryPolicy()
    {
        return _expiryPolicy;
    }

    public void setExpiryPolicy(TerminusExpiryPolicy expiryPolicy)
    {
        _expiryPolicy = expiryPolicy is null ? TerminusExpiryPolicy.SESSION_END : expiryPolicy;
    }

    public UnsignedInteger getTimeout()
    {
        return _timeout;
    }

    public void setTimeout(UnsignedInteger timeout)
    {
        _timeout = timeout;
    }

    public Boolean getDynamic()
    {
        return _dynamic;
    }

    public void setDynamic(Boolean dynamic)
    {
        _dynamic = dynamic;
    }

    public IObject getDynamicNodeProperties()
    {
        return _dynamicNodeProperties;
    }

    public void setDynamicNodeProperties(IObject dynamicNodeProperties)
    {
        _dynamicNodeProperties = dynamicNodeProperties;
    }


    public List!Symbol getCapabilities()
    {
        return _capabilities;
    }

    public void setCapabilities(List!Symbol capabilities)
    {
        _capabilities = capabilities;
    }

}
