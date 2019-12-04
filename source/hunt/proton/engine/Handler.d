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

module hunt.proton.engine.Handler;

import hunt.collection.LinkedHashSet;
import hunt.proton.engine.Event;
/**
 * Handler
 *
 */

interface Handler
{
    /**
     * Handle the event in this instance. This is the second half of
     * {@link Event#dispatch(Handler)}. The method must invoke a concrete onXxx
     * method for the given event, or invoke it's {@link #onUnhandled(Event)}
     * method if the {@link EventType} of the event is not recognized by the
     * handler.
     * <p>
     * <b>Note:</b> The handler is not supposed to invoke the
     * {@link #handle(Event)} method on it's {@link #children()}, that is the
     * responsibility of the {@link Event#dispatch(Handler)}
     *
     * @see BaseHandler
     * @param e
     *            The event to handle
     */
    void handle(Event e);

    void onUnhandled(Event e);

    void add(Handler child);

    LinkedHashSet!Handler children();

    int opCmp( Handler o);
}
