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

module hunt.proton.engine.impl.FrameWriter;

import hunt.collection.ByteBuffer;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.security.SaslFrameBody;
import hunt.proton.amqp.transport.EmptyFrame;
import hunt.proton.amqp.transport.FrameBody;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.framing.TransportFrame;
import hunt.proton.engine.impl.TransportImpl;
import hunt.proton.engine.impl.FrameWriterBuffer;
import hunt.util.Common;
import std.algorithm;
import hunt.proton.engine.impl.ProtocolTracer;
import  hunt.proton.amqp.transport.Begin;
import  hunt.proton.amqp.transport.Open;
import  hunt.proton.amqp.transport.Attach;
import  hunt.proton.amqp.transport.Transfer;
import hunt.logging;
/**
 * Writes Frames to an internal buffer for later processing by the transport.
 */
class FrameWriter {

    static int DEFAULT_FRAME_BUFFER_FULL_MARK = 64 * 1024;
    static int FRAME_HEADER_SIZE = 8;

    static byte AMQP_FRAME_TYPE = 0;
    static byte SASL_FRAME_TYPE = 1;

    private TransportImpl transport;
    private EncoderImpl encoder;
    private FrameWriterBuffer frameBuffer ;//= new FrameWriterBuffer();

    // Configuration of this Frame Writer
    private int maxFrameSize;
    private byte frameType;
    private int frameBufferMaxBytes; //= DEFAULT_FRAME_BUFFER_FULL_MARK;

    // State of current write operation, reset on start of each new write
    private int frameStart;

    // Frame Writer metrics
    private long framesOutput;

    this(EncoderImpl encoder, int maxFrameSize, byte frameType, TransportImpl transport) {
        this.encoder = encoder;
        this.maxFrameSize = maxFrameSize;
        this.frameType = frameType;
        this.transport = transport;
        this.frameBufferMaxBytes = DEFAULT_FRAME_BUFFER_FULL_MARK;
        this.frameBuffer = new FrameWriterBuffer();
        encoder.setByteBuffer(frameBuffer);
    }

    bool isFull() {
        return frameBuffer.position() > frameBufferMaxBytes;
    }

    int readBytes(ByteBuffer dst) {
        return frameBuffer.transferTo(dst);
    }

    long getFramesOutput() {
        return framesOutput;
    }

    void setMaxFrameSize(int maxFrameSize) {
        this.maxFrameSize = maxFrameSize;
    }

    void setFrameWriterMaxBytes(int maxBytes) {
        this.frameBufferMaxBytes = maxBytes;
    }

    int getFrameWriterMaxBytes() {
        return frameBufferMaxBytes;
    }

    void writeHeader(byte[] header) {
        frameBuffer.put(header, 0, cast(int)header.length);
    }

    void writeFrame(Object frameBody) {
        writeFrame(0, frameBody, null, null);
    }

    void writeFrame(int channel, Object frameBody, ReadableBuffer payload, Runnable onPayloadTooLarge) {
        frameStart = frameBuffer.position();

        if (cast(Begin)frameBody !is null)
        {
            logInfo(".");
        }

        int performativeSize = writePerformative(frameBody, payload, onPayloadTooLarge);
        if (cast(Begin)frameBody !is null)
        {
          version(HUNT_AMQP_DEBUG)   logInfof("begin size: %d", performativeSize);
        }
        if (cast(Open)frameBody !is null)
        {
          version(HUNT_AMQP_DEBUG)  logInfof("Open size: %d", performativeSize);
        }


        if (cast(Open)frameBody !is null)
        {
          version(HUNT_AMQP_DEBUG) logInfof("Open size: %d", performativeSize);
        }
        if (cast(Attach)frameBody !is null)
        {
            Attach at = cast(Attach)frameBody;
            version(HUNT_AMQP_DEBUG)  logInfof ("%s", at.toString);
        }

        int capacity = maxFrameSize > 0 ? maxFrameSize - performativeSize : 2147483647;
        int payloadSize = min(payload is null ? 0 : payload.remaining(), capacity);

        if (cast(Transfer)frameBody !is null)
        {
            version(HUNT_AMQP_DEBUG)  logInfo("Transfer size: %d ---%d ----%d", performativeSize, capacity , payloadSize);
        }

        if (transport.isFrameTracingEnabled()) {
            logFrame(channel, frameBody, payload, payloadSize);
        }

        if (payloadSize > 0) {
            int oldLimit = payload.limit();
            payload.limit(payload.position() + payloadSize);
            frameBuffer.put(payload);
            payload.limit(oldLimit);
        }

        endFrame(channel);

        framesOutput++;
    }

    private int writePerformative(Object frameBody, ReadableBuffer payload, Runnable onPayloadTooLarge) {
        frameBuffer.position(frameStart + FRAME_HEADER_SIZE);

        if (frameBody !is null) {
            encoder.writeObject(frameBody);
        }

        int performativeSize = frameBuffer.position() - frameStart;

        if (onPayloadTooLarge !is null && maxFrameSize > 0 && payload !is null && (payload.remaining() + performativeSize) > maxFrameSize) {
            // Next iteration will re-encode the frame body again with updates from the <payload-to-large>
            // handler and then we can move onto the body portion.
            onPayloadTooLarge.run();
            performativeSize = writePerformative(frameBody, payload, null);
        }

        return performativeSize;
    }

    private void endFrame(int channel) {
        int frameSize = frameBuffer.position() - frameStart;
        int originalPosition = frameBuffer.position();

        frameBuffer.position(frameStart);
        frameBuffer.putInt(frameSize);
        frameBuffer.put(cast(byte) 2);
        frameBuffer.put(frameType);
        frameBuffer.putShort(cast(short) channel);
        frameBuffer.position(originalPosition);
    }

    private void logFrame(int channel, Object frameBody, ReadableBuffer payload, int payloadSize) {
        ProtocolTracer tracer = transport.getProtocolTracer();
        if (frameType == AMQP_FRAME_TYPE) {
            ReadableBuffer originalPayload = null;
            if (payload !is null) {
                originalPayload = payload.slice();
                originalPayload.limit(payloadSize);
            }

            Binary payloadBin = Binary.create(originalPayload);
            FrameBody bd = null;
            if (frameBody is null) {
                bd = EmptyFrame.INSTANCE;
            } else {
                bd = cast(FrameBody) frameBody;
            }

            TransportFrame frame = new TransportFrame(channel, bd, payloadBin);

            transport.log(TransportImpl.OUTGOING, frame);

            if (tracer !is null) {
                tracer.sentFrame(frame);
            }
        } else {
            SaslFrameBody bd = cast(SaslFrameBody) frameBody;
            transport.log(TransportImpl.OUTGOING, bd);
            if (tracer !is null) {
                tracer.sentSaslBody(bd);
            }
        }
    }
}
