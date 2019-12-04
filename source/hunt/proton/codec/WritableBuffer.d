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

module hunt.proton.codec.WritableBuffer;

import hunt.proton.codec.ReadableBuffer;
import hunt.Exceptions;
import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import std.stdio;

abstract class WritableBuffer {
    void put(byte b);

    void putFloat(float f);

    void putDouble(double d);

    void put(byte[] src, int offset, int length);

    void putShort(short s);

    void putInt(int i);

    void putLong(long l);

    bool hasRemaining();

    //default void ensureRemaining(int requiredRemaining) {
    //    // No-op to allow for drop in updates
    //}
    void ensureRemaining(int requiredRemaining) {
        // No-op to allow for drop in updates
    }

    int remaining();

    int position();

    void position(int position);

    void put(ByteBuffer payload);

    void put(ReadableBuffer payload);

    void put(string value) {
        int length = cast(int)value.length;

        for (int i = 0; i < length; i++) {
            int c = value[i];
            if ((c & 0xFF80) == 0) {
                // U+0000..U+007F
                put(cast(byte) c);
            } else if ((c & 0xF800) == 0)  {
                // U+0080..U+07FF
                put(cast(byte) (0xC0 | ((c >> 6) & 0x1F)));
                put(cast(byte) (0x80 | (c & 0x3F)));
            } else if ((c & 0xD800) != 0xD800 || (c > 0xDBFF)) {
                // U+0800..U+FFFF - excluding surrogate pairs
                put(cast(byte) (0xE0 | ((c >> 12) & 0x0F)));
                put(cast(byte) (0x80 | ((c >> 6) & 0x3F)));
                put(cast(byte) (0x80 | (c & 0x3F)));
            } else {
                int low;

                if ((++i == length) || ((low = value[i]) & 0xDC00) != 0xDC00) {
                    throw new IllegalArgumentException("String contains invalid Unicode code points");
                }

                c = 0x010000 + ((c & 0x03FF) << 10) + (low & 0x03FF);

                put(cast(byte) (0xF0 | ((c >> 18) & 0x07)));
                put(cast(byte) (0x80 | ((c >> 12) & 0x3F)));
                put(cast(byte) (0x80 | ((c >> 6) & 0x3F)));
                put(cast(byte) (0x80 | (c & 0x3F)));
            }
        }
    }

    int limit();

}


class ByteBufferWrapper : WritableBuffer {
    private ByteBuffer _buf;

    this(ByteBuffer buf) {
        _buf = buf;
    }

    override
    public void put(byte b) {
        _buf.put(b);
    }

    override
    public void putFloat(float f) {
        _buf.putInt(cast(int)f);
    }

    override
    public void putDouble(double d) {
        _buf.putLong(cast(long)d);
    }

    override
    public void put(byte[] src, int offset, int length) {
        _buf.put(src, offset, length);
    }

    override
    public void putShort(short s) {
        _buf.putShort(s);
    }

    override
    public void putInt(int i) {
        _buf.putInt(i);
    }

    override
    public void putLong(long l) {
        _buf.putLong(l);
    }

    override
    public bool hasRemaining() {
        return _buf.hasRemaining();
    }

    override
    public void ensureRemaining(int remaining) {
        if (remaining < 0) {
            throw new IllegalArgumentException("Required remaining bytes cannot be negative");
        }

        if (_buf.remaining() < remaining) {
            writefln("....... %d  ..... %d",_buf.remaining(),remaining);
            //IndexOutOfBoundsException cause = new IndexOutOfBoundsException(String.format(
            //    "Requested min remaining bytes(%d) exceeds remaining(%d) in underlying ByteBuffer: %s",
            //    remaining, _buf.remaining(), _buf));

            throw (new BufferOverflowException());
        }
    }

    override
    public int remaining() {
        return _buf.remaining();
    }

    override
    public int position() {
        return _buf.position();
    }

    override
    public void position(int position) {
        _buf.position(position);
    }

    override
    public void put(ByteBuffer src) {
        _buf.put(src);
    }

    override
    public void put(ReadableBuffer src) {
        src.get(this);
    }

    override
    public void put(string value) {
        int length = cast(int)value.length;

        int pos = _buf.position();

        for (int i = 0; i < length; i++) {
            int c = value[i];
            try {
                if ((c & 0xFF80) == 0) {
                    // U+0000..U+007F
                    put(pos++, cast(byte) c);
                } else if ((c & 0xF800) == 0)  {
                    // U+0080..U+07FF
                    put(pos++, cast(byte) (0xC0 | ((c >> 6) & 0x1F)));
                    put(pos++, cast(byte) (0x80 | (c & 0x3F)));
                } else if ((c & 0xD800) != 0xD800 || (c > 0xDBFF))  {
                    // U+0800..U+FFFF - excluding surrogate pairs
                    put(pos++, cast(byte) (0xE0 | ((c >> 12) & 0x0F)));
                    put(pos++, cast(byte) (0x80 | ((c >> 6) & 0x3F)));
                    put(pos++, cast(byte) (0x80 | (c & 0x3F)));
                } else {
                    int low;

                    if ((++i == length) || ((low = value[i]) & 0xDC00) != 0xDC00) {
                        throw new IllegalArgumentException("String contains invalid Unicode code points");
                    }

                    c = 0x010000 + ((c & 0x03FF) << 10) + (low & 0x03FF);

                    put(pos++, cast(byte) (0xF0 | ((c >> 18) & 0x07)));
                    put(pos++, cast(byte) (0x80 | ((c >> 12) & 0x3F)));
                    put(pos++, cast(byte) (0x80 | ((c >> 6) & 0x3F)));
                    put(pos++, cast(byte) (0x80 | (c & 0x3F)));
                }
            }
            catch(IndexOutOfBoundsException ioobe) {
                throw new BufferOverflowException();
            }
        }

        // Now move the buffer position to reflect the work done here
        _buf.position(pos);
    }

    override
    public int limit() {
        return _buf.limit();
    }

    public ByteBuffer byteBuffer() {
        return _buf;
    }

    public ReadableBuffer toReadableBuffer() {
        return ByteBufferReader.wrap(cast(ByteBuffer) _buf.duplicate().flip());
    }

    //override
    //public string toString() {
    //    return String.format("[pos: %d, limit: %d, remaining:%d]", _buf.position(), _buf.limit(), _buf.remaining());
    //}

    public static ByteBufferWrapper allocate(int size) {
        ByteBuffer allocated = BufferUtils.allocate(size);
        return new ByteBufferWrapper(allocated);
    }

    public static ByteBufferWrapper wrap(ByteBuffer buffer) {
        return new ByteBufferWrapper(buffer);
    }

    public static ByteBufferWrapper wrap(byte[] bytes) {
        return new ByteBufferWrapper(BufferUtils.toBuffer(bytes));
    }

    private void put(int index, byte value) {
        if (_buf.hasArray()) {
            _buf.array()[_buf.arrayOffset() + index] = value;
        } else {
            _buf.put(index, value);
        }
    }
}