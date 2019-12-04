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
        const int CONNECTION_INIT = Type.CONNECTION_INIT.ordinal;
        const int CONNECTION_LOCAL_OPEN =Type.CONNECTION_LOCAL_OPEN.ordinal;
        const int CONNECTION_REMOTE_OPEN = Type.CONNECTION_REMOTE_OPEN.ordinal;
        const int CONNECTION_LOCAL_CLOSE = Type.CONNECTION_LOCAL_CLOSE.ordinal;
        const int CONNECTION_REMOTE_CLOSE =  Type.CONNECTION_REMOTE_CLOSE.ordinal;
        const int CONNECTION_BOUND = Type.CONNECTION_BOUND.ordinal;
        const int CONNECTION_UNBOUND = Type.CONNECTION_UNBOUND.ordinal;
        const int CONNECTION_FINAL = Type.CONNECTION_FINAL.ordinal;


        const int SESSION_INIT = Type.SESSION_INIT.ordinal;
        const int SESSION_LOCAL_OPEN = Type.SESSION_LOCAL_OPEN.ordinal;
        const int SESSION_REMOTE_OPEN = Type.SESSION_REMOTE_OPEN.ordinal;
        const int SESSION_LOCAL_CLOSE = Type.SESSION_LOCAL_CLOSE.ordinal;
        const int SESSION_REMOTE_CLOSE = Type.SESSION_REMOTE_CLOSE.ordinal;
        const int SESSION_FINAL =  Type.SESSION_FINAL.ordinal;


        const int LINK_INIT =  Type.LINK_INIT.ordinal;
        const int LINK_LOCAL_OPEN = Type.LINK_LOCAL_OPEN.ordinal;
        const int LINK_REMOTE_OPEN = Type.LINK_REMOTE_OPEN.ordinal;
        const int LINK_LOCAL_DETACH = Type.LINK_LOCAL_DETACH.ordinal;
        const int LINK_REMOTE_DETACH = Type.LINK_REMOTE_DETACH.ordinal;
        const int LINK_LOCAL_CLOSE = Type.LINK_LOCAL_CLOSE.ordinal;
        const int LINK_REMOTE_CLOSE = Type.LINK_REMOTE_CLOSE.ordinal;
        const int LINK_FLOW = Type.LINK_FLOW.ordinal;
        const int LINK_FINAL =  Type.LINK_FINAL.ordinal;
        const int DELIVERY = Type.DELIVERY.ordinal;
        const int TRANSPORT =  Type.TRANSPORT.ordinal;
        const int TRANSPORT_ERROR = Type.TRANSPORT_ERROR.ordinal;
        const int TRANSPORT_HEAD_CLOSED = Type.TRANSPORT_HEAD_CLOSED.ordinal;
        const int TRANSPORT_TAIL_CLOSED = Type.TRANSPORT_TAIL_CLOSED.ordinal;
        const int TRANSPORT_CLOSED = Type.TRANSPORT_CLOSED.ordinal;
        const int REACTOR_FINAL = Type.REACTOR_FINAL.ordinal;
        const int REACTOR_QUIESCED = Type.REACTOR_QUIESCED.ordinal;
        const int REACTOR_INIT = Type.REACTOR_INIT.ordinal;
        const int SELECTABLE_ERROR = Type.SELECTABLE_ERROR.ordinal;
        const int SELECTABLE_EXPIRED = Type.SELECTABLE_EXPIRED.ordinal;
        const int SELECTABLE_FINAL = Type.SELECTABLE_FINAL.ordinal;
        const int SELECTABLE_INIT = Type.SELECTABLE_INIT.ordinal;
        const int SELECTABLE_READABLE = Type.SELECTABLE_READABLE.ordinal;
        const int SELECTABLE_UPDATED = Type.SELECTABLE_UPDATED.ordinal;
        const int SELECTABLE_WRITABLE = Type.SELECTABLE_WRITABLE.ordinal;
        const int TIMER_TASK = Type.TIMER_TASK.ordinal;
        const int NON_CORE_EVENT = Type.NON_CORE_EVENT.ordinal;

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
