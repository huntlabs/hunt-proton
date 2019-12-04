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

module hunt.proton.engine.Receiver;

import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.WritableBuffer;

import hunt.proton.engine.Link;
/**
 * Receiver
 *
 */
interface Receiver : Link
{

    /**
     * Adds the specified number of credits.
     *
     * The number of link credits initialises to zero.  It is the application's responsibility to call
     * this method to allow the receiver to receive {@code credits} more deliveries.
     */
    public void flow(int credits);

    /**
     * Receive message data for the current delivery.
     *
     * If the caller takes all the bytes the Receiver currently has for this delivery then it is removed from
     * the Connection's work list.
     *
     * Before considering a delivery to be complete, the caller should examine {@link Delivery#isPartial()}.  If
     * the delivery is partial, the caller should call {@link #recv(byte[], int, int)} again to receive
     * the additional bytes once the Delivery appears again on the Connection work-list.
     *
     * TODO might the flags other than IO_WORK in DeliveryImpl also prevent the work list being pruned?
     * e.g. what if a slow JMS consumer receives a disposition frame containing state=RELEASED? This is not IO_WORK.
     *
     * @param bytes the destination array where the message data is written
     * @param offset index in the array to start writing data at
     * @param size the maximum number of bytes to write
     *
     * @return number of bytes written. -1 if there are no more bytes for the current delivery.
     *
     * @see #current()
     */
    public int recv(byte[] bytes, int offset, int size);

    /**
     * Receive message data for the current delivery.
     *
     * @param buffer the buffer to write the message data.
     *
     * @return number of bytes written. -1 if there are no more bytes for the current delivery.
     */
    public int recv(WritableBuffer buffer);

    /**
     * Receive message data for the current delivery returning the data in a Readable buffer.
     *
     * The delivery will return an empty buffer if there is no pending data to be read or if all
     * data has been read either by a previous call to this method or by a call to one of the other
     * receive methods.
     *
     * @return a ReadableBuffer that contains the currently available data for the current delivery.
     */
    public ReadableBuffer recv();

    public void drain(int credit);

    /**
     * {@inheritDoc}
     *
     * TODO document what this method conceptually does and when you should use it.
     */
    public bool advance();

    public bool draining();

    public void setDrain(bool drain);

}
