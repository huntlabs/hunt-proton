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


module hunt.proton.amqp.transport.ErrorCondition;


import hunt.proton.amqp.Symbol;
import hunt.logging;
import hunt.Object;
import hunt.String;

class ErrorCondition
{
    private Symbol _condition;
    private String _description;
    private IObject _info;

    this()
    {
    }

    this(Symbol condition, String description)
    {
        _condition = condition;
        _description = description;
    }

    public Symbol getCondition()
    {
        return _condition;
    }

    public void setCondition(Symbol condition)
    {
        if( condition is null )
        {
            logError("the condition field is mandatory");
        }

        _condition = condition;
    }

    public String getDescription()
    {
        return _description;
    }

    public void setDescription(String description)
    {
        _description = description;
    }

    public IObject getInfo()
    {
        return _info;
    }

    public void setInfo(IObject info)
    {
        _info = info;
    }

    public void clear()
    {
        _condition = null;
        _description = null;
        _info = null;
    }

    public void copyFrom(ErrorCondition condition)
    {
        _condition = condition._condition;
        _description = condition._description;
        _info = condition._info;
    }

    public int hashCode()
    {
        int result = _condition !is null ? _condition.hashCode() : 0;
        result = 31 * result + (_description !is null ? cast(int)(((cast(string)(_description.getBytes())).hashOf)) : 0);
        result = 31 * result + (_info !is null ? cast(int) _info.toHash() : 0);
        return result;
    }

    override bool opEquals(Object o)
    {
        if (this is o)
        {
            return true;
        }
        if (o is null || cast(ErrorCondition)o is null)
        {
            return false;
        }

        ErrorCondition that = cast(ErrorCondition)o;

        if (_condition !is null ? _condition != (that.getCondition()) : that.getCondition() !is null)
        {
            return false;
        }
        if (_description !is null ? _description != (that.getDescription()) : that.getDescription() !is null)
        {
            return false;
        }
        if (_info !is null ? _info != (that.getInfo()) : that.getInfo() !is null)
        {
            return false;
        }

        return true;
    }

}
