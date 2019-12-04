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

module hunt.proton.engine.Event;

import hunt.proton.engine.Reactor;
import hunt.proton.engine.Selectable;
import hunt.proton.engine.Task;
import hunt.proton.engine.Extendable;
import hunt.proton.engine.EventType;
import hunt.Enum;
import hunt.proton.engine.Handler;
import hunt.proton.engine.Connection;
import hunt.proton.engine.Link;
import hunt.proton.engine.Session;
import hunt.proton.engine.Sender;
import hunt.proton.engine.Receiver;
import hunt.proton.engine.Delivery;
import hunt.proton.engine.Transport;
import std.concurrency : initOnce;

/**
 * Event
 *
 */

//enum Type{
//    REACTOR_INIT,
//    REACTOR_QUIESCED,
//    REACTOR_FINAL,
//
//    TIMER_TASK,
//
//    CONNECTION_INIT,
//    CONNECTION_BOUND,
//    CONNECTION_UNBOUND,
//    CONNECTION_LOCAL_OPEN,
//    CONNECTION_REMOTE_OPEN,
//    CONNECTION_LOCAL_CLOSE,
//    CONNECTION_REMOTE_CLOSE,
//    CONNECTION_FINAL,
//
//    SESSION_INIT,
//    SESSION_LOCAL_OPEN,
//    SESSION_REMOTE_OPEN,
//    SESSION_LOCAL_CLOSE,
//    SESSION_REMOTE_CLOSE,
//    SESSION_FINAL,
//
//    LINK_INIT,
//    LINK_LOCAL_OPEN,
//    LINK_REMOTE_OPEN,
//    LINK_LOCAL_DETACH,
//    LINK_REMOTE_DETACH,
//    LINK_LOCAL_CLOSE,
//    LINK_REMOTE_CLOSE,
//    LINK_FLOW,
//    LINK_FINAL,
//
//    DELIVERY,
//
//    TRANSPORT,
//    TRANSPORT_ERROR,
//    TRANSPORT_HEAD_CLOSED,
//    TRANSPORT_TAIL_CLOSED,
//    TRANSPORT_CLOSED,
//
//    SELECTABLE_INIT,
//    SELECTABLE_UPDATED,
//    SELECTABLE_READABLE,
//    SELECTABLE_WRITABLE,
//    SELECTABLE_EXPIRED,
//    SELECTABLE_ERROR,
//    SELECTABLE_FINAL,
//
//    /**
//         * This value must never be used to generate an event, it's only used as
//         * a guard when casting custom EventTypes to core {@link Type} via
//         * {@link Event#getType()}.
//         */
//    NON_CORE_EVENT
//}


class Type : AbstractEnum!int , EventType {


    static Type  REACTOR_INIT() {
        __gshared Type  inst;
        return initOnce!inst(new Type("REACTOR_INIT",0));
    }

    static Type  REACTOR_QUIESCED() {
        __gshared Type  inst;
        return initOnce!inst(new Type("REACTOR_QUIESCED",1));
    }

    static Type  REACTOR_FINAL() {
        __gshared Type  inst;
        return initOnce!inst(new Type("REACTOR_FINAL",2));
    }

    static Type  TIMER_TASK() {
        __gshared Type  inst;
        return initOnce!inst(new Type("TIMER_TASK",3));
    }

    static Type  CONNECTION_INIT() {
        __gshared Type  inst;
        return initOnce!inst(new Type("CONNECTION_INIT",4));
    }

    static Type  CONNECTION_BOUND() {
        __gshared Type  inst;
        return initOnce!inst(new Type("CONNECTION_BOUND",5));
    }

    static Type  CONNECTION_UNBOUND() {
        __gshared Type  inst;
        return initOnce!inst(new Type("CONNECTION_UNBOUND",6));
    }

    static Type  CONNECTION_LOCAL_OPEN() {
        __gshared Type  inst;
        return initOnce!inst(new Type("CONNECTION_LOCAL_OPEN",7));
    }

    static Type  CONNECTION_REMOTE_OPEN() {
        __gshared Type  inst;
        return initOnce!inst(new Type("CONNECTION_REMOTE_OPEN",8));
    }

    static Type  CONNECTION_LOCAL_CLOSE() {
        __gshared Type  inst;
        return initOnce!inst(new Type("CONNECTION_LOCAL_CLOSE",9));
    }

    static Type  CONNECTION_REMOTE_CLOSE() {
        __gshared Type  inst;
        return initOnce!inst(new Type("CONNECTION_REMOTE_CLOSE",10));
    }

    static Type  CONNECTION_FINAL() {
        __gshared Type  inst;
        return initOnce!inst(new Type("CONNECTION_FINAL",11));
    }

    static Type  SESSION_INIT() {
        __gshared Type  inst;
        return initOnce!inst(new Type("SESSION_INIT",12));
    }

    static Type  SESSION_LOCAL_OPEN() {
        __gshared Type  inst;
        return initOnce!inst(new Type("SESSION_LOCAL_OPEN",13));
    }

    static Type  SESSION_REMOTE_OPEN() {
        __gshared Type  inst;
        return initOnce!inst(new Type("SESSION_REMOTE_OPEN",14));
    }

    static Type  SESSION_LOCAL_CLOSE() {
        __gshared Type  inst;
        return initOnce!inst(new Type("SESSION_LOCAL_CLOSE",15));
    }

    static Type  SESSION_REMOTE_CLOSE() {
        __gshared Type  inst;
        return initOnce!inst(new Type("SESSION_REMOTE_CLOSE",16));
    }

    static Type  SESSION_FINAL() {
        __gshared Type  inst;
        return initOnce!inst(new Type("SESSION_FINAL",17));
    }

    static Type  LINK_INIT() {
        __gshared Type  inst;
        return initOnce!inst(new Type("LINK_INIT",18));
    }

    static Type  LINK_LOCAL_OPEN() {
        __gshared Type  inst;
        return initOnce!inst(new Type("LINK_LOCAL_OPEN",19));
    }

    static Type  LINK_REMOTE_OPEN() {
        __gshared Type  inst;
        return initOnce!inst(new Type("LINK_REMOTE_OPEN",20));
    }

    static Type  LINK_LOCAL_DETACH() {
        __gshared Type  inst;
        return initOnce!inst(new Type("LINK_LOCAL_DETACH",21));
    }

    static Type  LINK_REMOTE_DETACH() {
        __gshared Type  inst;
        return initOnce!inst(new Type("LINK_REMOTE_DETACH",22));
    }

    static Type  LINK_LOCAL_CLOSE() {
        __gshared Type  inst;
        return initOnce!inst(new Type("LINK_LOCAL_CLOSE",23));
    }

    static Type  LINK_REMOTE_CLOSE() {
        __gshared Type  inst;
        return initOnce!inst(new Type("LINK_REMOTE_CLOSE",24));
    }

    static Type  LINK_FLOW() {
        __gshared Type  inst;
        return initOnce!inst(new Type("LINK_FLOW",25));
    }

    static Type  LINK_FINAL() {
        __gshared Type  inst;
        return initOnce!inst(new Type("LINK_FINAL",26));
    }

    static Type  DELIVERY() {
        __gshared Type  inst;
        return initOnce!inst(new Type("DELIVERY",27));
    }

    static Type  TRANSPORT() {
        __gshared Type  inst;
        return initOnce!inst(new Type("TRANSPORT",28));
    }

    static Type  TRANSPORT_ERROR() {
        __gshared Type  inst;
        return initOnce!inst(new Type("TRANSPORT_ERROR",29));
    }

    static Type  TRANSPORT_HEAD_CLOSED() {
        __gshared Type  inst;
        return initOnce!inst(new Type("TRANSPORT_HEAD_CLOSED",30));
    }

    static Type  TRANSPORT_TAIL_CLOSED() {
        __gshared Type  inst;
        return initOnce!inst(new Type("TRANSPORT_TAIL_CLOSED",31));
    }

    static Type  TRANSPORT_CLOSED() {
        __gshared Type  inst;
        return initOnce!inst(new Type("TRANSPORT_CLOSED",32));
    }

    static Type  SELECTABLE_INIT() {
        __gshared Type  inst;
        return initOnce!inst(new Type("SELECTABLE_INIT",33));
    }

    static Type  SELECTABLE_UPDATED() {
        __gshared Type  inst;
        return initOnce!inst(new Type("SELECTABLE_UPDATED",34));
    }

    static Type  SELECTABLE_READABLE() {
        __gshared Type  inst;
        return initOnce!inst(new Type("SELECTABLE_READABLE",35));
    }

    static Type  SELECTABLE_WRITABLE() {
        __gshared Type  inst;
        return initOnce!inst(new Type("SELECTABLE_WRITABLE",36));
    }

    static Type  SELECTABLE_EXPIRED() {
        __gshared Type  inst;
        return initOnce!inst(new Type("SELECTABLE_EXPIRED",37));
    }

    static Type  SELECTABLE_ERROR() {
        __gshared Type  inst;
        return initOnce!inst(new Type("SELECTABLE_ERROR",38));
    }

    static Type  SELECTABLE_FINAL() {
        __gshared Type  inst;
        return initOnce!inst(new Type("SELECTABLE_FINAL",39));
    }

    static Type  NON_CORE_EVENT() {
        __gshared Type  inst;
        return initOnce!inst(new Type("NON_CORE_EVENT",40));
    }

    this (string name, int i)
    {
        super(name,i);
    }

    //@Override
    //          public boolean isValid() { return false; }
    public bool isValid() {
       return this == NON_CORE_EVENT? false : true;
    }
}

interface Event : Extendable
{
    /**
     * Event types built into the library.
     */


    /**
     * @return type of the event. The event type can be defined outside of the
     *         proton library.
     */
    EventType getEventType();

    /**
     * A concrete event type of core events.
     *
     * @return type of the event for core events. For events generated by
     *         extensions a {@link Type#NON_CORE_EVENT} will be returned
     */
    Type getType();

    Object getContext();

    /**
     * The {@link Handler} at the root of the handler tree.
     * <p>
     * Set by the {@link Reactor} before dispatching the event.
     * <p>
     * @see #redispatch(EventType, Handler)
     * @return The root handler
     */
    Handler getRootHandler();

    void dispatch(Handler handler) ;

    /**
     * Synchronously redispatch the current event as a new {@link EventType} on the provided handler and it's children.
     * <p>
     * Note: the <code>redispatch()</code> will complete before children of the current handler have had the current event dispatched, see {@link #delegate()}.
     *
     *
     * @param as_type Type of event to dispatch
     * @param handler The handler where to start the dispatch. Use {@link #getRootHandler()} to redispatch the new event to all handlers in the tree.
     * @throws HandlerException A wrapper exception of any unhandled exception thrown by <code>handler</code>
     */
    void redispatch(EventType as_type, Handler handler) ;

    /**
     * dispatch the event to all children of the handler. A handler can call
     * this method explicitly to be able to do more processing after all child
     * handlers have already processed the event. If handler does not invoke
     * this method it is invoked implicitly by {@link #dispatch(Handler)}
     *
     * @throws HandlerException
     */
    void Idelegate();

    Connection getConnection();

    Session getSession();

    Link getLink();

    Sender getSender();

    Receiver getReceiver();

    Delivery getDelivery();

    Transport getTransport();

    Reactor getReactor();

    Selectable getSelectable();

    Task getTask();

    Event copy();

}
