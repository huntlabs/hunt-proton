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

module hunt.proton.engine.impl.FrameParser;

import  hunt.proton.engine.impl.AmqpHeader;
import  hunt.proton.engine.impl.ByteBufferUtils;

import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.transport.EmptyFrame;
import hunt.proton.amqp.transport.FrameBody;
import hunt.proton.codec.ByteBufferDecoder;
import hunt.proton.codec.DecodeException;
import hunt.proton.engine.Transport;
import hunt.proton.engine.TransportException;
import hunt.proton.framing.TransportFrame;
import hunt.proton.engine.impl.TransportInput;
import hunt.proton.engine.impl.FrameHandler;
import hunt.proton.engine.impl.TransportImpl;
import std.concurrency : initOnce;
import hunt.proton.engine.impl.ProtocolTracer;
import hunt.logging;
import hunt.String;

class FrameParser : TransportInput
{
    private static string HEADER_DESCRIPTION = "AMQP";

    //private static ByteBuffer _emptyInputBuffer = newWriteableBuffer(0);


   static ByteBuffer  _emptyInputBuffer() {
       __gshared ByteBuffer  inst;
       return initOnce!inst(ByteBufferUtils.newWriteableBuffer(0));
   }

    enum State
    {
        HEADER0,
        HEADER1,
        HEADER2,
        HEADER3,
        HEADER4,
        HEADER5,
        HEADER6,
        HEADER7,
        SIZE_0,
        SIZE_1,
        SIZE_2,
        SIZE_3,
        PRE_PARSE,
        BUFFERING,
        PARSING,
        ERROR
    }

    private FrameHandler _frameHandler;
    private ByteBufferDecoder _decoder;
    private int _inputBufferSize;
    private int _localMaxFrameSize;
    private TransportImpl _transport;

    private ByteBuffer _inputBuffer = null;
    private bool _tail_closed = false;

    private State _state = State.HEADER0;

    private long _framesInput = 0;

    /** the stated size of the current frame */
    private int _size;

    /** holds the current frame that is being parsed */
    private ByteBuffer _frameBuffer;

    private TransportFrame _heldFrame;
    private TransportException _parsingError;


    /**
     * We store the last result when processing input so that
     * we know not to process any more input if it was an error.
     */
    this(FrameHandler frameHandler, ByteBufferDecoder decoder, int localMaxFrameSize, TransportImpl transport)
    {
        _frameHandler = frameHandler;
        _decoder = decoder;
        _localMaxFrameSize = localMaxFrameSize;
        _inputBufferSize = _localMaxFrameSize > 0 ? _localMaxFrameSize : 16*1024;
        _transport = transport;
    }

    private void input(ByteBuffer inbuf)
    {
        //logError("inbuf : %s",inbuf.array());
       // ByteBuffer tmp = inbuf;
      //  logError("inbuf : %s",inbuf.getRemaining());
        flushHeldFrame();
        if (_heldFrame !is null)
        {
            return;
        }

        TransportException frameParsingError = null;
        int size = _size;
        State state = _state;
        ByteBuffer oldIn = null;

        bool transportAccepting = true;

        while(inbuf.hasRemaining() && state != State.ERROR && transportAccepting)
        {
            switch(state)
            {
                case State.HEADER0:
                    if(inbuf.hasRemaining())
                    {
                        byte c = inbuf.get();
                        if(c != AmqpHeader.HEADER[0])
                        {
                            frameParsingError = new TransportException("AMQP header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }
                        state = State.HEADER1;
                        goto case;
                    }
                    else
                    {
                        break;
                    }
                case State.HEADER1:
                    if(inbuf.hasRemaining())
                    {
                        byte c = inbuf.get();
                        if(c != AmqpHeader.HEADER[1])
                        {
                            frameParsingError = new TransportException("AMQP header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }
                        state = State.HEADER2;
                        goto case;
                    }
                    else
                    {
                        break;
                    }
                case State.HEADER2:
                    if(inbuf.hasRemaining())
                    {
                        byte c = inbuf.get();
                        if(c != AmqpHeader.HEADER[2])
                        {
                            frameParsingError = new TransportException("AMQP header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }
                        state = State.HEADER3;
                        goto case;
                    }
                    else
                    {
                        break;
                    }
                case State.HEADER3:
                    if(inbuf.hasRemaining())
                    {
                        byte c = inbuf.get();
                        if(c != AmqpHeader.HEADER[3])
                        {
                            frameParsingError = new TransportException("AMQP header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }
                        state = State.HEADER4;
                        goto case;
                    }
                    else
                    {
                        break;
                    }
                case State.HEADER4:
                    if(inbuf.hasRemaining())
                    {
                        byte c = inbuf.get();
                        if(c != AmqpHeader.HEADER[4])
                        {
                            frameParsingError = new TransportException("AMQP header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }
                        state = State.HEADER5;
                        goto case;
                    }
                    else
                    {
                        break;
                    }
                case State.HEADER5:
                    if(inbuf.hasRemaining())
                    {
                        byte c = inbuf.get();
                        if(c != AmqpHeader.HEADER[5])
                        {
                            frameParsingError = new TransportException("AMQP header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }
                        state = State.HEADER6;
                        goto case;
                    }
                    else
                    {
                        break;
                    }
                case State.HEADER6:
                    if(inbuf.hasRemaining())
                    {
                        byte c = inbuf.get();
                        if(c != AmqpHeader.HEADER[6])
                        {
                            frameParsingError = new TransportException("AMQP header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }
                        state = State.HEADER7;
                        goto case;
                    }
                    else
                    {
                        break;
                    }
                case State.HEADER7:
                    if(inbuf.hasRemaining())
                    {
                        byte c = inbuf.get();
                        if(c != AmqpHeader.HEADER[7])
                        {
                            frameParsingError = new TransportException("AMQP header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }

                        logHeader();

                        state = State.SIZE_0;
                        goto case;
                    }
                    else
                    {
                        break;
                    }
                case State.SIZE_0:
                    if(!inbuf.hasRemaining())
                    {
                        break;
                    }
                    if(inbuf.remaining() >= 4)
                    {
                        size = inbuf.getInt();
                        state = State.PRE_PARSE;
                        break;
                    }
                    else
                    {
                        size = (inbuf.get() << 24) & 0xFF000000;
                        if(!inbuf.hasRemaining())
                        {
                            state = State.SIZE_1;
                            break;
                        }
                    }
                    goto case;
                case State.SIZE_1:
                    size |= (inbuf.get() << 16) & 0xFF0000;
                    if(!inbuf.hasRemaining())
                    {
                        state = State.SIZE_2;
                        break;
                    }
                    goto case;
                case State.SIZE_2:
                    size |= (inbuf.get() << 8) & 0xFF00;
                    if(!inbuf.hasRemaining())
                    {
                        state = State.SIZE_3;
                        break;
                    }
                    goto case;
                case State.SIZE_3:
                    size |= inbuf.get() & 0xFF;
                    state = State.PRE_PARSE;
                    goto case;
                case State.PRE_PARSE:
                    if(size < 8)
                    {
                        frameParsingError = new TransportException("specified frame size %d smaller than minimum frame header ");
                        state = State.ERROR;
                        break;
                    }

                    if (_localMaxFrameSize > 0 && size > _localMaxFrameSize)
                    {
                        frameParsingError = new TransportException("specified frame size %d greater than maximum valid frame size %d");
                        state = State.ERROR;
                        break;
                    }

                    if(inbuf.remaining() < size-4)
                    {
                        _frameBuffer = BufferUtils.allocate(size-4);
                        _frameBuffer.put(inbuf);
                        state = State.BUFFERING;
                        break;
                    }
                    goto case;
                case State.BUFFERING:
                    if(_frameBuffer !is null)
                    {
                        if(inbuf.remaining() < _frameBuffer.remaining())
                        {
                            _frameBuffer.put(inbuf);
                            break;
                        }
                        else
                        {
                            ByteBuffer dup = inbuf.duplicate();
                            dup.limit(dup.position()+_frameBuffer.remaining());
                            inbuf.position(inbuf.position()+_frameBuffer.remaining());
                            _frameBuffer.put(dup);
                            oldIn = inbuf;
                            _frameBuffer.flip();
                            inbuf = _frameBuffer;
                            state = State.PARSING;
                        }
                    }
                    goto case;
                case State.PARSING:

                    int dataOffset = (inbuf.get() << 2) & 0x3FF;

                    if(dataOffset < 8)
                    {
                        frameParsingError = new TransportException("specified frame data offset %d smaller than minimum frame header size ");
                        state = State.ERROR;
                        break;
                    }
                    else if(dataOffset > size)
                    {
                        frameParsingError = new TransportException("specified frame data offset %d larger than the frame size ");
                        state = State.ERROR;
                        break;
                    }

                    // type

                    int type = inbuf.get() & 0xFF;
                    int channel = inbuf.getShort() & 0xFFFF;

                    if(type != 0)
                    {
                        frameParsingError = new TransportException("unknown frame type");
                        state = State.ERROR;
                        break;
                    }

                    // note that this skips over the extended header if it's present
                    if(dataOffset!=8)
                    {
                        inbuf.position(inbuf.position()+dataOffset-8);
                    }

                    // oldIn null iff not working on duplicated buffer
                    int frameBodySize = size - dataOffset;
                    if(oldIn is null)
                    {
                        oldIn = inbuf;
                        inbuf = inbuf.duplicate();
                        int endPos = inbuf.position() + frameBodySize;
                        inbuf.limit(endPos);
                        oldIn.position(endPos);

                    }

                    try
                    {
                        _framesInput += 1;

                        Binary payload = null;
                        Object val = null;

                        if (frameBodySize > 0)
                        {
                            _decoder.setByteBuffer(inbuf);
                            val = _decoder.readObject();
                            _decoder.setByteBuffer(null);

                            if(inbuf.hasRemaining())
                            {
                                byte[] payloadBytes = new byte[inbuf.remaining()];
                                inbuf.get(payloadBytes);
                                payload = new Binary(payloadBytes);
                            }
                            else
                            {
                                payload = null;
                            }
                        }
                        else
                        {
                            val = EmptyFrame.INSTANCE;
                        }

                        FrameBody frameBody = cast(FrameBody) val;
                        if(frameBody !is null)
                        {

                            //if(TRACE_LOGGER.isLoggable(Level.FINE))
                            //{
                            //    TRACE_LOGGER.log(Level.FINE, "IN: CH["+channel+"] : " + frameBody + (payload is null ? "" : "[" + payload + "]"));
                            //}
                            TransportFrame frame = new TransportFrame(channel, frameBody, payload);

                            if(_frameHandler.isHandlingFrames())
                            {
                                _tail_closed = _frameHandler.handleFrame(frame);
                            }
                            else
                            {
                                transportAccepting = false;
                                _heldFrame = frame;
                            }
                        }
                        else
                        {
                            logError("Frameparser encountered a null");
                            //throw new TransportException("Frameparser encountered a "
                            //        + (val is null? "null" : val.getClass())
                            //        + " which is not a " + FrameBody.class);
                        }

                        reset();
                        inbuf = oldIn;
                        oldIn = null;
                        _frameBuffer = null;
                        state = State.SIZE_0;
                    }
                    catch (DecodeException ex)
                    {
                        state = State.ERROR;
                        frameParsingError = new TransportException(ex);
                    }
                    break;
                case State.ERROR:
                    break;
                    // do nothing
                default:
                    break;
            }

        }

        if (_tail_closed)
        {
            if (inbuf.hasRemaining()) {
                state = State.ERROR;
                frameParsingError = new TransportException("framing error");
            } else if (state != State.SIZE_0) {
                state = State.ERROR;
                frameParsingError = new TransportException("connection aborted");
            } else {
                _frameHandler.closed(null);
            }
        }

        _state = state;
        _size = size;

        if(_state == State.ERROR)
        {
            _tail_closed = true;
            if(frameParsingError !is null)
            {
                _parsingError = frameParsingError;
                _frameHandler.closed(frameParsingError);
            }
            else
            {
                throw new TransportException("Unable to parse, probably because of a previous error");
            }
        }
    }

    override
    public int capacity()
    {
        if (_tail_closed) {
            return Transport.END_OF_STREAM;
        } else {
            if (_inputBuffer !is null) {
                return _inputBuffer.remaining();
            } else {
                return _inputBufferSize;
            }
        }
    }

    override
    public int position() {
        if (_tail_closed) {
            return Transport.END_OF_STREAM;
        }
        return (_inputBuffer is null) ? 0 : _inputBuffer.position();
    }

    override
    public ByteBuffer tail()
    {
        if (_tail_closed) {
            throw new TransportException("tail closed");
        }

        if (_inputBuffer is null) {
            _inputBuffer = ByteBufferUtils.newWriteableBuffer(_inputBufferSize);
        }

        return _inputBuffer;
    }

    override
    public void process()
    {
        if (_inputBuffer !is null)
        {
            _inputBuffer.flip();

            try
            {
                input(_inputBuffer);
            }
            finally
            {
                if (_inputBuffer.hasRemaining()) {
                    _inputBuffer.compact();
                } else if (_inputBuffer.capacity() > TransportImpl.BUFFER_RELEASE_THRESHOLD) {
                    _inputBuffer = null;
                } else {
                    _inputBuffer.clear();
                }
            }
        }
        else
        {
            input(_emptyInputBuffer);
        }
    }

    override
    public void close_tail()
    {
        _tail_closed = true;
        process();
    }

    /**
     * Attempt to flush any cached data to the frame transport.  This function
     * is useful if the {@link FrameHandler} state has changed.
     */
    public void flush()
    {
        flushHeldFrame();

        if (_heldFrame is null)
        {
            process();
        }
    }

    private void flushHeldFrame()
    {
        if(_heldFrame !is null && _frameHandler.isHandlingFrames())
        {
            _tail_closed = _frameHandler.handleFrame(_heldFrame);
            _heldFrame = null;
        }
    }

    private void reset()
    {
        _size = 0;
        _state = State.SIZE_0;
    }

    long getFramesInput()
    {
        return _framesInput;
    }

    private void logHeader() {
        if (_transport.isFrameTracingEnabled()) {
            _transport.log(TransportImpl.INCOMING, new String(HEADER_DESCRIPTION));

            ProtocolTracer tracer = _transport.getProtocolTracer();
            if (tracer !is null) {
                tracer.receivedHeader(HEADER_DESCRIPTION);
            }
        }
    }
}
