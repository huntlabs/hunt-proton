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

module hunt.proton.engine.impl.CollectorImpl;

import hunt.proton.engine.Collector;
import hunt.proton.engine.Event;
import hunt.proton.engine.EventType;
import hunt.proton.engine.impl.EventImpl;
import hunt.Exceptions;

/**
 * CollectorImpl
 *
 */

class CollectorImpl : Collector
{

    private EventImpl head;
    private EventImpl tail;
    private EventImpl free;

    this()
    {}

    
    public Event peek()
    {
        return head;
    }

    
    public void pop()
    {
        if (head !is null) {
            EventImpl next = head.next;
            head.next = free;
            free = head;
            head.clear();
            head = next;
        }
    }

    public EventImpl put(EventType type, Object context)
    {
        if (type is null) {
            throw new IllegalArgumentException("Type cannot be null");
        }
        if (!type.isValid()) {
            throw new IllegalArgumentException("Cannot put events of type ");
        }
        if (tail !is null && tail.getEventType() == type &&
            tail.getContext() == context) {
            return null;
        }

        EventImpl event;
        if (free is null) {
            event = new EventImpl();
        } else {
            event = free;
            free = free.next;
            event.next = null;
        }

        event.init(type, context);

        if (head is null) {
            head = event;
            tail = event;
        } else {
            tail.next = event;
            tail = event;
        }

        return event;
    }

    
    public bool more() {
        return head !is null && head.next !is null;
    }

}
