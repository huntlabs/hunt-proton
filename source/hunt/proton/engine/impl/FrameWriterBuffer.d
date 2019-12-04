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
module hunt.proton.engine.impl.FrameWriterBuffer;

import hunt.collection.ByteBuffer;
import std.algorithm;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.WritableBuffer;
import hunt.Byte;
import hunt.Short;
import hunt.Long;
import hunt.Integer;
import hunt.Float;
import hunt.Double;
import hunt.Exceptions;
import hunt.logging;
class FrameWriterBuffer : WritableBuffer {

    public static int DEFAULT_CAPACITY = 1024;

    byte [] _array;
    int _position;

   /**
    * Creates a new WritableBuffer with default capacity.
    */
   this() {
       this(DEFAULT_CAPACITY);
   }

    /**
     * Create a new WritableBuffer with the given capacity.
     *
     * @param capacity
     *      the inital capacity to allocate for this buffer.
     */
    this(int capacity) {
        this._array = new byte[capacity];
    }

    public byte[] array() {
        return _array;
    }

    public int arrayOffset() {
        return 0;
    }

    override
    public void put(byte b) {
        ensureRemaining(Byte.BYTES);
        _array[_position++] = b;
    }

    override
    public void putShort(short value) {
        ensureRemaining(Short.BYTES);
        _array[_position++] = cast(byte)(value >>> 8);
        _array[_position++] = cast(byte)(value >>> 0);
    }

    override
    public void putInt(int value) {
        ensureRemaining(Integer.BYTES);
        _array[_position++] = cast(byte)(value >>> 24);
        _array[_position++] = cast(byte)(value >>> 16);
        _array[_position++] = cast(byte)(value >>> 8);
        _array[_position++] = cast(byte)(value >>> 0);
    }

    override
    public void putLong(long value) {
        ensureRemaining(Long.BYTES);
        _array[_position++] = cast(byte)(value >>> 56);
        _array[_position++] = cast(byte)(value >>> 48);
        _array[_position++] = cast(byte)(value >>> 40);
        _array[_position++] = cast(byte)(value >>> 32);
        _array[_position++] = cast(byte)(value >>> 24);
        _array[_position++] = cast(byte)(value >>> 16);
        _array[_position++] = cast(byte)(value >>> 8);
        _array[_position++] = cast(byte)(value >>> 0);
    }

    override
    public void putFloat(float value) {
        putInt(Float.floatToRawIntBits(value));
    }

    override
    public void putDouble(double value) {
        putLong(Double.doubleToRawLongBits(value));
    }

    override
    public void put(byte[] src, int offset, int length) {
        if (length == 0) {
            return;
        }

        ensureRemaining(length);
        //System.arraycopy(src, offset, array, position, length);
        _array[_position .. _position+length] = src[offset .. offset+length];
        _position += length;
    }

    override
    public void put(ByteBuffer payload) {
        int toCopy = payload.remaining();
        ensureRemaining(toCopy);

        if (payload.hasArray()) {
            //System.arraycopy(payload.array(), payload.arrayOffset() + payload.position(), array, position, toCopy);
            _array[_position .. _position+toCopy] = payload.array()[payload.arrayOffset() + payload.position() .. payload.arrayOffset() + payload.position()+toCopy];
            payload.position(payload.position() + toCopy);
        } else {
            payload.get(_array, _position, toCopy);
        }

        _position += toCopy;
    }

    override
    public void put(ReadableBuffer payload) {
        int toCopy = payload.remaining();
        ensureRemaining(toCopy);

        if (payload.hasArray()) {
            //System.arraycopy(payload.array(), payload.arrayOffset() + payload.position(), array, position, toCopy);
            _array[_position .. toCopy+ _position] = payload.array()[payload.arrayOffset() + payload.position() .. payload.arrayOffset() + payload.position() + toCopy];
            payload.position(payload.position() + toCopy);
        } else {
            payload.get(_array, _position, toCopy);
        }

        _position += toCopy;
    }

    override
    public bool hasRemaining() {
        return _position < Integer.MAX_VALUE;
    }

    override
    public int remaining() {
        return Integer.MAX_VALUE - _position;
    }

    /**
     * Ensures the the buffer has at least the requiredRemaining space specified.
     * <p>
     * The internal buffer will be doubled if the requested capacity is less than that
     * amount or the buffer will be expanded to the full new requiredRemaining value.
     *
     * @param requiredRemaining
     *      the minimum remaining bytes needed to meet the next write operation.
     */
    override
    public void ensureRemaining(int requiredRemaining) {
        if (requiredRemaining > _array.length - _position) {
            byte [] newBuffer = new byte[max(_array.length << 1, requiredRemaining + _position)];
            newBuffer[0 .. _array.length] = _array[0 .. _array.length];
            //System.arraycopy(array, 0, newBuffer, 0, array.length);
            _array = newBuffer;
        }
    }

    override
    public int position() {
        return _position;
    }

    override
    public void position(int position) {
        if (position < 0) {
            throw new IllegalArgumentException("Requested new buffer position cannot be negative");
        }

        if (position > _array.length) {
            ensureRemaining(position - cast(int)_array.length);
        }

        this._position = position;
    }

    override
    public int limit() {
        return Integer.MAX_VALUE;
    }

    /**
     * Copy bytes from this buffer into the target buffer and compacts this buffer.
     * <p>
     * Copy either all bytes written into this buffer (start to current position) or
     * as many as will fit if the target capacity is less that the bytes written.  Bytes
     * not read from this buffer are moved to the front of the buffer and the position is
     * reset to the end of the copied region.
     *
     * @param target
     *      The array to move bytes to from those written into this buffer.
     *
     * @return the number of bytes transfered to the target buffer.
     */
    public int transferTo(ByteBuffer target) {
        int size = min(_position, target.remaining());
        if (size == 0) {
            return 0;
        }

        if (target.hasArray()) {
           // System.arraycopy(array, 0, target.array(), target.arrayOffset() + target.position(), size);
            target.array()[target.arrayOffset() + target.position() .. target.arrayOffset() + target.position()+size] = _array[0 .. size];
            target.position(target.position() + size);
        } else {
            target.put(_array, 0, size);
        }

        // Compact any remaining data to the front of the array so that new writes can reuse
        // space previously allocated and not extend the array if possible.
        if (size != _position) {
            int remainder = _position - size;
            //System.arraycopy(array, size, array, 0, remainder);
            _array[0 .. remainder] = _array[size .. size + remainder];
            _position = remainder;  // ensure we are at end of unread chunk
        } else {
            _position = 0; // reset to empty state.
        }

        return size;
    }
}
