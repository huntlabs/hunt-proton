/*
 * hunt-proton: AMQP Protocol library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module hunt.proton.engine.impl.ByteBufferUtils;

import hunt.io.ByteBuffer;
import hunt.io.BufferUtils;
import hunt.proton.engine.Transport;
import hunt.proton.engine.TransportException;
import std.algorithm;
import hunt.proton.engine.impl.TransportInput;
import hunt.Exceptions;

class ByteBufferUtils
{
    /**
     * @return number of bytes poured
     */
    public static int pour(ByteBuffer source, ByteBuffer destination)
    {
        int numberOfBytesToPour = min(source.remaining(), destination.remaining());
        ByteBuffer sourceSubBuffer = source.duplicate();
        sourceSubBuffer.limit(sourceSubBuffer.position() + numberOfBytesToPour);
        destination.put(sourceSubBuffer);
        source.position(source.position() + numberOfBytesToPour);
        return numberOfBytesToPour;
    }

    /**
     * Assumes {@code destination} is ready to be written.
     *
     * @return number of bytes poured which may be fewer than {@code sizeRequested} if
     * {@code destination} has insufficient remaining
     */
    public static int pourArrayToBuffer(byte[] source, int offset, int sizeRequested, ByteBuffer destination)
    {
        int numberToWrite = min(destination.remaining(), sizeRequested);
        destination.put(source, offset, numberToWrite);
        return numberToWrite;
    }

    /**
     * Pours the contents of {@code source} into {@code destinationTransportInput}, calling
     * the TransportInput many times if necessary.  If the TransportInput returns a {@link hunt.proton.engine.TransportResult}
     * other than ok, data may remain in source.
     */
    public static int pourAll(ByteBuffer source, TransportInput destinationTransportInput)
    {
        int capacity = destinationTransportInput.capacity();
        if (capacity == Transport.END_OF_STREAM)
        {
            if (source.hasRemaining()) {
                throw new IllegalStateException("Destination has reached end of stream: ");
            } else {
                return Transport.END_OF_STREAM;
            }
        }

        int total = source.remaining();

        while(source.hasRemaining() && destinationTransportInput.capacity() > 0)
        {
            pour(source, destinationTransportInput.tail());
            destinationTransportInput.process();
        }

        return total - source.remaining();
    }

    /**
     * Assumes {@code source} is ready to be read.
     *
     * @return number of bytes poured which may be fewer than {@code sizeRequested} if
     * {@code source} has insufficient remaining
     */
    public static int pourBufferToArray(ByteBuffer source, byte[] destination, int offset, int sizeRequested)
    {
        int numberToRead = min(source.remaining(), sizeRequested);
        source.get(destination, offset, numberToRead);
        return numberToRead;
    }

    public static ByteBuffer newWriteableBuffer(int capacity)
    {
        ByteBuffer newBuffer = BufferUtils.allocate(capacity);
        return newBuffer;
    }

    public static ByteBuffer newReadableBuffer(int capacity)
    {
        ByteBuffer newBuffer = BufferUtils.allocate(capacity);
        newBuffer.flip();
        return newBuffer;
    }

}
