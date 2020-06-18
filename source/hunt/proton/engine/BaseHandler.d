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

module hunt.proton.engine.BaseHandler;

import hunt.collection.LinkedHashSet;
import hunt.proton.engine.CoreHandler;
import hunt.proton.engine.Handler;
import hunt.proton.engine.Record;
import hunt.proton.engine.Extendable;
import hunt.proton.engine.Event;
/**
 * BaseHandler
 *
 */

class BaseHandler : CoreHandler
{

    public static Handler getHandler(Record r ,string key) {
        return  cast(Handler)(r.get(key));
    }

    public static void setHandler(Record r, Handler handler,string key) {
        r.set(key,  cast(Object)handler);
    }

    public static Handler getHandler(Extendable ext , string key) {
        return  cast(Handler)(ext.attachments().get(key));
    }

    public static void setHandler(Extendable ext, Handler handler,string key) {
        ext.attachments().set(key, cast(Object) handler);
    }

    this()
    {
        _children = new LinkedHashSet!Handler();
    }

    private LinkedHashSet!Handler _children ;//= new LinkedHashSet!Handler();

     public void onConnectionInit(Event e) { onUnhandled(e); }
     public void onConnectionLocalOpen(Event e) { onUnhandled(e); }
     public void onConnectionRemoteOpen(Event e) { onUnhandled(e); }
     public void onConnectionLocalClose(Event e) { onUnhandled(e); }
     public void onConnectionRemoteClose(Event e) { onUnhandled(e); }
     public void onConnectionBound(Event e) { onUnhandled(e); }
     public void onConnectionUnbound(Event e) { onUnhandled(e); }
     public void onConnectionFinal(Event e) { onUnhandled(e); }

     public void onSessionInit(Event e) { onUnhandled(e); }
     public void onSessionLocalOpen(Event e) { onUnhandled(e); }
     public void onSessionRemoteOpen(Event e) { onUnhandled(e); }
     public void onSessionLocalClose(Event e) { onUnhandled(e); }
     public void onSessionRemoteClose(Event e) { onUnhandled(e); }
     public void onSessionFinal(Event e) { onUnhandled(e); }

     public void onLinkInit(Event e) { onUnhandled(e); }
     public void onLinkLocalOpen(Event e) { onUnhandled(e); }
     public void onLinkRemoteOpen(Event e) { onUnhandled(e); }
     public void onLinkLocalDetach(Event e) { onUnhandled(e); }
     public void onLinkRemoteDetach(Event e) { onUnhandled(e); }
     public void onLinkLocalClose(Event e) { onUnhandled(e); }
     public void onLinkRemoteClose(Event e) { onUnhandled(e); }
     public void onLinkFlow(Event e) { onUnhandled(e); }
     public void onLinkFinal(Event e) { onUnhandled(e); }

     public void onDelivery(Event e) { onUnhandled(e); }
     public void onTransport(Event e) { onUnhandled(e); }
     public void onTransportError(Event e) { onUnhandled(e); }
     public void onTransportHeadClosed(Event e) { onUnhandled(e); }
     public void onTransportTailClosed(Event e) { onUnhandled(e); }
     public void onTransportClosed(Event e) { onUnhandled(e); }

     public void onReactorInit(Event e) { onUnhandled(e); }
     public void onReactorQuiesced(Event e) { onUnhandled(e); }
     public void onReactorFinal(Event e) { onUnhandled(e); }

     public void onTimerTask(Event e) { onUnhandled(e); }

     public void onSelectableInit(Event e) { onUnhandled(e); }
     public void onSelectableUpdated(Event e) { onUnhandled(e); }
     public void onSelectableReadable(Event e) { onUnhandled(e); }
     public void onSelectableWritable(Event e) { onUnhandled(e); }
     public void onSelectableExpired(Event e) { onUnhandled(e); }
     public void onSelectableError(Event e) { onUnhandled(e); }
     public void onSelectableFinal(Event e) { onUnhandled(e); }

     public void onUnhandled(Event event) {}

    
    public void add(Handler child) {
        _children.add(child);
    }

    
    public LinkedHashSet!Handler children() {
        return _children;
    }

	
	public void handle(Event e) {
        int type = e.getType().ordinal;

        enum CONNECTION_INIT =   AmqpEventType.CONNECTION_INIT.ordinal;
        enum CONNECTION_LOCAL_OPEN =AmqpEventType.CONNECTION_LOCAL_OPEN.ordinal;
        enum CONNECTION_REMOTE_OPEN = AmqpEventType.CONNECTION_REMOTE_OPEN.ordinal;
        enum CONNECTION_LOCAL_CLOSE = AmqpEventType.CONNECTION_LOCAL_CLOSE.ordinal;
        enum CONNECTION_REMOTE_CLOSE =  AmqpEventType.CONNECTION_REMOTE_CLOSE.ordinal;
        enum CONNECTION_BOUND = AmqpEventType.CONNECTION_BOUND.ordinal;
        enum CONNECTION_UNBOUND = AmqpEventType.CONNECTION_UNBOUND.ordinal;
        enum CONNECTION_FINAL = AmqpEventType.CONNECTION_FINAL.ordinal;


        enum SESSION_INIT = AmqpEventType.SESSION_INIT.ordinal;
        enum SESSION_LOCAL_OPEN = AmqpEventType.SESSION_LOCAL_OPEN.ordinal;
        enum SESSION_REMOTE_OPEN = AmqpEventType.SESSION_REMOTE_OPEN.ordinal;
        enum SESSION_LOCAL_CLOSE = AmqpEventType.SESSION_LOCAL_CLOSE.ordinal;
        enum SESSION_REMOTE_CLOSE = AmqpEventType.SESSION_REMOTE_CLOSE.ordinal;
        enum SESSION_FINAL =  AmqpEventType.SESSION_FINAL.ordinal;


        enum LINK_INIT =  AmqpEventType.LINK_INIT.ordinal;
        enum LINK_LOCAL_OPEN = AmqpEventType.LINK_LOCAL_OPEN.ordinal;
        enum LINK_REMOTE_OPEN = AmqpEventType.LINK_REMOTE_OPEN.ordinal;
        enum LINK_LOCAL_DETACH = AmqpEventType.LINK_LOCAL_DETACH.ordinal;
        enum LINK_REMOTE_DETACH = AmqpEventType.LINK_REMOTE_DETACH.ordinal;
        enum LINK_LOCAL_CLOSE = AmqpEventType.LINK_LOCAL_CLOSE.ordinal;
        enum LINK_REMOTE_CLOSE = AmqpEventType.LINK_REMOTE_CLOSE.ordinal;
        enum LINK_FLOW = AmqpEventType.LINK_FLOW.ordinal;
        enum LINK_FINAL =  AmqpEventType.LINK_FINAL.ordinal;
        enum DELIVERY = AmqpEventType.DELIVERY.ordinal;
        enum TRANSPORT =  AmqpEventType.TRANSPORT.ordinal;
        enum TRANSPORT_ERROR = AmqpEventType.TRANSPORT_ERROR.ordinal;
        enum TRANSPORT_HEAD_CLOSED = AmqpEventType.TRANSPORT_HEAD_CLOSED.ordinal;
        enum TRANSPORT_TAIL_CLOSED = AmqpEventType.TRANSPORT_TAIL_CLOSED.ordinal;
        enum TRANSPORT_CLOSED = AmqpEventType.TRANSPORT_CLOSED.ordinal;
        enum REACTOR_FINAL = AmqpEventType.REACTOR_FINAL.ordinal;
        enum REACTOR_QUIESCED = AmqpEventType.REACTOR_QUIESCED.ordinal;
        enum REACTOR_INIT = AmqpEventType.REACTOR_INIT.ordinal;
        enum SELECTABLE_ERROR = AmqpEventType.SELECTABLE_ERROR.ordinal;
        enum SELECTABLE_EXPIRED = AmqpEventType.SELECTABLE_EXPIRED.ordinal;
        enum SELECTABLE_FINAL = AmqpEventType.SELECTABLE_FINAL.ordinal;
        enum SELECTABLE_INIT = AmqpEventType.SELECTABLE_INIT.ordinal;
        enum SELECTABLE_READABLE = AmqpEventType.SELECTABLE_READABLE.ordinal;
        enum SELECTABLE_UPDATED = AmqpEventType.SELECTABLE_UPDATED.ordinal;
        enum SELECTABLE_WRITABLE = AmqpEventType.SELECTABLE_WRITABLE.ordinal;
        enum TIMER_TASK = AmqpEventType.TIMER_TASK.ordinal;
        enum NON_CORE_EVENT = AmqpEventType.NON_CORE_EVENT.ordinal;
        
        switch (type) {
        case CONNECTION_INIT:
            onConnectionInit(e);
            break;
        case CONNECTION_LOCAL_OPEN:
            onConnectionLocalOpen(e);
            break;
        case CONNECTION_REMOTE_OPEN:
            onConnectionRemoteOpen(e);
            break;
        case CONNECTION_LOCAL_CLOSE:
            onConnectionLocalClose(e);
            break;
        case CONNECTION_REMOTE_CLOSE:
            onConnectionRemoteClose(e);
            break;
        case CONNECTION_BOUND:
            onConnectionBound(e);
            break;
        case CONNECTION_UNBOUND:
            onConnectionUnbound(e);
            break;
        case CONNECTION_FINAL:
            onConnectionFinal(e);
            break;
        case SESSION_INIT:
            onSessionInit(e);
            break;
        case SESSION_LOCAL_OPEN:
            onSessionLocalOpen(e);
            break;
        case SESSION_REMOTE_OPEN:
            onSessionRemoteOpen(e);
            break;
        case SESSION_LOCAL_CLOSE:
            onSessionLocalClose(e);
            break;
        case SESSION_REMOTE_CLOSE:
            onSessionRemoteClose(e);
            break;
        case SESSION_FINAL:
            onSessionFinal(e);
            break;
        case LINK_INIT:
            onLinkInit(e);
            break;
        case LINK_LOCAL_OPEN:
            onLinkLocalOpen(e);
            break;
        case LINK_REMOTE_OPEN:
            onLinkRemoteOpen(e);
            break;
        case LINK_LOCAL_DETACH:
            onLinkLocalDetach(e);
            break;
        case LINK_REMOTE_DETACH:
            onLinkRemoteDetach(e);
            break;
        case LINK_LOCAL_CLOSE:
            onLinkLocalClose(e);
            break;
        case LINK_REMOTE_CLOSE:
            onLinkRemoteClose(e);
            break;
        case LINK_FLOW:
            onLinkFlow(e);
            break;
        case LINK_FINAL:
            onLinkFinal(e);
            break;
        case DELIVERY:
            onDelivery(e);
            break;
        case TRANSPORT:
            onTransport(e);
            break;
        case TRANSPORT_ERROR:
            onTransportError(e);
            break;
        case TRANSPORT_HEAD_CLOSED:
            onTransportHeadClosed(e);
            break;
        case TRANSPORT_TAIL_CLOSED:
            onTransportTailClosed(e);
            break;
        case TRANSPORT_CLOSED:
            onTransportClosed(e);
            break;
        case REACTOR_FINAL:
            onReactorFinal(e);
            break;
        case REACTOR_QUIESCED:
            onReactorQuiesced(e);
            break;
        case REACTOR_INIT:
            onReactorInit(e);
            break;
        case SELECTABLE_ERROR:
            onSelectableError(e);
            break;
        case SELECTABLE_EXPIRED:
            onSelectableExpired(e);
            break;
        case SELECTABLE_FINAL:
            onSelectableFinal(e);
            break;
        case SELECTABLE_INIT:
            onSelectableInit(e);
            break;
        case SELECTABLE_READABLE:
            onSelectableReadable(e);
            break;
        case SELECTABLE_UPDATED:
            onSelectableWritable(e);
            break;
        case SELECTABLE_WRITABLE:
            onSelectableWritable(e);
            break;
        case TIMER_TASK:
            onTimerTask(e);
            break;
        case NON_CORE_EVENT:
            onUnhandled(e);
            break;
        default:
        break;
        }

	}

    override
     int opCmp(Object o)
     {
         return _children.size - ((cast(BaseHandler)o)._children).size;
     }



    int opCmp(Handler o)
    {
      return  _children.size - ((cast(BaseHandler)o)._children).size;
    }
}
