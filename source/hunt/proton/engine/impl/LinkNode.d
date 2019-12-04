module hunt.proton.engine.impl.LinkNode;
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


interface Query(T)
{
    public bool matches(LinkNode!T node);
}

class LinkNode(E)
{
    private E _value;
    private LinkNode!E _prev;
    private LinkNode!E _next;

    this(E value)
    {
        _value = value;
    }

    public E getValue()
    {
        return _value;
    }

    public LinkNode!E getPrev()
    {
        return _prev;
    }

    public LinkNode!E getNext()
    {
        return _next;
    }

    public LinkNode!E next(Query!E query)
    {
        LinkNode!E next = _next;
        while(next !is null && !query.matches(next))
        {
            next = next.getNext();
        }
        return next;
    }

    public LinkNode!E remove()
    {
        LinkNode!E prev = _prev;
        LinkNode!E next = _next;
        if(prev !is null)
        {
            prev._next = next;
        }
        if(next !is null)
        {
            next._prev = prev;
        }
        _next = _prev = null;
        return next;
    }

    public LinkNode!E addAtTail(E value)
    {
        if(_next is null)
        {
            _next = new LinkNode!E(value);
            _next._prev = this;
            return _next;
        }
        else
        {
            return _next.addAtTail(value);
        }
    }

    public static LinkNode!T newList(T)(T value)
    {
        return new LinkNode!T (value);
    }

}
