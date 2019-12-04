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

module hunt.proton.engine.impl.PlainTransportWrapper;

import hunt.collection.ByteBuffer;

import hunt.proton.engine.TransportException;
import hunt.proton.engine.impl.TransportWrapper;
import hunt.proton.engine.impl.TransportInput;
import hunt.proton.engine.impl.TransportOutput;


class PlainTransportWrapper : TransportWrapper
{
    private TransportOutput _outputProcessor;
    private TransportInput _inputProcessor;

    this(TransportOutput outputProcessor,
            TransportInput inputProcessor)
    {
        _outputProcessor = outputProcessor;
        _inputProcessor = inputProcessor;
    }

    public int capacity()
    {
        return _inputProcessor.capacity();
    }

    public int position()
    {
        return _inputProcessor.position();
    }

    public ByteBuffer tail()
    {
        return _inputProcessor.tail();
    }

    public void process()
    {
        _inputProcessor.process();
    }

    public void close_tail()
    {
        _inputProcessor.close_tail();
    }

    public int pending()
    {
        return _outputProcessor.pending();
    }

    public ByteBuffer head()
    {
        return _outputProcessor.head();
    }

    public void pop(int bytes)
    {
        _outputProcessor.pop(bytes);
    }

    public void close_head()
    {
        _outputProcessor.close_head();
    }

}