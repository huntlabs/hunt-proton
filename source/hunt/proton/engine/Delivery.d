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

module hunt.proton.engine.Delivery;

import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.engine.Link;
import hunt.proton.engine.Extendable;
/**
 * A delivery of a message on a particular link.
 *
 * Whilst a message is logically a long-lived object, a delivery is short-lived - it
 * is only intended to be used by the application until it is settled and all its data has been read.
 */
interface Delivery : Extendable
{

    public byte[] getTag();

    public Link getLink();

    public DeliveryState getLocalState();

    public DeliveryState getRemoteState();

    /**
     * updates the state of the delivery
     *
     * The new state may have no on-the-wire effect, if delivery settlement was already communicated to/from the peer.
     *
     * @param state the new delivery state
     */
    public void disposition(DeliveryState state);

    /**
     * Settles this delivery.
     *
     * Causes the delivery to be removed from the connection's work list (see {@link Connection#getWorkHead()}).
     * If this delivery is its link's current delivery, the link's current delivery pointer is advanced.
     */
    public void settle();

    /**
     * Returns whether this delivery has been settled.
     *
     * TODO proton-j and proton-c return the local and remote statuses respectively. Resolve this ambiguity.
     *
     * @see #settle()
     */
    public bool isSettled();

    public bool remotelySettled();

    /**
     * TODO When does an application call this method?  Do we really need this?
     */
    public void free();

    /**
     * @see Connection#getWorkHead()
     */
    public Delivery getWorkNext();

    public Delivery next();

    public bool isWritable();

    /**
     * Returns whether this delivery has data ready to be received.
     *
     * @see Receiver#recv(byte[], int, int)
     */
    public bool isReadable();

    public void setContext(Object o);

    public Object getContext();

    /**
     * Returns whether this delivery's state or settled flag has ever remotely changed.
     *
     * TODO what is the main intended use case for calling this method?
     */
    public bool isUpdated();

    public void clear();

    /**
     * Check for whether the delivery is still partial.
     *
     * For a receiving Delivery, this means the delivery does not hold
     * a complete message payload as all the content hasn't been
     * received yet. Note that an {@link #isAborted() aborted} delivery
     * will also be considered partial and the full payload won't
     * be received.
     *
     * For a sending Delivery, this means the sender link has not been
     * {@link Sender#advance() advanced} to complete the delivery yet.
     *
     * @return true if the delivery is partial
     * @see #isAborted()
     */
    public bool isPartial();

    /**
     * Check for whether the delivery was aborted.
     *
     * @return true if the delivery was aborted.
     */
    bool isAborted();

    public int pending();

    public bool isBuffered();

    /**
     * Configures a default DeliveryState to be used if a
     * received delivery is settled/freed without any disposition
     * state having been previously applied.
     *
     * @param state the default delivery state
     */
    public void setDefaultDeliveryState(DeliveryState state);

    public DeliveryState getDefaultDeliveryState();

    /**
     * Sets the message-format for this Delivery, representing the 32bit value using an int.
     *
     * The default value is 0 as per the message format defined in the core AMQP 1.0 specification.<p>
     *
     * See the following for more details:<br>
     * <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-transport-v1.0-os.html#type-transfer">
     *          http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-transport-v1.0-os.html#type-transfer</a><br>
     * <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-transport-v1.0-os.html#type-message-format">
     *          http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-transport-v1.0-os.html#type-message-format</a><br>
     * <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-messaging-v1.0-os.html#section-message-format">
     *          http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-messaging-v1.0-os.html#section-message-format</a><br>
     * <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-messaging-v1.0-os.html#definition-MESSAGE-FORMAT">
     *          http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-messaging-v1.0-os.html#definition-MESSAGE-FORMAT</a><br>
     *
     * @param messageFormat the message format
     */
    public void setMessageFormat(int messageFormat);

    /**
     * Gets the message-format for this Delivery, representing the 32bit value using an int.
     *
     * @return the message-format
     * @see #setMessageFormat(int)
     */
    public int getMessageFormat();

    /**
     * Returns the number of bytes currently available for this delivery, which may not be complete yet, that are still
     * to either be received by the application or sent by the transport.
     *
     * Note that this value will change as bytes are received/sent, and is in general not equal to the total length of
     * a delivery, except the point where {@link #isPartial()} returns false and no content has yet been received by the
     * application or sent by the transport.
     *
     * @return the number of bytes currently available for the delivery
     *
     * @see Receiver#recv(byte[], int, int)
     * @see Receiver#recv(hunt.proton.codec.WritableBuffer)
     * @see Sender#send(byte[], int, int)
     * @see Sender#send(hunt.proton.codec.ReadableBuffer)
     */
    int available();
}
