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

module hunt.proton.codec.DroppingWritableBuffer;

import hunt.collection.ByteBuffer;
import hunt.proton.codec.WritableBuffer;
import hunt.Integer;
import hunt.String;
import hunt.proton.codec.ReadableBuffer;

class DroppingWritableBuffer : WritableBuffer
{
    private int _pos = 0;

    override
    public bool hasRemaining()
    {
        return true;
    }

    override
    public void put(byte b)
    {
        _pos += 1;
    }

    override
    public void putFloat(float f)
    {
        _pos += 4;
    }

    override
    public void putDouble(double d)
    {
        _pos += 8;
    }

    override
    public void put(byte[] src, int offset, int length)
    {
        _pos += length;
    }

    override
    public void putShort(short s)
    {
        _pos += 2;
    }

    override
    public void putInt(int i)
    {
        _pos += 4;
    }

    override
    public void putLong(long l)
    {
        _pos += 8;
    }

    override
    public int remaining()
    {
        return Integer.MAX_VALUE - _pos;
    }

    override
    public int position()
    {
        return _pos;
    }

    override
    public void position(int position)
    {
        _pos = position;
    }

    override
    public void put(ByteBuffer payload)
    {
        _pos += payload.remaining();
        payload.position(payload.limit());
    }

    override
    public int limit()
    {
        return Integer.MAX_VALUE;
    }

    override
    public void put(ReadableBuffer payload)
    {
        _pos += payload.remaining();
        payload.position(payload.limit());
    }

    public void put(String value)
    {
        _pos += value.getBytes().length;
    }
}
