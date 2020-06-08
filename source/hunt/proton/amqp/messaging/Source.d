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
module hunt.proton.amqp.messaging.Source;


import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.messaging.Terminus;
import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.messaging.Outcome;

import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.Object;
import hunt.String;

class Source : Terminus, hunt.proton.amqp.transport.Source.Source
{
    private Symbol _distributionMode;
    private IObject _filter;
    private Outcome _defaultOutcome;
    private List!Symbol _outcomes;

    // override
    // string toString()
    // {
    //     return "source: " ~ "_distributionMode = " ~ (_distributionMode is null ? "null": "") ~
    //             " _filter = " ~ (_filter is null? "null": "") ~
    //             " _defaultOutcome = " ~ ( _defaultOutcome is null ? "null": "") ~
    //             " _outcomes = " ~ (_outcomes is null ? "null" : "") ;
    // }

    this(Source other) {
        super(other);
        _distributionMode = other._distributionMode;
        if (other._filter !is null)
            _filter = other._filter;
        _defaultOutcome = other._defaultOutcome;
        if (other._outcomes !is null)
            _outcomes = other._outcomes;
    }
    
    this() {

    }

    public Symbol getDistributionMode()
    {
        return _distributionMode;
    }

    public void setDistributionMode(Symbol distributionMode)
    {
        _distributionMode = distributionMode;
    }

    public IObject getFilter()
    {
        return _filter;
    }

    public void setFilter(IObject filter)
    {
        _filter = filter;
    }

    public Outcome getDefaultOutcome()
    {
        return _defaultOutcome;
    }

    public void setDefaultOutcome(Outcome defaultOutcome)
    {
        _defaultOutcome = defaultOutcome;
    }

    public List!Symbol getOutcomes()
    {
        return _outcomes;
    }

    public void setOutcomes(List!Symbol outcomes)
    {
        _outcomes = outcomes;
    }

    override string toString()
    {
        String address = getAddress();
        IObject nodeProperties = getDynamicNodeProperties();
        
        return "Source{" ~
               "address='" ~ (address is null ? "null" : address.toString()) ~ '\'' ~
               ", durable=" ~ getDurable().toString() ~
               ", expiryPolicy=" ~ getExpiryPolicy().toString() ~
               ", timeout=" ~ getTimeout().toString() ~
               ", dynamic=" ~ getDynamic().toString() ~
               ", dynamicNodeProperties=" ~ (nodeProperties is null ? "null" : nodeProperties.toString()) ~
               ", distributionMode=" ~ (_distributionMode is null ? "null" : _distributionMode.toString()) ~
               ", filter=" ~ (_filter is null ? "null" : _filter.toString()) ~
               ", defaultOutcome=" ~ (_defaultOutcome is null ? "null" : (cast(Object)_defaultOutcome).toString()) ~
               ", outcomes=" ~ (_outcomes is null ? "null" : _outcomes.toString()) ~
               ", capabilities=" ~ (getCapabilities() is null ? "null" : getCapabilities().toString()) ~
               '}';
    }

    override
    public hunt.proton.amqp.transport.Source.Source copy() {
        return new Source(this);
    }

    override
    String getAddress()
    {
        return super.getAddress();
    }
}
  