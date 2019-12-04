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

module hunt.proton.engine.impl.EventImpl;


import hunt.proton.engine.Connection;
import hunt.proton.engine.Delivery;
import hunt.proton.engine.Event;
import hunt.proton.engine.EventType;
import hunt.proton.engine.Handler;
import hunt.proton.engine.HandlerException;
import hunt.proton.engine.Link;
import hunt.proton.engine.Receiver;
import hunt.proton.engine.Record;
import hunt.proton.engine.Sender;
import hunt.proton.engine.Session;
import hunt.proton.engine.Transport;
import hunt.proton.engine.Reactor;
import hunt.proton.engine.Selectable;
import hunt.proton.engine.Task;
//import hunt.proton.reactor.impl.ReactorImpl;
import hunt.proton.engine.impl.RecordImpl;
import hunt.Exceptions;
import hunt.collection.LinkedHashSet;
import hunt.proton.engine.impl.TransportImpl;
/**

 * EventImpl
 *
 */

class EventImpl : Event
{

    EventType type;
    Object context;
    EventImpl next;
    RecordImpl _attachments;// = new RecordImpl();

    this()
    {
        this.type = null;
        _attachments =  new RecordImpl();
    }

    void init(EventType type, Object context)
    {
        this.type = type;
        this.context = context;
        this._attachments.clear();
    }

    void clear()
    {
        type = null;
        context = null;
        _attachments.clear();
    }


    public EventType getEventType()
    {
        return type;
    }


    public Type getType() {
        Type t = cast(Type)type;
        if (t !is null) {
            return t;
        }
        return Type.NON_CORE_EVENT;
    }


    public Object getContext()
    {
        return context;
    }


    public Handler getRootHandler() {
        implementationMissing(false);
        return null;

      //  return ReactorImpl.ROOT.get(this);
    }

    private Handler delegated = null;

     void Idelegate()
     {
         implementationMissing(false);
     }

    public void dispatch(Handler handler)
    {
        Handler old_delegated = delegated;
        try {
            delegated = handler;
            try {
                handler.handle(this);
            } catch(HandlerException handlerException) {
                throw handlerException;
            } catch(RuntimeException runtimeException) {
                throw new HandlerException(handler, runtimeException);
            }
            delegat();
        } finally {
            delegated = old_delegated;
        }
    }


    public void delegat()
    {
        if (delegated is null) {
            return; // short circuit
        }
        LinkedHashSet!Handler children = delegated.children();
        delegated = null;
        foreach (Handler handler ; children)
        {
            dispatch(handler);
        }
        //while(children.hasNext()) {
        //    dispatch(children.next());
        //}
    }


    public void redispatch(EventType as_type, Handler handler)
    {
        if (!as_type.isValid()) {
            throw new IllegalArgumentException("Can only redispatch valid event types");
        }
        EventType old = type;
        try {
            type = as_type;
            dispatch(handler);
        }
        finally {
            type = old;
        }
    }


    public Connection getConnection()
    {
        Connection conn  = cast(Connection)context;
        if (conn !is null) {
            return conn;
        } else if ( cast(Transport)context !is null) {
            Transport transport = getTransport();
            if (transport is null) {
                return null;
            }
            return (cast(TransportImpl) transport).getConnectionImpl();
        } else {
            Session ssn = getSession();
            if (ssn is null) {
                return null;
            }
            return ssn.getConnection();
        }
    }


    public Session getSession()
    {
        Session session = cast(Session)context;
        if (session !is null) {
            return session;
        } else {
            Link link = getLink();
            if (link is null) {
                return null;
            }
            return link.getSession();
        }
    }


    public Link getLink()
    {
        Link link = cast(Link)context;
        if (link !is null) {
            return link;
        } else {
            Delivery dlv = getDelivery();
            if (dlv is null) {
                return null;
            }
            return dlv.getLink();
        }
    }


    public Sender getSender()
    {
        Sender sender = cast(Sender)context;
        if (sender !is null) {
            return sender;
        } else {
            Link link = getLink();
            Sender s = cast(Sender)link;
            if (s !is null) {
                return s;
            }
            return null;
        }
    }


    public Receiver getReceiver()
    {
        Receiver rec = cast(Receiver)context;
        if (rec !is null) {
            return rec;
        } else {
            Link link = getLink();
            Receiver r = cast(Receiver)link;
            if (r !is null) {
                return r;
            }
            return null;
        }
    }


    public Delivery getDelivery()
    {
        Delivery del = cast(Delivery)context;
        if (del !is null) {
            return del;
        } else {
            return null;
        }
    }


    public Transport getTransport()
    {
        Transport trsp = cast(Transport)context;
        if (trsp !is null) {
            return trsp;
        } else if (cast(Connection)context !is null) {
            return (cast(Connection)context).getTransport();
        } else {
            Session session = getSession();
            if (session is null) {
                return null;
            }

            Connection connection = session.getConnection();
            if (connection is null) {
                return null;
            }

            return connection.getTransport();
        }
    }


    public Selectable getSelectable() {
        Selectable select = cast(Selectable)context;
        if (select !is null) {
            return select;
        } else {
            return null;
        }
    }


    public Reactor getReactor() {

        if (cast(Reactor)context !is null) {
            return cast(Reactor) context;
        } else if (cast(Task)context !is null) {
            return (cast(Task)context).getReactor();
        } else if (cast(Transport)context !is null ) {
            return (cast(TransportImpl)context).getReactor();
        } else if (cast(Delivery)context !is null) {
            return (cast(Delivery)context).getLink().getSession().getConnection().getReactor();
        } else if (cast(Link)context !is null) {
            return (cast(Link)context).getSession().getConnection().getReactor();
        } else if (cast(Session)context !is null) {
            return (cast(Session)context).getConnection().getReactor();
        } else if (cast(Connection)context !is null) {
            return (cast(Connection)context).getReactor();
        } else if (cast(Selectable)context !is null) {
            return (cast(Selectable)context).getReactor();
        }
        return null;
    }


    public Task getTask() {
        Task tesk = cast(Task)context;
        if (tesk !is null) {
            return tesk;
        } else {
            return null;
        }
    }


    public Record attachments() {
        return _attachments;
    }


    public Event copy()
    {
       EventImpl newEvent = new EventImpl();
       newEvent.init(type, context);
       newEvent._attachments.copy(_attachments);
       return newEvent;
    }

    //
    //public String toString()
    //{
    //    return "EventImpl{" + "type=" + type + ", context=" + context + '}';
    //}


}
