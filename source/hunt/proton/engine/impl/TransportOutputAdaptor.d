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
module hunt.proton.engine.impl.TransportOutputAdaptor;

import hunt.proton.engine.impl.ByteBufferUtils;

import hunt.io.ByteBuffer;
import hunt.proton.engine.impl.TransportImpl;
import hunt.proton.engine.Transport;
import hunt.proton.engine.impl.TransportOutputWriter;
import hunt.proton.engine.impl.TransportOutput;
import std.concurrency : initOnce;
import hunt.logging;

class TransportOutputAdaptor : TransportOutput
{
   // private static ByteBuffer _emptyHead = newReadableBuffer(0).asReadOnlyBuffer();

    static ByteBuffer  _emptyHead() {
        __gshared ByteBuffer  inst;
        return initOnce!inst(ByteBufferUtils.newReadableBuffer(0).asReadOnlyBuffer());
    }

    private TransportOutputWriter _transportOutputWriter;
    private int _maxFrameSize;

    private ByteBuffer _outputBuffer = null;
    private ByteBuffer _head = null;
    private bool _output_done = false;
    private bool _head_closed = false;
    private bool _readOnlyHead = true;

    this(TransportOutputWriter transportOutputWriter, int maxFrameSize, bool readOnlyHead)
    {
        _transportOutputWriter = transportOutputWriter;
        _maxFrameSize = maxFrameSize > 0 ? maxFrameSize : 16*1024;
        _readOnlyHead = readOnlyHead;
    }

    
    public int pending()
    {
        if (_head_closed) {
            return Transport.END_OF_STREAM;
        }

        if(_outputBuffer is null)
        {
            init_buffers();
        }
       // logInfof("pending ------- %s",_outputBuffer.getRemaining());
        _output_done = _transportOutputWriter.writeInto(_outputBuffer);
        _head.limit(_outputBuffer.position());

        if (_outputBuffer.position() == 0 && _outputBuffer.capacity() > TransportImpl.BUFFER_RELEASE_THRESHOLD)
        {
            release_buffers();
        }

        if (_output_done && (_outputBuffer is null || _outputBuffer.position() == 0))
        {
            return Transport.END_OF_STREAM;
        }
        else
        {
            return _outputBuffer is null ? 0 : _outputBuffer.position();
        }
    }

    
    public ByteBuffer head()
    {
        pending();
        return _head !is null ? _head : _emptyHead;
    }

    
    public void pop(int bytes)
    {
        if (_outputBuffer !is null) {
            _outputBuffer.flip();
            _outputBuffer.position(bytes);
            _outputBuffer.compact();
            _head.position(0);
            _head.limit(_outputBuffer.position());
            if (_outputBuffer.position() == 0 && _outputBuffer.capacity() > TransportImpl.BUFFER_RELEASE_THRESHOLD) {
                release_buffers();
            }
        }
    }

    
    public void close_head()
    {
        _head_closed = true;
        _transportOutputWriter.closed(null);
        release_buffers();
    }

    private void init_buffers() {
        _outputBuffer = ByteBufferUtils.newWriteableBuffer(_maxFrameSize);
        if (_readOnlyHead) {
            _head = _outputBuffer.asReadOnlyBuffer();
        } else {
            _head = _outputBuffer.duplicate();
        }
        _head.limit(0);
    }

    private void release_buffers() {
        _head = null;
        _outputBuffer = null;
    }
}
