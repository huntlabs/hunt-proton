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

module hunt.proton.engine.Sender;

import hunt.proton.codec.ReadableBuffer;
import hunt.proton.engine.Link;

/**
 * Sender
 *
 */
interface Sender : Link
{

    /**
     * indicates pending deliveries
     *
     * @param credits the number of pending deliveries
     */
    //TODO is this absolute or cumulative?
    public void offer(int credits);

    /**
     * Sends some data for the current delivery.  The application may call this method multiple
     * times for the same delivery.
     *
     * @param bytes the byte array containing the data to be sent.
     * @param offset the offset into the given array to start reading.
     * @param length the number of bytes to read from the given byte array.
     *
     * @return the number of bytes accepted
     *
     * TODO Proton-j current copies all the bytes it has been given so the return value will always be
     * length.  Should this be changed? How does Proton-c behave?   What should the application do if
     * the number of bytes accepted is smaller than length.
     */
    public int send(byte[] bytes, int offset, int length);

    /**
     * Sends some data for the current delivery. The application may call this method multiple
     * times for the same delivery.
     *
     * @param buffer the buffer to read the data from.
     *
     * @return the number of bytes read from the provided buffer.
     */
    public int send(ReadableBuffer buffer);

    /**
     * Sends data to the current delivery attempting not to copy the data unless a previous
     * send has already added data to the Delivery in which case a copy may occur depending on
     * the implementation.
     * <p>
     * Care should be taken when passing ReadableBuffer instances that wrapped pooled bytes
     * as the send does not mean the data will be sent immediately when the transport is
     * flushed so the pooled bytes could be held for longer than expected.
     *
     * @param buffer
     *      An immutable ReadableBuffer that can be held until the next transport flush.
     *
     * @return the number of bytes read from the provided buffer.
     */
    public int sendNoCopy(ReadableBuffer buffer);

    /**
     * Abort the current delivery.
     *
     * Note "pn_link_abort" is commented out in the .h
     */
    public void abort();

    /**
     * {@inheritDoc}
     *
     * Informs the sender that all the bytes of the current {@link Delivery} have been written.
     * The application must call this method in order for the delivery to be considered complete.
     *
     * @see #send(byte[], int, int)
     *
     * TODO fully state the rules regarding when you have to call this method, what happens if you don't call it
     * before creating another delivery etc.
     */
    public bool advance();

}
