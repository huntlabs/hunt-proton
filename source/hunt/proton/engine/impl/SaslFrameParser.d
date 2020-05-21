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

module hunt.proton.engine.impl.SaslFrameParser;

import  hunt.proton.engine.impl.AmqpHeader;

import hunt.io.ByteBuffer;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.security.SaslFrameBody;
import hunt.proton.codec.ByteBufferDecoder;
import hunt.proton.codec.DecodeException;
import hunt.proton.engine.TransportException;
import hunt.proton.engine.impl.SaslFrameHandler;
import hunt.proton.engine.impl.TransportImpl;
import hunt.proton.engine.impl.SaslImpl;
import hunt.proton.codec.DecodeException;
import hunt.proton.engine.impl.ProtocolTracer;
import hunt.io.BufferUtils;
import hunt.String;
import hunt.logging;

class SaslFrameParser
{
    private static string HEADER_DESCRIPTION = "SASL";

    private SaslFrameHandler _sasl;

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

    private State _state = State.HEADER0;
    private int _size;

    private ByteBuffer _buffer;

    private ByteBufferDecoder _decoder;
    private int _frameSizeLimit;
    private TransportImpl _transport;

    this(SaslFrameHandler sasl, ByteBufferDecoder decoder, int frameSizeLimit, TransportImpl transport)
    {
        _sasl = sasl;
        _decoder = decoder;
        _frameSizeLimit = frameSizeLimit;
        _transport = transport;
    }

    /**
     * Parse the provided SASL input and call my SASL frame handler with the result
     */
    public void input(ByteBuffer input)
    {
        TransportException frameParsingError = null;
        int size = _size;
        State state = _state;
        ByteBuffer oldIn = null;

        while(input.hasRemaining() && state != State.ERROR && !_sasl.isDone())
        {
            switch(state)
            {
                case State.HEADER0:
                    if(input.hasRemaining())
                    {
                        byte c = input.get();
                        if(c != AmqpHeader.SASL_HEADER[0])
                        {
                            frameParsingError = new TransportException("AMQP SASL header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }
                        state = State.HEADER1;
                    }
                    else
                    {
                        break;
                    }
                    goto case;
                case State.HEADER1:
                    if(input.hasRemaining())
                    {
                        byte c = input.get();
                        if(c != AmqpHeader.SASL_HEADER[1])
                        {
                            frameParsingError = new TransportException("AMQP SASL header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }
                        state = State.HEADER2;
                    }
                    else
                    {
                        break;
                    }
                    goto case;
                case State.HEADER2:
                    if(input.hasRemaining())
                    {
                        byte c = input.get();
                        if(c != AmqpHeader.SASL_HEADER[2])
                        {
                            frameParsingError = new TransportException("AMQP SASL header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }
                        state = State.HEADER3;
                    }
                    else
                    {
                        break;
                    }
                    goto case;
                case State.HEADER3:
                    if(input.hasRemaining())
                    {
                        byte c = input.get();
                        if(c != AmqpHeader.SASL_HEADER[3])
                        {
                            frameParsingError = new TransportException("AMQP SASL header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }
                        state = State.HEADER4;
                    }
                    else
                    {
                        break;
                    }
                    goto case;
                case State.HEADER4:
                    if(input.hasRemaining())
                    {
                        byte c = input.get();
                        if(c != AmqpHeader.SASL_HEADER[4])
                        {
                            frameParsingError = new TransportException("AMQP SASL header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }
                        state = State.HEADER5;
                    }
                    else
                    {
                        break;
                    }
                    goto case;
                case State.HEADER5:
                    if(input.hasRemaining())
                    {
                        byte c = input.get();
                        if(c != AmqpHeader.SASL_HEADER[5])
                        {
                            frameParsingError = new TransportException("AMQP SASL header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }
                        state = State.HEADER6;
                    }
                    else
                    {
                        break;
                    }
                    goto case;
                case State.HEADER6:
                    if(input.hasRemaining())
                    {
                        byte c = input.get();
                        if(c != AmqpHeader.SASL_HEADER[6])
                        {
                            frameParsingError = new TransportException("AMQP SASL header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }
                        state = State.HEADER7;
                    }
                    else
                    {
                        break;
                    }
                    goto case;
                case State.HEADER7:
                    if(input.hasRemaining())
                    {
                        byte c = input.get();
                        if(c != AmqpHeader.SASL_HEADER[7])
                        {
                            frameParsingError = new TransportException("AMQP SASL header mismatch value %x, expecting %x. In state: %s");
                            state = State.ERROR;
                            break;
                        }

                        logHeader();

                        state = State.SIZE_0;
                    }
                    else
                    {
                        break;
                    }
                    goto case;
                case State.SIZE_0:
                    if(!input.hasRemaining())
                    {
                        break;
                    }

                    if(input.remaining() >= 4)
                    {
                        size = input.getInt();
                        state = State.PRE_PARSE;
                        break;
                    }
                    else
                    {
                        size = (input.get() << 24) & 0xFF000000;
                        if(!input.hasRemaining())
                        {
                            state = State.SIZE_1;
                            break;
                        }
                    }
                    goto case;
                case State.SIZE_1:
                    size |= (input.get() << 16) & 0xFF0000;
                    if(!input.hasRemaining())
                    {
                        state = State.SIZE_2;
                        break;
                    }
                    goto case;
                case State.SIZE_2:
                    size |= (input.get() << 8) & 0xFF00;
                    if(!input.hasRemaining())
                    {
                        state = State.SIZE_3;
                        break;
                    }
                    goto case;
                case State.SIZE_3:
                    size |= input.get() & 0xFF;
                    state = State.PRE_PARSE;
                    goto case;
                case State.PRE_PARSE:
                    if(size < 8)
                    {
                        frameParsingError = new TransportException(
                                "specified frame size %d smaller than minimum SASL frame header size 8");
                        state = State.ERROR;
                        break;
                    }

                    if (size > _frameSizeLimit)
                    {
                        frameParsingError = new TransportException(
                                "specified frame size %d larger than maximum SASL frame size %d");
                        state = State.ERROR;
                        break;
                    }

                    if(input.remaining() < size-4)
                    {
                        _buffer = BufferUtils.allocate(size-4);
                        _buffer.put(input);
                        state = State.BUFFERING;
                        break;
                    }
                    goto case;
                case State.BUFFERING:
                    if(_buffer !is null)
                    {
                        if(input.remaining() < _buffer.remaining())
                        {
                            _buffer.put(input);
                            break;
                        }
                        else
                        {
                            ByteBuffer dup = input.duplicate();
                            dup.limit(dup.position()+_buffer.remaining());
                            input.position(input.position()+_buffer.remaining());
                            _buffer.put(dup);
                            oldIn = input;
                            _buffer.flip();
                            input = _buffer;
                            state = State.PARSING;
                        }
                    }
                    goto case;
                case State.PARSING:

                    int dataOffset = (input.get() << 2) & 0x3FF;

                    if(dataOffset < 8)
                    {
                        frameParsingError = new TransportException("specified frame data offset %d smaller than minimum frame header size %d");
                        state = State.ERROR;
                        break;
                    }
                    else if(dataOffset > size)
                    {
                        frameParsingError = new TransportException("specified frame data offset %d larger than the frame size %d");
                        state = State.ERROR;
                        break;
                    }

                    // type

                    int type = input.get() & 0xFF;
                    // SASL frame has no type-specific content in the frame header, so we skip next two bytes
                    input.get();
                    input.get();

                    if(type != SaslImpl.SASL_FRAME_TYPE)
                    {
                        frameParsingError = new TransportException("unknown frame type: %d");
                        state = State.ERROR;
                        break;
                    }

                    if(dataOffset!=8)
                    {
                        input.position(input.position()+dataOffset-8);
                    }

                    // oldIn null iff not working on duplicated buffer
                    if(oldIn is null)
                    {
                        oldIn = input;
                        input = input.duplicate();
                        int endPos = input.position() + size - dataOffset;
                        input.limit(endPos);
                        oldIn.position(endPos);

                    }

                    try
                    {
                     //   logInfo("vvvvvv %s",input.getRemaining());
                        _decoder.setByteBuffer(input);
                        Object val = _decoder.readObject();

                        Binary payload;

                        if(input.hasRemaining())
                        {
                            byte[] payloadBytes = new byte[input.remaining()];
                            input.get(payloadBytes);
                            payload = new Binary(payloadBytes);
                        }
                        else
                        {
                            payload = null;
                        }

                        SaslFrameBody frameBody = cast(SaslFrameBody)val;
                        if(val !is null)
                        {
                            _sasl.handle(frameBody, payload);

                            reset();
                            input = oldIn;
                            oldIn = null;
                            _buffer = null;
                            state = State.SIZE_0;
                        }
                        else
                        {
                            state = State.ERROR;
                            frameParsingError = new TransportException("Unexpected frame type encountered");
                        }
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

        _state = state;
        _size = size;

        if(_state == State.ERROR)
        {
            if(frameParsingError !is null)
            {
                throw frameParsingError;
            }
            else
            {
                throw new TransportException("Unable to parse, probably because of a previous error");
            }
        }
    }

    private void reset()
    {
        _size = 0;
        _state = State.SIZE_0;
    }

    private void logHeader()
    {
        if (_transport.isFrameTracingEnabled())
        {
            _transport.log(TransportImpl.INCOMING, new String(HEADER_DESCRIPTION));

            ProtocolTracer tracer = _transport.getProtocolTracer();
            if (tracer !is null)
            {
                tracer.receivedHeader(HEADER_DESCRIPTION);
            }
        }
    }
}
