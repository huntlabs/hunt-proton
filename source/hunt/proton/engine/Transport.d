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

module hunt.proton.engine.Transport;

import hunt.io.ByteBuffer;

import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.engine.impl.TransportImpl;
import hunt.proton.engine.Endpoint;
import hunt.proton.engine.Connection;
import hunt.proton.engine.TransportResult;
import hunt.proton.engine.Sasl;
import hunt.proton.engine.SslDomain;
import hunt.proton.engine.Ssl;
import hunt.proton.engine.SslPeerDetails;

/**
 * <p>
 * Operates on the entities in the associated {@link Connection}
 * by accepting and producing binary AMQP output, potentially
 * layered within SASL and/or SSL.
 * </p>
 * <p>
 * After a connection is bound with {@link #bind(Connection)}, the methods for accepting and producing
 * output are typically repeatedly called. See the specific methods for details of their legal usage.
 * </p>
 * <p>
 * <strong>Processing the input data received from another AMQP container.</strong>
 * </p>
 * <ol>
 * <li>{@link #getInputBuffer()} </li>
 * <li>Write data into input buffer</li>
 * <li>{@link #processInput()}</li>
 * <li>Check the result, e.g. by calling {@link TransportResult#checkIsOk()}</li>
 * </ol>
 * <p>
 * <strong>Getting the output data to send to another AMQP container:</strong>
 * </p>
 * <ol>
 * <li>{@link #getOutputBuffer()} </li>
 * <li>Read output from output buffer</li>
 * <li>{@link #outputConsumed()}</li>
 * </ol>
 *
 * <p>The following methods on the byte buffers returned by {@link #getInputBuffer()} and {@link #getOutputBuffer()}
 * must not be called:
 * </p>
 * <ol>
 * <li> {@link ByteBuffer#clear()} </li>
 * <li> {@link ByteBuffer#compact()} </li>
 * <li> {@link ByteBuffer#flip()} </li>
 * <li> {@link ByteBuffer#mark()} </li>
 * </ol>
 */
interface Transport : Endpoint
{

    class Factory
    {
        public static Transport create() {
            return new TransportImpl();
        }
    }

    public static  int TRACE_OFF = 0;
    public static  int TRACE_RAW = 1;
    public static  int TRACE_FRM = 2;
    public static  int TRACE_DRV = 4;

    public static  int DEFAULT_MAX_FRAME_SIZE = -1;

    /** the lower bound for the agreed maximum frame size (in bytes). */
    enum  int MIN_MAX_FRAME_SIZE = 512;
    enum int SESSION_WINDOW = 16*1024;
    enum int END_OF_STREAM = -1;

    public void trace(int levels);

    public void bind(Connection connection);
    public void unbind();

    public int capacity();
    public ByteBuffer tail();
    public void process() ;
    public void close_tail();


    public int pending();
    public ByteBuffer head();
    public void pop(int bytes);
    public void close_head();

    public bool isClosed();

    /**
     * Processes the provided input.
     *
     * @param bytes input bytes for consumption
     * @param offset the offset within bytes where input begins
     * @param size the number of bytes available for input
     *
     * @return the number of bytes consumed
     * @throws TransportException if the input is invalid, if the transport is already in an error state,
     * or if the input is empty (unless the remote connection is already closed)
     * @deprecated use {@link #getInputBuffer()} and {@link #processInput()} instead.
     */
    public int input(byte[] bytes, int offset, int size);

    /**
     * Get a buffer that can be used to write input data into the transport.
     * Once the client has finished putting into the input buffer, {@link #processInput()}
     * must be called.
     *
     * Successive calls to this method are not guaranteed to return the same object.
     * Once {@link #processInput()} is called the buffer must not be used.
     *
     * @throws TransportException if the transport is already in an invalid state
     */
    ByteBuffer getInputBuffer();

    /**
     * Tell the transport to process the data written to the input buffer.
     *
     * If the returned result indicates failure, the transport will not accept any more input.
     * Specifically, any subsequent {@link #processInput()} calls on this object will
     * throw an exception.
     *
     * @return the result of processing the data, which indicates success or failure.
     * @see #getInputBuffer()
     */
    TransportResult processInput();

    /**
     * Has the transport produce up to size bytes placing the result
     * into dest beginning at position offset.
     *
     * @param dest array for output bytes
     * @param offset the offset within bytes where output begins
     * @param size the maximum number of bytes to be output
     *
     * @return the number of bytes written
     * @deprecated use {@link #getOutputBuffer()} and {@link #outputConsumed()} instead
     */
    public int output(byte[] dest, int offset, int size);

    /**
     * Get a read-only byte buffer containing the transport's pending output.
     * Once the client has finished getting from the output buffer, {@link #outputConsumed()}
     * must be called.
     *
     * Successive calls to this method are not guaranteed to return the same object.
     * Once {@link #outputConsumed()} is called the buffer must not be used.
     *
     * If the transport's state changes AFTER calling this method, this will not be
     * reflected in the output buffer.
     */
    ByteBuffer getOutputBuffer();

    /**
     * Informs the transport that the output buffer returned by {@link #getOutputBuffer()}
     * is finished with, allowing implementation-dependent steps to be performed such as
     * reclaiming buffer space.
     */
    void outputConsumed();

    /**
     * Signal the transport to expect SASL frames used to establish a SASL layer prior to
     * performing the AMQP protocol version negotiation. This must first be performed before
     * the transport is used for processing. Subsequent invocations will return the same
     * {@link Sasl} object.
     *
     * @throws IllegalStateException if transport processing has already begun prior to initial invocation
     */
    Sasl sasl() ;

    /**
     * Wrap this transport's output and input to apply SSL encryption and decryption respectively.
     *
     * This method is expected to be called at most once. A subsequent invocation will return the same
     * {@link Ssl} object, regardless of the parameters supplied.
     *
     * @param sslDomain the SSL settings to use
     * @param sslPeerDetails peer details, used for SNI, hostname verification, etc when connecting. May be null.
     * @return an {@link Ssl} object representing the SSL session.
     * @throws IllegalArgumentException if the sslDomain requests hostname verification but sslPeerDetails are null.
     * @throws IllegalStateException if the sslDomain has not been initialised.
     */
    Ssl ssl(SslDomain sslDomain, SslPeerDetails sslPeerDetails);

    /**
     * Equivalent to {@link #ssl(SslDomain, SslPeerDetails)} but passing null for SslPeerDetails, meaning no SNI detail
     * is sent, hostname verification isn't supported etc when connecting.
     *
     * @throws IllegalArgumentException if the sslDomain requests hostname verification.
     * @throws IllegalStateException if the sslDomain has not been initialised.
     */
    Ssl ssl(SslDomain sslDomain) ;


    /**
     * Get the maximum frame size for the transport
     *
     * @return the maximum frame size
     */
    int getMaxFrameSize();

    void setMaxFrameSize(int size);

    int getRemoteMaxFrameSize();

    /**
     * Allows overriding the initial remote-max-frame-size to a value greater than the default 512bytes. The value set
     * will be used until such time as the Open frame arrives from the peer and populates the remote max frame size.
     *
     * This method must be called before before {@link #sasl()} in order to influence SASL behaviour.
     * @param size the remote frame size to use
     */
    void setInitialRemoteMaxFrameSize(int size);

    /**
     * Gets the local channel-max value to be advertised to the remote peer
     *
     * @return the local channel-max value
     * @see #setChannelMax(int)
     */
    int getChannelMax();

    /**
     * Set the local value of channel-max, to be advertised to the peer on the
     * <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-transport-v1.0-os.html#type-open">
     * Open frame</a> emitted by the transport.
     *
     * The remote peers advertised channel-max can be observed using {@link #getRemoteChannelMax()}.
     *
     * @param channelMax the local channel-max to advertise to the peer, in range [0 - 2^16).
     * @throws IllegalArgumentException if the value supplied is outside range [0 - 2^16).
     */
    void setChannelMax(int channelMax);

    /**
     * Gets the remote value of channel-max, as advertised by the peer on its
     * <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-transport-v1.0-os.html#type-open">
     * Open frame</a>.
     *
     * The local peers advertised channel-max can be observed using {@link #getChannelMax()}.
     *
     * @return the remote channel-max value
     */
    int getRemoteChannelMax();

    ErrorCondition getCondition();

    /**
     *
     * @param timeout local idle timeout in milliseconds
     */
    void setIdleTimeout(int timeout);
    /**
     *
     * @return local idle timeout in milliseconds
     */
    int getIdleTimeout();
    /**
     *
     * @return remote idle timeout in milliseconds
     */
    int getRemoteIdleTimeout();

    /**
     * Prompt the transport to perform work such as idle-timeout/heartbeat handling, and return an
     * absolute deadline in milliseconds that tick must again be called by/at, based on the provided
     * current time in milliseconds, to ensure the periodic work is carried out as necessary.
     *
     * A returned deadline of 0 indicates there is no periodic work necessitating tick be called, e.g.
     * because neither peer has defined an idle-timeout value.
     *
     * The provided milliseconds time values can be from {@link System#currentTimeMillis()} or derived
     * from {@link System#nanoTime()}, noting that for the later in particular that the returned
     * deadline could be a different sign than the given time, and (if non-zero) the returned
     * deadline should have the current time originally provided subtracted from it in order to
     * establish a relative time delay to the next deadline.
     *
     * @param nowMillis the current time in milliseconds
     * @return the absolute deadline in milliseconds to next call tick by/at, or 0 if there is none.
     */
    long tick(long nowMillis);

    long getFramesInput();

    long getFramesOutput();

    /**
     * Configure whether a synthetic Flow event should be emitted when messages are sent,
     * reflecting a change in the credit level on the link that may prompt other action.
     *
     * Defaults to true.
     *
     * @param emitFlowEventOnSend true if a flow event should be emitted, false otherwise
     */
    void setEmitFlowEventOnSend(bool emitFlowEventOnSend);

    bool isEmitFlowEventOnSend();

    /**
     * Set an upper limit on the size of outgoing frames that will be sent
     * to the peer. Allows constraining the transport not to emit Transfer
     * frames over a given size even when the peers max frame size allows it.
     *
     * Must be set before receiving the peers Open frame to have effect.
     *
     * @param size the size limit to apply
     */
    void setOutboundFrameSizeLimit(int size);

    int getOutboundFrameSizeLimit();
}
