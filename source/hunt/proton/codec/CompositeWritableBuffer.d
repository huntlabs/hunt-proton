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
module hunt.proton.codec.CompositeWritableBuffer;

import hunt.collection.ByteBuffer;

import hunt.proton.codec.ReadableBuffer;
import hunt.collection.BufferUtils;
import hunt.proton.codec.WritableBuffer;
import hunt.Float;
import hunt.Double;
import hunt.String;

class CompositeWritableBuffer : WritableBuffer
{
    private WritableBuffer _first;
    private WritableBuffer _second;

    this(WritableBuffer first, WritableBuffer second)
    {
        _first = first;
        _second = second;
    }

    override
    public void put(byte b)
    {
        (_first.hasRemaining() ? _first : _second).put(b);
    }

    override
    public void putFloat(float f)
    {
        putInt(Float.floatToRawIntBits(f));
    }

    override
    public void putDouble(double d)
    {
        putLong(Double.doubleToRawLongBits(d));
    }

    override
    public void putShort(short s)
    {
        int remaining = _first.remaining();
        if(remaining >= 2)
        {
            _first.putShort(s);
        }
        else if(remaining ==0 )
        {
            _second.putShort(s);
        }
        else
        {
            ByteBuffer wrap = BufferUtils.toBuffer(new byte[2]);
            wrap.putShort(s);
            wrap.flip();
            put(wrap);
        }
    }

    override
    public void putInt(int i)
    {
        int remaining = _first.remaining();
        if(remaining >= 4)
        {
            _first.putInt(i);
        }
        else if(remaining ==0 )
        {
            _second.putInt(i);
        }
        else
        {
            ByteBuffer wrap = BufferUtils.toBuffer(new byte[4]);
            wrap.putInt(i);
            wrap.flip();
            put(wrap);
        }
    }

    override
    public void putLong(long l)
    {
        int remaining = _first.remaining();
        if(remaining >= 8)
        {
            _first.putLong(l);
        }
        else if(remaining ==0 )
        {
            _second.putLong(l);
        }
        else
        {
            ByteBuffer wrap = BufferUtils.toBuffer(new byte[8]);
            wrap.putLong(l);
            wrap.flip();
            put(wrap);
        }
    }

    override
    public bool hasRemaining()
    {
        return _first.hasRemaining() || _second.hasRemaining();
    }

    override
    public int remaining()
    {
        return _first.remaining()+_second.remaining();
    }

    override
    public int position()
    {
        return _first.position()+_second.position();
    }

    override
    public int limit()
    {
        return _first.limit() + _second.limit();
    }

    override
    public void position(int position)
    {
        int first_limit = _first.limit();
        if( position <= first_limit )
        {
            _first.position(position);
            _second.position(0);
        }
        else
        {
            _first.position(first_limit);
            _second.position(position - first_limit);
        }
    }

    override
    public void put(byte[] src, int offset, int length)
    {
        int firstRemaining = _first.remaining();
        if(firstRemaining > 0)
        {
            if(firstRemaining >= length)
            {
                _first.put(src, offset, length);
                return;
            }
            else
            {
                _first.put(src,offset, firstRemaining);
            }
        }
        _second.put(src, offset+firstRemaining, length-firstRemaining);
    }

    override
    public void put(ByteBuffer payload)
    {
        int firstRemaining = _first.remaining();
        if(firstRemaining > 0)
        {
            if(firstRemaining >= payload.remaining())
            {
                _first.put(payload);
                return;
            }
            else
            {
                int limit = payload.limit();
                payload.limit(payload.position()+firstRemaining);
                _first.put(payload);
                payload.limit(limit);
            }
        }
        _second.put(payload);
    }

    //override
    //public String toString()
    //{
    //    return _first.toString() ~ " ~ "+_second.toString();
    //}

    override
    public void put(ReadableBuffer payload) {
        int firstRemaining = _first.remaining();
        if(firstRemaining > 0)
        {
            if(firstRemaining >= payload.remaining())
            {
                _first.put(payload);
                return;
            }
            else
            {
                int limit = payload.limit();
                payload.limit(payload.position()+firstRemaining);
                _first.put(payload);
                payload.limit(limit);
            }
        }
        _second.put(payload);
    }

    public void put(String value)
    {
        if (_first.hasRemaining())
        {
            byte[] utf8Bytes = value.getBytes();
            put(utf8Bytes, 0, cast(int)utf8Bytes.length);
        }
        else
        {
            _second.put(cast(string)value.getBytes());
        }
    }
}
