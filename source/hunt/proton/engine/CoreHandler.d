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

module hunt.proton.engine.CoreHandler;
import hunt.proton.engine.Handler;
import hunt.proton.engine.Event;

interface CoreHandler : Handler {
    void onConnectionInit(Event e);
    void onConnectionLocalOpen(Event e);
    void onConnectionRemoteOpen(Event e);
    void onConnectionLocalClose(Event e);
    void onConnectionRemoteClose(Event e);
    void onConnectionBound(Event e);
    void onConnectionUnbound(Event e);
    void onConnectionFinal(Event e);

    void onSessionInit(Event e);
    void onSessionLocalOpen(Event e);
    void onSessionRemoteOpen(Event e);
    void onSessionLocalClose(Event e);
    void onSessionRemoteClose(Event e);
    void onSessionFinal(Event e);

    void onLinkInit(Event e);
    void onLinkLocalOpen(Event e);
    void onLinkRemoteOpen(Event e);
    void onLinkLocalDetach(Event e);
    void onLinkRemoteDetach(Event e);
    void onLinkLocalClose(Event e);
    void onLinkRemoteClose(Event e);
    void onLinkFlow(Event e);
    void onLinkFinal(Event e);

    void onDelivery(Event e);
    void onTransport(Event e);
    void onTransportError(Event e);
    void onTransportHeadClosed(Event e);
    void onTransportTailClosed(Event e);
    void onTransportClosed(Event e);

    void onReactorInit(Event e);
    void onReactorQuiesced(Event e);
    void onReactorFinal(Event e);

    void onTimerTask(Event e);

    void onSelectableInit(Event e);
    void onSelectableUpdated(Event e);
    void onSelectableReadable(Event e);
    void onSelectableWritable(Event e);
    void onSelectableExpired(Event e);
    void onSelectableError(Event e);
    void onSelectableFinal(Event e);

}
