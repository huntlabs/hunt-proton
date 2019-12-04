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

module hunt.proton.engine.impl.HandshakeSniffingTransportWrapper;

import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.proton.engine.Transport;
import hunt.proton.engine.TransportException;
import hunt.proton.engine.impl.TransportWrapper;
import hunt.Exceptions;
import std.concurrency : initOnce;


class HandshakeSniffingTransportWrapper(T1 , T2): TransportWrapper
{

    protected T1 _wrapper1;
    protected T2 _wrapper2;

    private bool _tail_closed = false;
    private bool _head_closed = false;
    protected TransportWrapper _selectedTransportWrapper;

    private ByteBuffer _determinationBuffer;

    this(T1 wrapper1,T2 wrapper2)
    {
        _wrapper1 = wrapper1;
        _wrapper2 = wrapper2;
        _determinationBuffer = BufferUtils.allocate(bufferSize());
    }

    public int capacity()
    {
        if (isDeterminationMade())
        {
            return _selectedTransportWrapper.capacity();
        }
        else
        {
            if (_tail_closed) { return Transport.END_OF_STREAM; }
            return _determinationBuffer.remaining();
        }
    }

    public int position()
    {
        if (isDeterminationMade())
        {
            return _selectedTransportWrapper.position();
        }
        else
        {
            if (_tail_closed) { return Transport.END_OF_STREAM; }
            return _determinationBuffer.position();
        }
    }

    public ByteBuffer tail()
    {
        if (isDeterminationMade())
        {
            return _selectedTransportWrapper.tail();
        }
        else
        {
            return _determinationBuffer;
        }
    }

    protected abstract int bufferSize();

    protected abstract void makeDetermination(byte[] bytes);

    public void process() 
    {
        if (isDeterminationMade())
        {
            _selectedTransportWrapper.process();
        }
        else if (_determinationBuffer.remaining() == 0)
        {
            _determinationBuffer.flip();
            byte[] bytesInput = new byte[_determinationBuffer.remaining()];
            _determinationBuffer.get(bytesInput);
            makeDetermination(bytesInput);
            _determinationBuffer.rewind();

            // TODO what if the selected transport has insufficient capacity?? Maybe use pour, and then try to finish pouring next time round.
            _selectedTransportWrapper.tail().put(_determinationBuffer);
            _selectedTransportWrapper.process();
        } else if (_tail_closed) {
            throw new TransportException("connection aborted");
        }
    }

    
    public void close_tail()
    {
        try {
            if (isDeterminationMade())
            {
                _selectedTransportWrapper.close_tail();
            }
        } finally {
            _tail_closed = true;
        }
    }

    
    public int pending()
    {
        if (_head_closed) { return Transport.END_OF_STREAM; }

        if (isDeterminationMade()) {
            return _selectedTransportWrapper.pending();
        } else {
            return 0;
        }

    }

    //private static ByteBuffer EMPTY = BufferUtils.allocate(0);

    static ByteBuffer  EMPTY() {
        __gshared ByteBuffer  inst;
        return initOnce!inst(BufferUtils.allocate(0));
    }


    public ByteBuffer head()
    {
        if (isDeterminationMade()) {
            return _selectedTransportWrapper.head();
        } else {
            return EMPTY;
        }
    }

    
    public void pop(int bytes)
    {
        if (isDeterminationMade()) {
            _selectedTransportWrapper.pop(bytes);
        } else if (bytes > 0) {
            throw new IllegalStateException("no bytes have been read");
        }
    }

    
    public void close_head()
    {
        if (isDeterminationMade()) {
            _selectedTransportWrapper.close_head();
        } else {
            _head_closed = true;
        }
    }

    protected bool isDeterminationMade()
    {
        return _selectedTransportWrapper !is null;
    }

}
