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

module hunt.proton.engine.Selectable;

import hunt.proton.engine.ReactorChild;
import hunt.proton.engine.Collector;
import hunt.proton.engine.Extendable;
import hunt.proton.engine.Reactor;

/**
 * An entity that can be multiplexed using a {@link Selector}.
 * <p>
 * Every selectable is associated with exactly one {@link SelectableChannel}.
 * Selectables may be interested in three kinds of events: read events, write
 * events, and timer events. A selectable will express its interest in these
 * events through the {@link #isReading()}, {@link #isWriting()}, and
 * {@link #getDeadline()} methods.
 * <p>
 * When a read, write, or timer event occurs, the selectable must be notified by
 * calling {@link #readable()}, {@link #writeable()}, or {@link #expired()} as
 * appropriate.
 *
 * Once a selectable reaches a terminal state (see {@link #isTerminal()}, it
 * will never be interested in events of any kind. When this occurs it should be
 * removed from the Selector and discarded using {@link #free()}.
 */

interface Callback {
    void run(Selectable selectable);
}

interface Selectable : ReactorChild, Extendable {

    /**
     * A callback that can be passed to the various "on" methods of the
     * selectable - to allow code to be run when the selectable becomes ready
     * for the associated operation.
     */


    /**
     * @return <code>true</code> if the selectable is interested in receiving
     *         notification (via the {@link #readable()} method that indicate
     *         that the associated {@link SelectableChannel} has data ready
     *         to be read from it.
     */
    bool isReading();

    /**
     * @return <code>true</code> if the selectable is interested in receiving
     *         notifications (via the {@link #writeable()} method that indicate
     *         that the associated {@link SelectableChannel} is ready to be
     *         written to.
     */
    bool isWriting();

    /**
     * @return a deadline after which this selectable can expect to receive
     *         a notification (via the {@link #expired()} method that indicates
     *         that the deadline has past.  The deadline is expressed in the
     *         same format as {@link System#currentTimeMillis()}.  Returning
     *         a deadline of zero (or a negative number) indicates that the
     *         selectable does not wish to be notified of expiry.
     */
    long getDeadline();

    /**
     * Sets the value that will be returned by {@link #isReading()}.
     * @param reading
     */
    void setReading(bool reading);

    /**
     * Sets the value that will be returned by {@link #isWriting()}.
     * @param writing
     */
    void setWriting(bool writing);

    /**
     * Sets the value that will be returned by {@link #getDeadline()}.
     * @param deadline
     */
    void setDeadline(long deadline);

    /**
     * Registers a callback that will be run when the selectable becomes ready
     * for reading.
     * @param runnable the callback to register.  Any previously registered
     *                 callback will be replaced.
     */
    void onReadable(Callback runnable);

    /**
     * Registers a callback that will be run when the selectable becomes ready
     * for writing.
     * @param runnable the callback to register.  Any previously registered
     *                 callback will be replaced.
     */
    void onWritable(Callback runnable);

    /**
     * Registers a callback that will be run when the selectable expires.
     * @param runnable the callback to register.  Any previously registered
     *                 callback will be replaced.
     */
    void onExpired(Callback runnable);

    /**
     * Registers a callback that will be run when the selectable is notified of
     * an error.
     * @param runnable the callback to register.  Any previously registered
     *                 callback will be replaced.
     */
    void onError(Callback runnable);

    /**
     * Registers a callback that will be run when the selectable is notified
     * that it has been released.
     * @param runnable the callback to register.  Any previously registered
     *                 callback will be replaced.
     */
    void onRelease(Callback runnable);

    /**
     * Registers a callback that will be run when the selectable is notified
     * that it has been free'd.
     * @param runnable the callback to register.  Any previously registered
     *                 callback will be replaced.
     */
    void onFree(Callback runnable);

    /**
     * Notify the selectable that the underlying {@link SelectableChannel} is
     * ready for a read operation.
     */
    void readable();

    /**
     * Notify the selectable that the underlying {@link SelectableChannel} is
     * ready for a write operation.
     */
    void writeable();

    /** Notify the selectable that it has expired. */
    void expired();

    /** Notify the selectable that an error has occurred. */
    void error();

    /** Notify the selectable that it has been released. */
    void release();

    /** Notify the selectable that it has been free'd. */
    void free();

    /**
     * Associates a {@link SelectableChannel} with this selector.
     * @param channel
     */
   // void setChannel(SelectableChannel channel); // This is the equivalent to pn_selectable_set_fd(...)

    /** @return the {@link SelectableChannel} associated with this selector. */
 //   SelectableChannel getChannel(); // This is the equivalent to pn_selectable_get_fd(...)

    /**
     * Check if a selectable is registered.  This can be used for tracking
     * whether a given selectable has been registerd with an external event
     * loop.
     * <p>
     * <em>Note:</em> the reactor code, currently, does not use this flag.
     * @return <code>true</code>if the selectable is registered.
     */
    bool isRegistered();  // XXX: unused in C reactor code

    /**
     * Set the registered flag for a selectable.
     * <p>
     * <em>Note:</em> the reactor code, currently, does not use this flag.
     * @param registered the value returned by {@link #isRegistered()}
     */
    void setRegistered(bool registered); // XXX: unused in C reactor code

    /**
     * Configure a selectable with a set of callbacks that emit readable,
     * writable, and expired events into the supplied collector.
     * @param collector
     */
    void setCollector( Collector collector);

    /** @return the reactor to which this selectable is a child. */
    Reactor getReactor() ;

    /**
     * Terminates the selectable.  Once a selectable reaches a terminal state
     * it will never be interested in events of any kind.
     */
    public void terminate() ;

    /**
     * @return <code>true</code> if the selectable has reached a terminal state.
     */
    bool isTerminal();

}
