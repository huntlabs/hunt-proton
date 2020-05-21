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

module hunt.proton.amqp.Binary;

import hunt.io.ByteBuffer;
import hunt.collection.Collection;
import hunt.proton.codec.ReadableBuffer;
import hunt.io.BufferUtils;

class Binary
{
    private  byte[] _data;
    private  int _offset;
    private  int _length;
    private  int _hashCode;

    this( byte[] data)
    {
        this(data, 0, cast(int)(data.length));
    }

    this( byte[] data, int offset,int length)
    {
        _data = data;
        _offset = offset;
        _length = length;
    }

    public ByteBuffer asByteBuffer()
    {
        return BufferUtils.toBuffer(_data,_offset,_length);
    }

    //override
    //public int hashCode()
    //{
    //    int hc = _hashCode;
    //    if(hc == 0)
    //    {
    //        for (int i = 0; i < _length; i++)
    //        {
    //            hc = 31*hc + (0xFF & _data[_offset + i]);
    //        }
    //        _hashCode = hc;
    //    }
    //    return hc;
    //}

    override
    public  size_t toHash() @trusted nothrow
    {
            int hc = _hashCode;
            if(hc == 0)
            {
                for (int i = 0; i < _length; i++)
                {
                    hc = 31*hc + (0xFF & _data[_offset + i]);
                }
                _hashCode = hc;
            }
            return cast(size_t)hc;
    }

   override bool opEquals(Object o)
    {
        if (this is o)
        {
            return true;
        }

        if (o is null || cast(Binary)o is null)
        {
            return false;
        }

        Binary buf = cast(Binary) o;
        int size = _length;
        if (size != buf.getLength())
        {
            return false;
        }

        byte[] myData = _data;
        byte[] theirData = buf.getArray();
        int myOffset = _offset;
        int theirOffset = buf.getArrayOffset();
        int myLimit = myOffset + size;

        while(myOffset < myLimit)
        {
            if (myData[myOffset++] != theirData[theirOffset++])
            {
                return false;
            }
        }

        return true;
    }

    public int getArrayOffset()
    {
        return _offset;
    }

    public byte[] getArray()
    {
        return _data;
    }

    public int getLength()
    {
        return _length;
    }


    public static Binary combine(Collection!Binary binaries)
    {
        if(binaries.size() == 1)
        {
            return binaries.iterator().front();
        }

        byte[] data ;
        foreach(Binary binary ; binaries)
        {
            data ~= binary.getArray()[binary.getArrayOffset() .. $];
        }
        return new Binary(data);
    }

    public Binary subBinary(int offset,int length)
    {
        return new Binary(_data, _offset+offset, length);
    }

    public static Binary create(ReadableBuffer buffer)
    {
        if (buffer is null)
        {
            return null;
        }
        else if (!buffer.hasArray())
        {
            byte[] data = new byte [buffer.remaining()];
            ReadableBuffer dup = buffer.duplicate();
            dup.get(data);
            return new Binary(data);
        }
        else
        {
            return new Binary(buffer.array(), buffer.arrayOffset() + buffer.position(), buffer.remaining());
        }
    }

    public static Binary create(ByteBuffer buffer)
    {
        if (buffer is null)
        {
            return null;
        }
        if (buffer.isDirect() || buffer.isReadOnly())
        {
            byte[] data = new byte [buffer.remaining()];
            ByteBuffer dup = buffer.duplicate();
            dup.get(data);
            return new Binary(data);
        }
        else
        {
            return new Binary(buffer.array(), buffer.arrayOffset()+buffer.position(), buffer.remaining());
        }
    }

    public static Binary copy(Binary source)
    {
        if (source is null)
        {
            return null;
        }
        else
        {
            byte[] data ;
          //  System.arraycopy(source.getArray(), source.getArrayOffset(), data, 0, source.getLength());
            data ~= source.getArray()[source.getArrayOffset() .. $];
            return new Binary(data);
        }
    }
}
