/*
 * hunt-proton: AMQP Protocol library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module hunt.proton.engine.impl.TransportImpl;

import hunt.logging;
import std.conv:to;
import hunt.proton.engine.impl.ByteBufferUtils;
import hunt.Boolean;
import hunt.collection.ByteBuffer;
import hunt.collection.ArrayList;
import hunt.collection.HashMap;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.LinkedHashMap;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedShort;
import hunt.proton.amqp.security.SaslFrameBody;
import hunt.proton.amqp.transport.Attach;
import hunt.proton.amqp.transport.Begin;
import hunt.proton.amqp.transport.Close;
import hunt.proton.amqp.transport.ConnectionError;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.amqp.transport.Detach;
import hunt.proton.amqp.transport.Disposition;
import hunt.proton.amqp.transport.End;
import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.amqp.transport.Flow;
import hunt.proton.amqp.transport.FrameBody;
import hunt.proton.amqp.transport.Open;
import hunt.proton.amqp.transport.Role;
import hunt.proton.amqp.transport.Transfer;
import hunt.proton.codec.AMQPDefinedTypes;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.engine.Connection;
import hunt.proton.engine.EndpointState;
import hunt.proton.engine.Event;
import hunt.proton.engine.ProtonJTransport;
import hunt.proton.engine.Sasl;
import hunt.proton.engine.Ssl;
import hunt.proton.engine.SslDomain;
import hunt.proton.engine.SslPeerDetails;
import hunt.proton.engine.TransportException;
import hunt.proton.engine.TransportResult;
import hunt.proton.engine.TransportResultFactory;
import hunt.proton.engine.impl.ssl.SslImpl;
import hunt.proton.framing.TransportFrame;
import hunt.proton.engine.Reactor;
import hunt.proton.engine.Selectable;
import hunt.proton.engine.impl.EndpointImpl;
import hunt.proton.engine.impl.FrameHandler;
import hunt.proton.engine.impl.TransportOutputWriter;
import hunt.proton.engine.impl.TransportInternal;
import hunt.Integer;
import hunt.proton.engine.impl.FrameParser;
import hunt.proton.engine.impl.ConnectionImpl;
import hunt.proton.engine.impl.TransportSession;
import hunt.proton.engine.impl.TransportInput;
import hunt.proton.engine.impl.TransportOutput;
import hunt.proton.engine.impl.FrameWriter;
import hunt.proton.engine.impl.SaslImpl;
import hunt.proton.engine.impl.Ref;
import hunt.proton.engine.impl.ProtocolTracer;
import hunt.proton.engine.Transport;
import hunt.proton.engine.impl.TransportLayer;
import hunt.proton.engine.impl.TransportWrapper;
import hunt.Exceptions;
import hunt.proton.engine.impl.LinkImpl;
import hunt.proton.engine.impl.TransportLink;
import hunt.proton.engine.impl.SessionImpl;
import hunt.proton.engine.impl.SenderImpl;
import hunt.proton.engine.impl.TransportSender;
import hunt.proton.engine.impl.DeliveryImpl;
import hunt.proton.engine.impl.TransportDelivery;
import hunt.Boolean;
import hunt.util.Common;
import hunt.proton.engine.impl.ReceiverImpl;
import hunt.proton.engine.impl.AmqpHeader;
import hunt.proton.engine.Event;
import hunt.proton.engine.impl.TransportOutputAdaptor;
import hunt.String;
import std.algorithm;
import hunt.proton.amqp.transport.Attach;
import hunt.proton.amqp.transport.Open;
import hunt.proton.amqp.transport.Begin;
import hunt.proton.amqp.transport.Detach;
import hunt.proton.amqp.transport.Close;
import hunt.proton.amqp.transport.Flow;
import hunt.proton.amqp.transport.End;
import hunt.proton.amqp.transport.Transfer;
import hunt.proton.amqp.transport.EmptyFrame;
import hunt.proton.amqp.transport.Disposition;
import hunt.Exceptions;

class TransportImpl : EndpointImpl, ProtonJTransport, FrameBodyHandler!int,
        FrameHandler, TransportOutputWriter, TransportInternal
{
   // static int BUFFER_RELEASE_THRESHOLD = Integer.getInteger("proton.transport_buffer_release_threshold", 2 * 1024 * 1024);
    private static int CHANNEL_MAX_LIMIT = 65535;
    static int BUFFER_RELEASE_THRESHOLD = 2 * 1024 * 1024;
    //private static boolean getBooleanEnv(String name)
    //{
    //    String value = System.getenv(name);
    //    return "true".equalsIgnoreCase(value) ||
    //        "1".equals(value) ||
    //        "yes".equalsIgnoreCase(value);
    //}

    private static bool FRM_ENABLED = false;
    //private static boolean FRM_ENABLED = getBooleanEnv("PN_TRACE_FRM");
    private static int TRACE_FRAME_PAYLOAD_LENGTH = 1024;
   // private static int TRACE_FRAME_PAYLOAD_LENGTH = Integer.getInteger("proton.trace_frame_payload_length", 1024);
    private static string HEADER_DESCRIPTION = "AMQP";

    // trace levels
    private int _levels = 0;

    private FrameParser _frameParser;

    private ConnectionImpl _connectionEndpoint;

    private bool _isOpenSent;
    private bool _isCloseSent;

    private bool _headerWritten;
    private Map!(int, TransportSession) _remoteSessions ;//= new HashMap<Integer, TransportSession>();
    private Map!(int, TransportSession) _localSessions ; //= new HashMap<Integer, TransportSession>();

    private TransportInput _inputProcessor;
    private TransportOutput _outputProcessor;

    private DecoderImpl _decoder ;//= new DecoderImpl();
    private EncoderImpl _encoder ;//= new EncoderImpl(_decoder);

    private int _maxFrameSize  ;//= Transport.DEFAULT_MAX_FRAME_SIZE;
    private int _remoteMaxFrameSize ;// = Transport.MIN_MAX_FRAME_SIZE;
    private int _outboundFrameSizeLimit = 0;
    private int _channelMax      ;// = CHANNEL_MAX_LIMIT;
    private int _remoteChannelMax ;// = CHANNEL_MAX_LIMIT;

    private FrameWriter _frameWriter;

    private bool _closeReceived;
    private Open _open;
    private SaslImpl _sasl;
    //private SslImpl _ssl;
    private Ref!ProtocolTracer _protocolTracer ;//= new Ref<>(null);

    private TransportResult _lastTransportResult ;//= TransportResultFactory.ok();

    private bool _init;
    private bool _processingStarted;
    private bool _emitFlowEventOnSend = true;
    private bool _useReadOnlyOutputBuffer = true;

    private FrameHandler _frameHandler ;//= this;
    private bool _head_closed = false;
    private bool _conditionSet;

    private bool postedHeadClosed = false;
    private bool postedTailClosed = false;
    private bool postedTransportError = false;

    private int _localIdleTimeout = 0;
    private int _remoteIdleTimeout = 0;
    private long _bytesInput = 0;
    private long _bytesOutput = 0;
    private long _localIdleDeadline = 0;
    private long _lastBytesInput = 0;
    private long _lastBytesOutput = 0;
    private long _remoteIdleDeadline = 0;

    private Selectable _selectable;
    private Reactor _reactor;

    private List!TransportLayer _additionalTransportLayers;

    // Cached instances used to carry the Performatives to the frame writer without the need to create
    // a new instance on each operation that triggers a write
    private Disposition cachedDisposition ;//= new Disposition();
    private Flow cachedFlow  ;//= new Flow();
    private Transfer cachedTransfer ;//= new Transfer();

    /**
     * Application code should use {@link hunt.proton.engine.Transport.Factory#create()} instead
     */
    this()
    {
        this(Transport.DEFAULT_MAX_FRAME_SIZE);
    }

    /**
     * Creates a transport with the given maximum frame size.
     * Note that the maximumFrameSize also determines the size of the output buffer.
     */
    this(int maxFrameSize)
    {
        _decoder = new DecoderImpl;
        _encoder = new EncoderImpl(_decoder);
        _remoteSessions = new LinkedHashMap!(int, TransportSession);
        _localSessions = new LinkedHashMap!(int, TransportSession);
        _protocolTracer = new Ref!ProtocolTracer(null);
        _lastTransportResult = TransportResultFactory.ok();
        cachedTransfer = new Transfer();
        cachedFlow = new Flow();
        cachedDisposition = new Disposition();
        _remoteMaxFrameSize = Transport.MIN_MAX_FRAME_SIZE;
        _maxFrameSize = Transport.DEFAULT_MAX_FRAME_SIZE;
        _channelMax       = CHANNEL_MAX_LIMIT;
        _remoteChannelMax  = CHANNEL_MAX_LIMIT;
        AMQPDefinedTypes.registerAllTypes(_decoder, _encoder);

        _maxFrameSize = maxFrameSize;
        _frameWriter = new FrameWriter(_encoder, _remoteMaxFrameSize,
                                       FrameWriter.AMQP_FRAME_TYPE,
                                       this);
        _frameHandler = this;
    }

    private void init()
    {
        if(!_init)
        {
            _init = true;
            _frameParser = new FrameParser(_frameHandler , _decoder, _maxFrameSize, this);
            _inputProcessor = _frameParser;
            _outputProcessor = new TransportOutputAdaptor(this, _maxFrameSize, isUseReadOnlyOutputBuffer());
        }
    }

    public void trace(int levels) {
        _levels = levels;
    }

    public int getMaxFrameSize()
    {
        return _maxFrameSize;
    }

    public int getRemoteMaxFrameSize()
    {
        return _remoteMaxFrameSize;
    }

    public void setInitialRemoteMaxFrameSize(int remoteMaxFrameSize)
    {
        if(_init)
        {
            throw new IllegalStateException("Cannot set initial remote max frame size after transport has been initialised");
        }

        _remoteMaxFrameSize = remoteMaxFrameSize;
    }

    public void setMaxFrameSize(int maxFrameSize)
    {
        if(_init)
        {
            throw new IllegalStateException("Cannot set max frame size after transport has been initialised");
        }
        _maxFrameSize = maxFrameSize;
    }

    public int getChannelMax()
    {
        return _channelMax;
    }

    public void setChannelMax(int channelMax)
    {
        if(_isOpenSent)
        {
          throw new IllegalArgumentException("Cannot change channel max after open frame has been sent");
        }

        if(channelMax < 0 || channelMax >= (1<<16))
        {
            throw new NumberFormatException("Value \"" ~ to!string(channelMax) ~"\" lies outside the range [0-" ~ to!string((1<<16) )~").");
        }

        _channelMax = channelMax;
    }

    override
    public int getRemoteChannelMax()
    {
        return _remoteChannelMax;
    }

    override
    public ErrorCondition getCondition()
    {
        // Get the ErrorCondition, but only return it if its condition field is populated.
        // This somewhat retains prior TransportImpl behaviour of returning null when no
        // condition had been set (by TransportImpl itself) rather than the 'empty' ErrorCondition
        // object historically used in the other areas.
        ErrorCondition errorCondition = super.getCondition();
        return errorCondition.getCondition() !is null ? errorCondition : null;
    }

    override
    public void setCondition(ErrorCondition error)
    {
        super.setCondition(error);
        _conditionSet = error !is null && error.getCondition() !is null;
    }

    override
    public void bind(Connection conn)
    {
        // TODO - check if already bound

        _connectionEndpoint = cast(ConnectionImpl) conn;
        put(Type.CONNECTION_BOUND, cast(Object)conn);
        _connectionEndpoint.setTransport(this);
        _connectionEndpoint.incref();

        if(getRemoteState() != EndpointState.UNINITIALIZED)
        {
            _connectionEndpoint.handleOpen(_open);
            if(getRemoteState() == EndpointState.CLOSED)
            {
                _connectionEndpoint.setRemoteState(EndpointState.CLOSED);
            }

            _frameParser.flush();
        }
    }


    FrameBody copy()
    {
        implementationMissing(false);
        return null;
    }

    override
    public void unbind()
    {
        foreach (TransportSession ts ;_localSessions.values()) {
            ts.unbind();
        }
        foreach (TransportSession ts ;_remoteSessions.values()) {
            ts.unbind();
        }

        put(Type.CONNECTION_UNBOUND, _connectionEndpoint);

        _connectionEndpoint.modifyEndpoints();
        _connectionEndpoint.setTransport(null);
        _connectionEndpoint.decref();
    }

    override
    public int input(byte[] bytes, int offset, int length)
    {
        oldApiCheckStateBeforeInput(length).checkIsOk();

        ByteBuffer inputBuffer = getInputBuffer();
        int numberOfBytesConsumed = ByteBufferUtils.pourArrayToBuffer(bytes, offset, length, inputBuffer);
        processInput().checkIsOk();
        return numberOfBytesConsumed;
    }

    /**
     * This method is public as it is used by Python layer.
     * @see hunt.proton.engine.Transport#input(byte[], int, int)
     */
    public TransportResult oldApiCheckStateBeforeInput(int inputLength)
    {
        _lastTransportResult.checkIsOk();
        if(inputLength == 0)
        {
            if(_connectionEndpoint is null || _connectionEndpoint.getRemoteState() != EndpointState.CLOSED)
            {
                return TransportResultFactory.error(new TransportException("Unexpected EOS when remote connection not closed: connection aborted"));
            }
        }
        return TransportResultFactory.ok();
    }

    //==================================================================================================================
    // Process model state to generate output

    override
    public int output(byte[] bytes, int offset, int size)
    {
        ByteBuffer outputBuffer = getOutputBuffer();
        int numberOfBytesOutput = ByteBufferUtils.pourBufferToArray(outputBuffer, bytes, offset, size);
        outputConsumed();
        return numberOfBytesOutput;
    }

    override
    public bool writeInto(ByteBuffer outputBuffer)
    {
        processHeader();
        processOpen();
        processBegin();
        processAttach();
        processReceiverFlow();
        // we process transport work twice intentionally, the first
        // pass may end up settling deliveries that the second pass
        // can clean up
        processTransportWork();
        processTransportWork();
        processSenderFlow();
        processDetach();
        processEnd();
        processClose();

        _frameWriter.readBytes(outputBuffer);

        return _isCloseSent || _head_closed;
    }

    override
    public Sasl sasl()
    {
        if(_sasl is null)
        {
            if(_processingStarted)
            {
                throw new IllegalStateException("Sasl can't be initiated after transport has started processing");
            }

            init();
            _sasl = new SaslImpl(this, _remoteMaxFrameSize);
            TransportWrapper transportWrapper = _sasl.wrap(_inputProcessor, _outputProcessor);
            _inputProcessor = transportWrapper;
            _outputProcessor = transportWrapper;
        }
        return _sasl;

    }

    /**
     * {@inheritDoc}
     *
     * <p>Note that sslDomain must implement {@link hunt.proton.engine.impl.ssl.ProtonSslEngineProvider}.
     * This is not possible enforce at the API level because {@link hunt.proton.engine.impl.ssl.ProtonSslEngineProvider} is not part of the
     * public Proton API.</p>
     */
    override
    public Ssl ssl(SslDomain sslDomain, SslPeerDetails sslPeerDetails)
    {
        implementationMissing(false);
        return null;
        //if (_ssl is null)
        //{
        //    init();
        //    _ssl = new SslImpl(sslDomain, sslPeerDetails);
        //    TransportWrapper transportWrapper = _ssl.wrap(_inputProcessor, _outputProcessor);
        //    _inputProcessor = transportWrapper;
        //    _outputProcessor = transportWrapper;
        //}
        //return _ssl;
    }

    override
    public Ssl ssl(SslDomain sslDomain)
    {
        return ssl(sslDomain, null);
    }

    private void processDetach()
    {
       // logInfo("processDetach out -------------------------------------");
        if(_connectionEndpoint !is null && _isOpenSent)
        {
            EndpointImpl endpoint = _connectionEndpoint.getTransportHead();
            while(endpoint !is null)
            {
                LinkImpl link = cast(LinkImpl)endpoint;
                if(link !is null)
                {
                    TransportLink  transportLink = getTransportState(link);
                    SessionImpl session = link.getSession();
                    TransportSession transportSession = getTransportState(session);
                   // logInfo("processDetach in -------------------------------------");
                    if(((link.getLocalState() == EndpointState.CLOSED) || link.detached())
                       && transportLink.isLocalHandleSet()
                       && transportSession.isLocalChannelSet()
                       && !_isCloseSent)
                    {
                        if((cast(SenderImpl)link !is null)
                           && link.getQueued() > 0
                           && !transportLink.detachReceived()
                           && !transportSession.endReceived()
                           && !_closeReceived) {
                            endpoint = endpoint.transportNext();
                            continue;
                        }

                        UnsignedInteger localHandle = transportLink.getLocalHandle();
                        transportLink.clearLocalHandle();
                        transportSession.freeLocalHandle(localHandle);

                        Detach detach = new Detach();
                        detach.setHandle(localHandle);
                        detach.setClosed(new Boolean(!link.detached()));

                        ErrorCondition localError = link.getCondition();
                        if( localError.getCondition() !is null )
                        {
                            detach.setError(localError);
                        }

                        writeFrame(transportSession.getLocalChannel(), detach, null, null);
                    }

                    endpoint.clearModified();

                }
                endpoint = endpoint.transportNext();
            }
        }
    }

    private void writeFlow(TransportSession ssn, TransportLink link)
    {
        cachedFlow.setNextIncomingId(ssn.getNextIncomingId());
        cachedFlow.setNextOutgoingId(ssn.getNextOutgoingId());
        ssn.updateIncomingWindow();
        cachedFlow.setIncomingWindow(ssn.getIncomingWindowSize());
        cachedFlow.setOutgoingWindow(ssn.getOutgoingWindowSize());
        cachedFlow.setProperties(null);
        if (link !is null) {
            cachedFlow.setHandle(link.getLocalHandle());
            cachedFlow.setDeliveryCount(link.getDeliveryCount());
            cachedFlow.setLinkCredit(link.getLinkCredit());
            cachedFlow.setDrain(new Boolean((cast(LinkImpl)link.getLink()).getDrain()));
        } else {
            cachedFlow.setHandle(null);
            cachedFlow.setDeliveryCount(null);
            cachedFlow.setLinkCredit(null);
            cachedFlow.setDrain(Boolean.FALSE);
        }
        writeFrame(ssn.getLocalChannel(), cachedFlow, null, null);
    }

    private void processSenderFlow()
    {
        if(_connectionEndpoint !is null && _isOpenSent && !_isCloseSent)
        {
            EndpointImpl endpoint = _connectionEndpoint.getTransportHead();
            while(endpoint !is null)
            {
                 SenderImpl sender = cast(SenderImpl) endpoint;
                if(sender !is null)
                {
                    if(sender.getDrain() && sender.getDrained() > 0)
                    {
                        TransportSender transportLink = sender.getTransportLink();
                        TransportSession transportSession = sender.getSession().getTransportSession();
                        UnsignedInteger credits = transportLink.getLinkCredit();
                        transportLink.setLinkCredit(UnsignedInteger.ZERO);
                        transportLink.setDeliveryCount(transportLink.getDeliveryCount().add(credits));
                        sender.setDrained(0);

                        writeFlow(transportSession, transportLink);
                    }
                }

                endpoint = endpoint.transportNext();
            }
        }
    }

    private void processTransportWork()
    {
        if(_connectionEndpoint !is null && _isOpenSent && !_isCloseSent)
        {
            DeliveryImpl delivery = _connectionEndpoint.getTransportWorkHead();
            while(delivery !is null)
            {
                LinkImpl link = delivery.getLink();
                if (cast(SenderImpl)link !is null) {
                    if (processTransportWorkSender(delivery, cast(SenderImpl) link)) {
                        delivery = delivery.clearTransportWork();
                    } else {
                        delivery = delivery.getTransportWorkNext();
                    }
                } else {
                    if (processTransportWorkReceiver(delivery, cast(ReceiverImpl) link)) {
                        delivery = delivery.clearTransportWork();
                    } else {
                        delivery = delivery.getTransportWorkNext();
                    }
                }
            }
        }
    }

    private bool processTransportWorkSender(DeliveryImpl delivery,
                                               SenderImpl snd)
    {
        TransportSender tpLink = snd.getTransportLink();
        SessionImpl session = snd.getSession();
        TransportSession tpSession = session.getTransportSession();

        bool wasDone = delivery.isDone();

        if(!delivery.isDone() &&
           (delivery.getDataLength() > 0 || delivery != snd.current()) &&
           tpSession.hasOutgoingCredit() && tpLink.hasCredit() &&
           tpSession.isLocalChannelSet() &&
           tpLink.getLocalHandle() !is null && !_frameWriter.isFull())
        {
            DeliveryImpl inProgress = tpLink.getInProgressDelivery();
            if(inProgress !is null){
                // There is an existing Delivery awaiting completion. Check it
                // is the same Delivery object given and return if not, as we
                // can't interleave Transfer frames for deliveries on a link.
                if(inProgress != delivery) {
                    return false;
                }
            }

            TransportDelivery tpDelivery = delivery.getTransportDelivery();
            UnsignedInteger deliveryId;
            if (tpDelivery !is null) {
                deliveryId = tpDelivery.getDeliveryId();
            } else {
                deliveryId = tpSession.getOutgoingDeliveryId();
                tpSession.incrementOutgoingDeliveryId();
            }
            tpDelivery = new TransportDelivery(deliveryId, delivery, tpLink);
            delivery.setTransportDelivery(tpDelivery);

            cachedTransfer.setDeliveryId(deliveryId);
            cachedTransfer.setDeliveryTag(new Binary(delivery.getTag()));
            cachedTransfer.setHandle(tpLink.getLocalHandle());
            cachedTransfer.setRcvSettleMode(null);
            cachedTransfer.setResume(Boolean.FALSE); // Ensure default is written
            cachedTransfer.setAborted(Boolean.FALSE); // Ensure default is written
            cachedTransfer.setBatchable(Boolean.FALSE); // Ensure default is written

            if(delivery.getLocalState() !is null)
            {
                cachedTransfer.setState(delivery.getLocalState());
            }
            else
            {
                cachedTransfer.setState(null);
            }

            if(delivery.isSettled())
            {
                cachedTransfer.setSettled(Boolean.TRUE);
            }
            else
            {
                cachedTransfer.setSettled(Boolean.FALSE);
                tpSession.addUnsettledOutgoing(deliveryId, delivery);
            }

            if(snd.current() == delivery)
            {
                cachedTransfer.setMore(Boolean.TRUE);
            }
            else
            {
                // Partial transfers will reset this as needed to true in the FrameWriter
                cachedTransfer.setMore(Boolean.FALSE);
            }

            int messageFormat = delivery.getMessageFormat();
            if(messageFormat == DeliveryImpl.DEFAULT_MESSAGE_FORMAT) {
                cachedTransfer.setMessageFormat(UnsignedInteger.ZERO);
            } else {
                cachedTransfer.setMessageFormat(UnsignedInteger.valueOf(messageFormat));
            }

            ReadableBuffer payload = delivery.getData();

            int pending = payload.remaining();
            //logInfo("pending !!! %d",pending);

            try {
                writeFrame(tpSession.getLocalChannel(), cachedTransfer, payload, new class Runnable {
                    void run()
                    {
                        cachedTransfer.setMore(Boolean.TRUE);
                    }
                });
            } finally {
                delivery.afterSend();  // Allow for freeing resources after write of buffered data
            }

            tpSession.incrementOutgoingId();
            tpSession.decrementRemoteIncomingWindow();

            if (payload is null || !payload.hasRemaining())
            {
                session.incrementOutgoingBytes(-pending);

                if (!cachedTransfer.getMore().booleanValue) {
                    // Clear the in-progress delivery marker
                    tpLink.setInProgressDelivery(null);

                    delivery.setDone();
                    tpLink.setDeliveryCount(tpLink.getDeliveryCount().add(UnsignedInteger.ONE));
                    tpLink.setLinkCredit(tpLink.getLinkCredit().subtract(UnsignedInteger.ONE));
                    session.incrementOutgoingDeliveries(-1);
                    snd.decrementQueued();
                }
            }
            else
            {
                session.incrementOutgoingBytes(-(pending - payload.remaining()));

                // Remember the delivery we are still processing
                // the body transfer frames for
                tpLink.setInProgressDelivery(delivery);
            }

            if (_emitFlowEventOnSend && snd.getLocalState() != EndpointState.CLOSED) {
                getConnectionImpl().put(Type.LINK_FLOW, snd);
            }
        }

        if(wasDone && delivery.getLocalState() !is null)
        {
            TransportDelivery tpDelivery = delivery.getTransportDelivery();
            // Use cached object as holder of data for immediate write to the FrameWriter
            cachedDisposition.setFirst(tpDelivery.getDeliveryId());
            cachedDisposition.setLast(tpDelivery.getDeliveryId());
            cachedDisposition.setRole(Role.SENDER);
            cachedDisposition.setSettled(new Boolean(delivery.isSettled()));
            cachedDisposition.setBatchable(Boolean.FALSE);  // Enforce default is written
            if(delivery.isSettled())
            {
                tpDelivery.settled();
            }
            cachedDisposition.setState(delivery.getLocalState());

            writeFrame(tpSession.getLocalChannel(), cachedDisposition, null, null);
        }

        return !delivery.isBuffered();
    }

    private bool processTransportWorkReceiver(DeliveryImpl delivery, ReceiverImpl rcv)
    {
        TransportDelivery tpDelivery = delivery.getTransportDelivery();
        SessionImpl session = rcv.getSession();
        TransportSession tpSession = session.getTransportSession();

        if (tpSession.isLocalChannelSet())
        {
            bool settled = delivery.isSettled();
            DeliveryState localState = delivery.getLocalState();
            // Use cached object as holder of data for immediate write to the FrameWriter
            cachedDisposition.setFirst(tpDelivery.getDeliveryId());
            cachedDisposition.setLast(tpDelivery.getDeliveryId());
            cachedDisposition.setRole(Role.RECEIVER);
            cachedDisposition.setSettled(new Boolean(settled));
            cachedDisposition.setState(localState);
            cachedDisposition.setBatchable(new Boolean(false));  // Enforce default is written

            if(localState is null && settled) {
                cachedDisposition.setState(delivery.getDefaultDeliveryState());
            }

            writeFrame(tpSession.getLocalChannel(), cachedDisposition, null, null);
            if (settled)
            {
                tpDelivery.settled();
            }
            return true;
        }

        return false;
    }

    private void processReceiverFlow()
    {
       // logInfo("processReceiverFlow out ------------------------");
        if(_connectionEndpoint !is null && _isOpenSent && !_isCloseSent)
        {
            EndpointImpl endpoint = _connectionEndpoint.getTransportHead();
            while(endpoint !is null)
            {
                 ReceiverImpl receiver = cast(ReceiverImpl) endpoint;
                if(receiver !is null)
                {
                    TransportLink transportLink = getTransportState(receiver);
                    TransportSession transportSession = getTransportState(receiver.getSession());

                    if(receiver.getLocalState() == EndpointState.ACTIVE && transportSession.isLocalChannelSet() && !receiver.detached())
                    {
                        int credits = receiver.clearUnsentCredits();
                        //logInfo("processReceiverFlow in ------------------------");
                        if(credits != 0 || receiver.getDrain() ||
                           transportSession.getIncomingWindowSize() == (UnsignedInteger.ZERO))
                        {
                            //logInfo("processReceiverFlow in in ------------------------");
                            transportLink.addCredit(credits);
                            writeFlow(transportSession, transportLink);
                        }
                    }
                }
                endpoint = endpoint.transportNext();
            }
            endpoint = _connectionEndpoint.getTransportHead();
            while(endpoint !is null)
            {
                SessionImpl session = cast(SessionImpl) endpoint;
                if(session !is null)
                {
                    TransportSession transportSession = getTransportState(session);
                   // logInfo("processReceiverFlow in ------------------------");
                    if(session.getLocalState() == EndpointState.ACTIVE && transportSession.isLocalChannelSet())
                    {
                        if(transportSession.getIncomingWindowSize()==(UnsignedInteger.ZERO))
                        {
                           // logInfo("processReceiverFlow in in------------------------");
                            writeFlow(transportSession, null);
                        }
                    }
                }
                endpoint = endpoint.transportNext();
            }
        }
    }

    private void processAttach()
    {
        if(_connectionEndpoint !is null && _isOpenSent && !_isCloseSent)
        {
            EndpointImpl endpoint = _connectionEndpoint.getTransportHead();

            while(endpoint !is null)
            {
                LinkImpl link = cast(LinkImpl) endpoint;
                if(link !is null)
                {
                    TransportLink transportLink = getTransportState(link);
                    SessionImpl session = link.getSession();
                    TransportSession transportSession = getTransportState(session);
                    if(link.getLocalState() != EndpointState.UNINITIALIZED && !transportLink.attachSent() && transportSession.isLocalChannelSet())
                    {

                        if( (link.getRemoteState() == EndpointState.ACTIVE
                            && !transportLink.isLocalHandleSet()) || link.getRemoteState() == EndpointState.UNINITIALIZED)
                        {

                            UnsignedInteger localHandle = transportSession.allocateLocalHandle(transportLink);

                            if(link.getRemoteState() == EndpointState.UNINITIALIZED)
                            {
                               // logInfo("processAttach UNINITIALIZED ...........................");
                                transportSession.addHalfOpenLink(transportLink);
                            }

                            Attach attach = new Attach();
                            attach.setHandle(localHandle);
                            attach.setName(transportLink.getName() is null ? null : new String(transportLink.getName()));

                            if(link.getSenderSettleMode() !is null)
                            {
                                //logInfo("processAttach getSenderSettleMode ......................... %d ",link.getSenderSettleMode().getEnum);
                                attach.setSndSettleMode(link.getSenderSettleMode());
                            }

                            if(link.getReceiverSettleMode() !is null)
                            {
                                //logInfo("processAttach getReceiverSettleMode ......................... %d ",link.getReceiverSettleMode().getEnum);
                                attach.setRcvSettleMode(link.getReceiverSettleMode());
                            }

                            if(link.getSource() !is null)
                            {
                               attach.setSource(link.getSource());
                            }

                            if(link.getTarget() !is null)
                            {
                                attach.setTarget(link.getTarget());
                            }

                            if(link.getProperties() !is null)
                            {
                                //attach.setProperties(link.getProperties());
                            }

                            if(link.getOfferedCapabilities() !is null)
                            {
                               // attach.setOfferedCapabilities(new ArrayList!Symbol(link.getOfferedCapabilities()));
                            }

                            if(link.getDesiredCapabilities() !is null)
                            {
                               // attach.setDesiredCapabilities(new ArrayList!Symbol (link.getDesiredCapabilities()));
                            }

                            if(link.getMaxMessageSize() !is null)
                            {
                               // logInfo("processAttach getMaxMessageSize ......................... %d ",link.getMaxMessageSize().intValue);
                                attach.setMaxMessageSize(link.getMaxMessageSize());
                            }

                            attach.setRole(cast(ReceiverImpl)endpoint !is null ? Role.RECEIVER : Role.SENDER);

                            if(cast(SenderImpl)link !is null)
                            {
                                //logInfo("processAttach setInitialDeliveryCount ......................... ");
                                attach.setInitialDeliveryCount(UnsignedInteger.ZERO);
                            }

                            writeFrame(transportSession.getLocalChannel(), attach, null, null);
                            transportLink.sentAttach();
                        }
                    }
                }
                endpoint = endpoint.transportNext();
            }
        }
    }

    private void processHeader()
    {
       // logInfo("processHeader  out ------------------------");
        if(!_headerWritten)
        {
           // logInfo("processHeader  in ------------------------");
            outputHeaderDescription();
            _frameWriter.writeHeader(AmqpHeader.HEADER);
            _headerWritten = true;
        }
    }

    private void outputHeaderDescription()
    {
        if (isFrameTracingEnabled())
        {
            log(TransportImpl.OUTGOING, new String(HEADER_DESCRIPTION));

            ProtocolTracer tracer = getProtocolTracer();
            if (tracer !is null)
            {
                tracer.sentHeader(HEADER_DESCRIPTION);
            }
        }
    }

    private void processOpen()
    {
       // logInfo("processOpen  out -------------------------------");
        if (!_isOpenSent && (_conditionSet ||
             (_connectionEndpoint !is null &&
              _connectionEndpoint.getLocalState() != EndpointState.UNINITIALIZED)))
        {
           // logInfo("processOpen  in -------------------------------");
            Open open = new Open();
            if (_connectionEndpoint !is null) {
               // logInfo("processOpen  in in-------------------------------");
                string cid = _connectionEndpoint.getLocalContainerId();
                open.setContainerId( new String( cid is null ? "" : cid));
                open.setHostname(_connectionEndpoint.getHostname()is null ? null : new String(_connectionEndpoint.getHostname()));
                //open.setDesiredCapabilities(_connectionEndpoint.getDesiredCapabilities().length == 0? null : new ArrayList!Symbol(_connectionEndpoint.getDesiredCapabilities()));
                //open.setOfferedCapabilities(_connectionEndpoint.getOfferedCapabilities().length == 0? null :new ArrayList!Symbol(_connectionEndpoint.getOfferedCapabilities()));
                //open.setProperties(_connectionEndpoint.getProperties());
                open.setDesiredCapabilities(null);
                open.setOfferedCapabilities(null);
                open.setProperties(null);
            } else {
                open.setContainerId(new String(""));
            }

            if (_maxFrameSize > 0) {
                open.setMaxFrameSize(UnsignedInteger.valueOf(_maxFrameSize));
            }
            if (_channelMax > 0) {
                open.setChannelMax(UnsignedShort.valueOf(cast(short) _channelMax));
            }

            // as per the recommendation in the spec, advertise half our
            // actual timeout to the remote
            if (_localIdleTimeout > 0) {
                open.setIdleTimeOut(new UnsignedInteger(_localIdleTimeout / 2));
            }
            _isOpenSent = true;

            writeFrame(0, open, null, null);
        }
    }

    private void processBegin()
    {
       // logInfo("processBegin out -----------------------------");
        if(_connectionEndpoint !is null && _isOpenSent && !_isCloseSent)
        {
            EndpointImpl endpoint = _connectionEndpoint.getTransportHead();
            while(endpoint !is null)
            {
                SessionImpl session = cast(SessionImpl) endpoint;
                if(session !is null)
                {
                    TransportSession transportSession = getTransportState(session);
                    if(session.getLocalState() != EndpointState.UNINITIALIZED && !transportSession.beginSent())
                    {
                        int channelId = allocateLocalChannel(transportSession);
                        Begin begin = new Begin();

                        if(session.getRemoteState() != EndpointState.UNINITIALIZED)
                        {
                           // logInfo("processBegin in in-----------------------------");
                            begin.setRemoteChannel(UnsignedShort.valueOf(cast(short) transportSession.getRemoteChannel()));
                        }
                       // logInfo("processBegin in -----------------------------");
                        transportSession.updateIncomingWindow();

                        begin.setHandleMax(transportSession.getHandleMax());
                        begin.setIncomingWindow(transportSession.getIncomingWindowSize());
                        begin.setOutgoingWindow(transportSession.getOutgoingWindowSize());
                        //logInfo("getOutgoingWindowSize :%d",transportSession.getOutgoingWindowSize().intValue);
                        begin.setNextOutgoingId(transportSession.getNextOutgoingId());

                        if(session.getProperties() !is null)
                        {
                           // begin.setProperties(session.getProperties());
                        }

                        if(session.getOfferedCapabilities() !is null)
                        {
                            //begin.setOfferedCapabilities(new ArrayList!Symbol(session.getOfferedCapabilities()));
                        }

                        if(session.getDesiredCapabilities() !is null)
                        {
                           // begin.setDesiredCapabilities(new ArrayList!Symbol (session.getDesiredCapabilities()));
                        }

                        writeFrame(channelId, begin, null, null);
                        transportSession.sentBegin();
                    }
                }
                endpoint = endpoint.transportNext();
            }
        }
    }

    private TransportSession getTransportState(SessionImpl session)
    {
        TransportSession transportSession = session.getTransportSession();
        if(transportSession is null)
        {
            transportSession = new TransportSession(this, session);
            session.setTransportSession(transportSession);
        }
        return transportSession;
    }

    private TransportLink getTransportState(LinkImpl link)
    {
        TransportLink transportLink = link.getTransportLink();
        if(transportLink is null)
        {
            transportLink = TransportLink.createTransportLink(link);
        }
        return transportLink;
    }

    private int allocateLocalChannel(TransportSession transportSession)
    {
        for (int i = 0; i < _connectionEndpoint.getMaxChannels(); i++)
        {
            if (!_localSessions.containsKey(i))
            {
                _localSessions.put(i, transportSession);
                transportSession.setLocalChannel(i);
                return i;
            }
        }

        return -1;
    }

    private int freeLocalChannel(TransportSession transportSession)
    {
        int channel = transportSession.getLocalChannel();
        _localSessions.remove(channel);
        transportSession.freeLocalChannel();
        return channel;
    }

    private void processEnd()
    {
       // logInfo("processEnd out -----------------------------");
        if(_connectionEndpoint !is null && _isOpenSent)
        {
            EndpointImpl endpoint = _connectionEndpoint.getTransportHead();
            while(endpoint !is null)
            {
                SessionImpl session;
                TransportSession transportSession;

                if((cast(SessionImpl)endpoint !is null)) {
                    if ((session = cast(SessionImpl)endpoint).getLocalState() == EndpointState.CLOSED
                        && (transportSession = session.getTransportSession()).isLocalChannelSet()
                        && !_isCloseSent)
                    {
                        if (hasSendableMessages(session)) {
                            endpoint = endpoint.transportNext();
                            continue;
                        }

                        int channel = freeLocalChannel(transportSession);
                        End end = new End();
                        ErrorCondition localError = endpoint.getCondition();
                        if( localError.getCondition() !is null )
                        {
                            end.setError(localError);
                        }

                        writeFrame(channel, end, null, null);
                    }
                   // logInfo("processEnd in -----------------------------");
                    endpoint.clearModified();
                }

                endpoint = endpoint.transportNext();
            }
        }
    }

    private bool hasSendableMessages(SessionImpl session)
    {
        if (_connectionEndpoint is null) {
            return false;
        }

        if(!_closeReceived && (session is null || !session.getTransportSession().endReceived()))
        {
            EndpointImpl endpoint = _connectionEndpoint.getTransportHead();
            while(endpoint !is null)
            {
                SenderImpl sender = cast(SenderImpl) endpoint;
                if(sender !is null)
                {
                    if((session is null || sender.getSession() == session)
                       && sender.getQueued() != 0
                        && !getTransportState(sender).detachReceived())
                    {
                        return true;
                    }
                }
                endpoint = endpoint.transportNext();
            }
        }
        return false;
    }

    private void processClose()
    {
       // logInfo("processClose out -----------------");
        if ((_conditionSet ||
             (_connectionEndpoint !is null &&
              _connectionEndpoint.getLocalState() == EndpointState.CLOSED)) &&
            !_isCloseSent) {
            if(!hasSendableMessages(null))
            {
              //  logInfo("processClose in -----------------");
                Close close = new Close();

                ErrorCondition localError;

                if (_connectionEndpoint is null) {
                    localError = getCondition();
                } else {
                    localError =  _connectionEndpoint.getCondition();
                }

                if(localError !is null && localError.getCondition() !is null)
                {
                    close.setError(localError);
                }

                _isCloseSent = true;

                writeFrame(0, close, null, null);

                if (_connectionEndpoint !is null) {
                    _connectionEndpoint.clearModified();
                }
            }
        }
    }

    protected void writeFrame(int channel, FrameBody frameBody,
                              ReadableBuffer payload, Runnable onPayloadTooLarge)
    {
        _frameWriter.writeFrame(channel, cast(Object)frameBody, payload, onPayloadTooLarge);
    }

    //==================================================================================================================

    override
    public ConnectionImpl getConnectionImpl()
    {
        return _connectionEndpoint;
    }

    override
    void postFinal() {}

    override
    void doFree() { }

    //==================================================================================================================
    // handle incoming amqp data


    public void handleOpen(Open open, Binary payload, int channel)
    {
        setRemoteState(EndpointState.ACTIVE);
        if(_connectionEndpoint !is null)
        {
            _connectionEndpoint.handleOpen(open);
        }
        else
        {
            _open = open;
        }

        int effectiveMaxFrameSize = _remoteMaxFrameSize;
        if(open.getMaxFrameSize().longValue() > 0)
        {
            _remoteMaxFrameSize = cast(int) open.getMaxFrameSize().longValue();
            effectiveMaxFrameSize = cast(int) min(open.getMaxFrameSize().longValue(), Integer.MAX_VALUE);
        }

        if(_outboundFrameSizeLimit > 0) {
            effectiveMaxFrameSize = cast(int) min(open.getMaxFrameSize().longValue(), _outboundFrameSizeLimit);
        }

        _frameWriter.setMaxFrameSize(effectiveMaxFrameSize);

        if (open.getChannelMax().longValue() > 0)
        {
            _remoteChannelMax = cast(int) open.getChannelMax().longValue();
        }

        if (open.getIdleTimeOut() !is null && open.getIdleTimeOut().longValue() > 0)
        {
            _remoteIdleTimeout = open.getIdleTimeOut().intValue();
        }
    }

    public void handleBegin(Begin begin, Binary payload, int channel)
    {
        // TODO - check channel < max_channel
        TransportSession transportSession = _remoteSessions.get(channel);
        if(transportSession !is null)
        {
            // TODO - fail due to begin on begun session
        }
        else
        {
            SessionImpl session;
            if(begin.getRemoteChannel() is null)
            {
                session = _connectionEndpoint.session();
                transportSession = getTransportState(session);
            }
            else
            {
                transportSession = _localSessions.get(begin.getRemoteChannel().intValue());
                if (transportSession is null) {
                    // TODO handle failure rather than just throwing a nicer NPE
                    throw new NullPointerException("uncorrelated channel: ");
                }
                session = transportSession.getSession();

            }
            transportSession.setRemoteChannel(channel);
            session.setRemoteState(EndpointState.ACTIVE);
            transportSession.setNextIncomingId(begin.getNextOutgoingId());
            session.setRemoteProperties(begin.getProperties());
            if (begin.getDesiredCapabilities() !is null)
            {
                session.setRemoteDesiredCapabilities(begin.getDesiredCapabilities().toArray());
            }
            if (begin.getOfferedCapabilities() !is null)
            {
                session.setRemoteOfferedCapabilities(begin.getOfferedCapabilities().toArray());
            }
            _remoteSessions.put(channel, transportSession);

            _connectionEndpoint.put(Type.SESSION_REMOTE_OPEN, session);
        }

    }

    public void handleAttach(Attach attach, Binary payload, int channel)
    {
        TransportSession transportSession = _remoteSessions.get(channel);
        if(transportSession is null)
        {
            // TODO - fail due to attach on non-begun session
        }
        else
        {
            SessionImpl session = transportSession.getSession();
            UnsignedInteger handle = attach.getHandle();
            if (handle > (transportSession.getHandleMax())) {
                // The handle-max value is the highest handle value that can be used on the session. A peer MUST
                // NOT attempt to attach a link using a handle value outside the range that its partner can handle.
                // A peer that receives a handle outside the supported range MUST close the connection with the
                // framing-error error-code.
                ErrorCondition condition =
                        new ErrorCondition(ConnectionError.FRAMING_ERROR,
                                                            new String("handle-max exceeded"));
                _connectionEndpoint.setCondition(condition);
                _connectionEndpoint.setLocalState(EndpointState.CLOSED);
                if (!_isCloseSent) {
                    Close close = new Close();
                    close.setError(condition);
                    _isCloseSent = true;
                    writeFrame(0, close, null, null);
                }
                close_tail();
                return;
            }
            TransportLink transportLink = transportSession.getLinkFromRemoteHandle(handle);
            LinkImpl link = null;

            if(transportLink !is null)
            {
                // TODO - fail - attempt attach on a handle which is in use
            }
            else
            {
                transportLink = transportSession.resolveHalfOpenLink(cast(string)(attach.getName().getBytes()));
                if(transportLink is null)
                {

                    link = (attach.getRole() == Role.RECEIVER)
                           ? session.sender(cast(string)(attach.getName().getBytes()))
                           : session.receiver(cast(string)(attach.getName().getBytes()));
                    transportLink = getTransportState(link);
                }
                else
                {
                    link = cast(LinkImpl)(transportLink.getLink());
                }
                if(attach.getRole() == Role.SENDER)
                {
                    transportLink.setDeliveryCount(attach.getInitialDeliveryCount());
                }

                link.setRemoteState(EndpointState.ACTIVE);
                link.setRemoteSource(attach.getSource());
                link.setRemoteTarget(attach.getTarget());

                link.setRemoteReceiverSettleMode(attach.getRcvSettleMode());
                link.setRemoteSenderSettleMode(attach.getSndSettleMode());

                link.setRemoteProperties(attach.getProperties());

                if (attach.getDesiredCapabilities() !is null)
                {
                    link.setRemoteDesiredCapabilities(attach.getDesiredCapabilities().toArray());
                }
                if (attach.getOfferedCapabilities() !is null)
                {
                    link.setRemoteOfferedCapabilities(attach.getOfferedCapabilities().toArray());
                }


                link.setRemoteMaxMessageSize(attach.getMaxMessageSize());

                transportLink.setName(cast(string)(attach.getName().getBytes()));
                transportLink.setRemoteHandle(handle);
                transportSession.addLinkRemoteHandle(transportLink, handle);

            }

            _connectionEndpoint.put(Type.LINK_REMOTE_OPEN, link);
        }
    }

    public void handleFlow(Flow flow, Binary payload, int channel)
    {
        TransportSession transportSession = _remoteSessions.get(channel);
        if(transportSession is null)
        {
            // TODO - fail due to attach on non-begun session
        }
        else
        {
            transportSession.handleFlow(flow);
        }

    }

    public void handleTransfer(Transfer transfer, Binary payload, int channel)
    {
        // TODO - check channel < max_channel
        TransportSession transportSession = _remoteSessions.get(channel);
        if(transportSession !is null)
        {
            transportSession.handleTransfer(transfer, payload);
        }
        else
        {
            // TODO - fail due to begin on begun session
        }
    }

    public void handleDisposition(Disposition disposition, Binary payload, int channel)
    {
        TransportSession transportSession = _remoteSessions.get(channel);
        if(transportSession is null)
        {
            // TODO - fail due to attach on non-begun session
        }
        else
        {
            transportSession.handleDisposition(disposition);
        }
    }

    public void handleDetach(Detach detach, Binary payload, int channel)
    {
        TransportSession transportSession = _remoteSessions.get(channel);
        if(transportSession is null)
        {
            // TODO - fail due to attach on non-begun session
        }
        else
        {
            TransportLink transportLink = transportSession.getLinkFromRemoteHandle(detach.getHandle());

            if(transportLink !is null)
            {
                LinkImpl link = cast(LinkImpl)(transportLink.getLink());
                transportLink.receivedDetach();
                transportSession.freeRemoteHandle(transportLink.getRemoteHandle());
                if (detach.getClosed().booleanValue()) {
                    _connectionEndpoint.put(Type.LINK_REMOTE_CLOSE, link);
                } else {
                    _connectionEndpoint.put(Type.LINK_REMOTE_DETACH, link);
                }
                transportLink.clearRemoteHandle();
                link.setRemoteState(EndpointState.CLOSED);
                if(detach.getError() !is null)
                {
                    link.getRemoteCondition().copyFrom(detach.getError());
                }
            }
            else
            {
                // TODO - fail - attempt attach on a handle which is in use
            }
        }
    }

     void invoke(FrameBodyHandler!int handler, Binary payload, int context)
     {
         implementationMissing(false);
     }

    public void handleEnd(End end, Binary payload, int channel)
    {
        TransportSession transportSession = _remoteSessions.get(channel);
        if(transportSession is null)
        {
            // TODO - fail due to attach on non-begun session
        }
        else
        {
            _remoteSessions.remove(channel);
            transportSession.receivedEnd();
            transportSession.unsetRemoteChannel();
            SessionImpl session = transportSession.getSession();
            session.setRemoteState(EndpointState.CLOSED);
            ErrorCondition errorCondition = end.getError();
            if(errorCondition !is null)
            {
                session.getRemoteCondition().copyFrom(errorCondition);
            }

            _connectionEndpoint.put(Type.SESSION_REMOTE_CLOSE, session);
        }
    }

    public void handleClose(Close close, Binary payload, int channel)
    {
        _closeReceived = true;
        _remoteIdleTimeout = 0;
        setRemoteState(EndpointState.CLOSED);
        if(_connectionEndpoint !is null)
        {
            _connectionEndpoint.setRemoteState(EndpointState.CLOSED);
            if(close.getError() !is null)
            {
                _connectionEndpoint.getRemoteCondition().copyFrom(close.getError());
            }

            _connectionEndpoint.put(Type.CONNECTION_REMOTE_CLOSE, _connectionEndpoint);
        }

    }

    override
    public bool handleFrame(TransportFrame frame)
    {
        if (!isHandlingFrames())
        {
            throw new IllegalStateException("Transport cannot accept frame: ");
        }

        log(INCOMING, frame);

        ProtocolTracer tracer = _protocolTracer.get();
        if( tracer !is null )
        {
            tracer.receivedFrame(frame);
        }

        //import hunt.proton.amqp.transport.Attach;
        //import hunt.proton.amqp.transport.Open;
        //import hunt.proton.amqp.transport.Begin;
        //import hunt.proton.amqp.transport.Detach;
        //import hunt.proton.amqp.transport.Close;
        //import hunt.proton.amqp.transport.Flow;
        //import hunt.proton.amqp.transport.End;
        //import hunt.proton.amqp.transport.Transfer;
        //import hunt.proton.amqp.transport.EmptyFrame;
        //import hunt.proton.amqp.transport.Disposition;
        Attach attach = cast(Attach)frame.getBody();
        if (attach !is null)
        {
            attach.invoke(this,frame.getPayload(), frame.getChannel());
            return _closeReceived;
        }
        Open open = cast(Open)frame.getBody();
        if (open !is null)
        {
            open.invoke(this,frame.getPayload(), frame.getChannel());
            return _closeReceived;
        }
        Begin begin = cast(Begin)frame.getBody();
        if (begin !is null)
        {
            begin.invoke(this,frame.getPayload(), frame.getChannel());
            return _closeReceived;
        }
        Detach detach = cast(Detach)frame.getBody();
        if (detach !is null)
        {
            detach.invoke(this,frame.getPayload(), frame.getChannel());
            return _closeReceived;
        }
        Close close = cast(Close)frame.getBody();
        if (close !is null)
        {
            close.invoke(this,frame.getPayload(), frame.getChannel());
            return _closeReceived;
        }
        Flow flow = cast(Flow)frame.getBody();
        if (flow !is null)
        {
            flow.invoke(this,frame.getPayload(), frame.getChannel());
            return _closeReceived;
        }
        End end = cast(End)frame.getBody();
        if (end !is null)
        {
            end.invoke(this,frame.getPayload(), frame.getChannel());
            return _closeReceived;
        }
        Transfer transfer = cast(Transfer)frame.getBody();
        if (transfer !is null)
        {
            transfer.invoke(this,frame.getPayload(), frame.getChannel());
            return _closeReceived;
        }
        EmptyFrame emptyframe = cast(EmptyFrame)frame.getBody();
        if (emptyframe !is null)
        {
            emptyframe.invoke(this,frame.getPayload(), frame.getChannel());
            return _closeReceived;
        }
        Disposition dispos = cast(Disposition)frame.getBody();
        if (dispos !is null)
        {
            dispos.invoke(this,frame.getPayload(), frame.getChannel());
            return _closeReceived;
        }
      //  (cast(FrameBodyHandler!int)frame.getBody()).invoke(this,frame.getPayload(), frame.getChannel());
        return _closeReceived;
    }

    void put(Type type, Object context) {
        if (_connectionEndpoint !is null) {
            _connectionEndpoint.put(type, context);
        }
    }

    private void maybePostClosed()
    {
        if (postedHeadClosed && postedTailClosed) {
            put(Type.TRANSPORT_CLOSED, this);
        }
    }

    override
    public void closed(TransportException error)
    {
        if (!_closeReceived || error !is null) {
            // Set an error condition, but only if one was not already set
            if(!_conditionSet) {
                string description =  error is null ? "connection aborted" : error.toString();
                setCondition(new ErrorCondition(ConnectionError.FRAMING_ERROR, new String( description)));
            }

            _head_closed = true;
        }

        if (_conditionSet && !postedTransportError) {
            put(Type.TRANSPORT_ERROR, this);
            postedTransportError = true;
        }

        if (!postedTailClosed) {
            put(Type.TRANSPORT_TAIL_CLOSED, this);
            postedTailClosed = true;
            maybePostClosed();
        }
    }

    override
    public bool isHandlingFrames()
    {
        return _connectionEndpoint !is null || getRemoteState() == EndpointState.UNINITIALIZED;
    }

    override
    public ProtocolTracer getProtocolTracer()
    {
        return _protocolTracer.get();
    }

    override
    public void setProtocolTracer(ProtocolTracer protocolTracer)
    {
        this._protocolTracer.set(protocolTracer);
    }

    override
    public ByteBuffer getInputBuffer()
    {
        return tail();
    }

    override
    public TransportResult processInput()
    {
        try {
            process();
            return TransportResultFactory.ok();
        } catch (TransportException e) {
            return TransportResultFactory.error(e);
        }
    }

    override
    public ByteBuffer getOutputBuffer()
    {
        pending();
        return head();
    }

    override
    public void outputConsumed()
    {
        pop(_outputProcessor.head().position());
    }

    override
    public int capacity()
    {
        init();
        return _inputProcessor.capacity();
    }

    override
    public ByteBuffer tail()
    {
        init();
        return _inputProcessor.tail();
    }

    override
    public void process()
    {
        _processingStarted = true;

        try {
            init();
            int beforePosition = _inputProcessor.position();
            _inputProcessor.process();
            _bytesInput += beforePosition - _inputProcessor.position();
        } catch (TransportException e) {
            _head_closed = true;
        }
    }

    override
    public void close_tail()
    {
        init();
        _inputProcessor.close_tail();
    }

    override
    public int pending()
    {
        init();
        //version(HUNT_DEBUG)
        //{
          //  logInfof("ttttttttttttttt %s",typeid(cast(Object)_outputProcessor));
        //}
        return _outputProcessor.pending();
    }

    override
    public ByteBuffer head()
    {
        init();
        return _outputProcessor.head();
    }

    override
    public void pop(int bytes)
    {
        init();
        _outputProcessor.pop(bytes);
        _bytesOutput += bytes;

        int p = pending();
        if (p < 0 && !postedHeadClosed) {
            put(Type.TRANSPORT_HEAD_CLOSED, this);
            postedHeadClosed = true;
            maybePostClosed();
        }
    }

    override
    public void setIdleTimeout(int timeout) {
        _localIdleTimeout = timeout;
    }

    override
    public int getIdleTimeout() {
        return _localIdleTimeout;
    }

    override
    public int getRemoteIdleTimeout() {
        return _remoteIdleTimeout;
    }

    override
    public long tick(long now)
    {
      long deadline = 0;
      synchronized(this){
        if (pending() == 0) {
          writeFrame( 0, null, null, null);
          pending();
        }
      }
      //synchronized(this){
      //  if (_localIdleTimeout > 0) {
      //    if (_localIdleDeadline == 0 || _lastBytesInput != _bytesInput) {
      //      _localIdleDeadline = computeDeadline(now, _localIdleTimeout);
      //      _lastBytesInput = _bytesInput;
      //    } else if (_localIdleDeadline - now <= 0) {
      //      _localIdleDeadline = computeDeadline(now, _localIdleTimeout);
      //      if (_connectionEndpoint !is null &&
      //      _connectionEndpoint.getLocalState() != EndpointState.CLOSED) {
      //        ErrorCondition condition =
      //        new ErrorCondition(Symbol.getSymbol("amqp:resource-limit-exceeded"),
      //        new String ("local-idle-timeout expired"));
      //        _connectionEndpoint.setCondition(condition);
      //        _connectionEndpoint.setLocalState(EndpointState.CLOSED);
      //
      //        if (!_isOpenSent) {
      //          if ((_sasl !is null) && (!_sasl.isDone())) {
      //            _sasl.fail();
      //          }
      //          Open open = new Open();
      //          _isOpenSent = true;
      //          writeFrame(0, open, null, null);
      //        }
      //        if (!_isCloseSent) {
      //          Close close = new Close();
      //          close.setError(condition);
      //          _isCloseSent = true;
      //          writeFrame(0, close, null, null);
      //        }
      //        close_tail();
      //      }
      //    }
      //    deadline = _localIdleDeadline;
      //  }
      //
      //  if (_remoteIdleTimeout != 0 && !_isCloseSent) {
      //    if (_remoteIdleDeadline == 0 || _lastBytesOutput != _bytesOutput) {
      //      _remoteIdleDeadline = computeDeadline(now, _remoteIdleTimeout / 2);
      //      _lastBytesOutput = _bytesOutput;
      //    } else if (_remoteIdleDeadline - now <= 0) {
      //      _remoteIdleDeadline = computeDeadline(now, _remoteIdleTimeout / 2);
      //      if (pending() == 0) {
      //        writeFrame(0, null, null, null);
      //        _lastBytesOutput += pending();
      //      }
      //    }
      //
      //    if(deadline == 0) {
      //      deadline = _remoteIdleDeadline;
      //    } else {
      //      if(_remoteIdleDeadline - _localIdleDeadline <= 0) {
      //        deadline = _remoteIdleDeadline;
      //      } else {
      //        deadline = _localIdleDeadline;
      //      }
      //    }
      //  }
      //}
      return deadline;
    }

    private long computeDeadline(long now, long timeout) {
        long deadline = now + timeout;

        // We use 0 to signal not-initialised and/or no-timeout, so in the
        // unlikely event thats to be the actual deadline, return 1 instead
        return deadline != 0 ? deadline : 1;
    }

    override
    public long getFramesOutput()
    {
        return _frameWriter.getFramesOutput();
    }

    override
    public long getFramesInput()
    {
        return _frameParser.getFramesInput();
    }

    override
    public void close_head()
    {
        _outputProcessor.close_head();
    }

    override
    public bool isClosed() {
        int p = pending();
        int c = capacity();
        return  p == END_OF_STREAM && c == END_OF_STREAM;
    }
    override
    public string toString()
    {
        implementationMissing(false);
        return "";
       // return "TransportImpl [_connectionEndpoint=" ~ _connectionEndpoint ~ ", " ~ super.toString() ~ "]";
    }

    /**
     * Override the default frame handler. Must be called before the transport starts being used
     * (e.g. {@link #getInputBuffer()}, {@link #getOutputBuffer()}, {@link #ssl(SslDomain)} etc).
     */
    public void setFrameHandler(FrameHandler frameHandler)
    {
        _frameHandler = frameHandler;
    }

    static string INCOMING = "<-";
    static string OUTGOING = "->";

    void log(string event, TransportFrame frame)
    {
        if (isTraceFramesEnabled()) {
            outputMessage(event, frame.getChannel(), cast(Object)frame.getBody(), frame.getPayload());
        }
    }

    void log(string event, SaslFrameBody frameBody) {
        if (isTraceFramesEnabled()) {
            outputMessage(event, 0, cast(Object)frameBody, null);
        }
    }

    void log(string event, String headerDescription) {
        if (isTraceFramesEnabled()) {
            outputMessage(event, 0, headerDescription, null);
        }
    }

    private void outputMessage(string event, int channel, Object frameBody, Binary payload) {
        implementationMissing(false);
        //string msg         ;
        //
        //msg.append("[").append(System.identityHashCode(this)).append(":").append(channel).append("] ");
        //msg.append(event).append(" ").append(frameBody);
        //if (payload !is null) {
        //    msg.append(" (").append(payload.getLength()).append(") ");
        //    msg.append(StringUtils.toQuotedString(payload, TRACE_FRAME_PAYLOAD_LENGTH, true));
        //}
        //
        //System.out.println(msg.toString());
    }

    bool isFrameTracingEnabled()
    {
        return (_levels & TRACE_FRM) != 0 || _protocolTracer.get() !is null;
    }

    bool isTraceFramesEnabled()
    {
        return (_levels & TRACE_FRM) != 0;
    }

    override
    void localOpen() {}

    override
    void localClose() {}

    public void setSelectable(Selectable selectable) {
        _selectable = selectable;
    }

    public Selectable getSelectable() {
        return _selectable;
    }

    public void setReactor(Reactor reactor) {
        _reactor = reactor;
    }

    public Reactor getReactor() {
        return _reactor;
    }

    override
    public void setEmitFlowEventOnSend(bool emitFlowEventOnSend)
    {
        _emitFlowEventOnSend = emitFlowEventOnSend;
    }

    override
    public bool isEmitFlowEventOnSend()
    {
        return _emitFlowEventOnSend;
    }

    override
    public void setUseReadOnlyOutputBuffer(bool value)
    {
        this._useReadOnlyOutputBuffer = value;
    }

    override
    public bool isUseReadOnlyOutputBuffer()
    {
        return _useReadOnlyOutputBuffer;
    }

    // From TransportInternal
    override
    public void addTransportLayer(TransportLayer layer)
    {
        if (_processingStarted)
        {
            throw new IllegalStateException("Additional layer can't be added after transport has started processing");
        }

        if (_additionalTransportLayers is null)
        {
            _additionalTransportLayers = new ArrayList!TransportLayer();
        }

        if (!_additionalTransportLayers.contains(layer))
        {
            init();
            TransportWrapper transportWrapper = layer.wrap(_inputProcessor, _outputProcessor);
            _inputProcessor = transportWrapper;
            _outputProcessor = transportWrapper;
            _additionalTransportLayers.add(layer);
        }
    }

    override
    public void setOutboundFrameSizeLimit(int limit) {
        _outboundFrameSizeLimit = limit;
    }

    override
    public int getOutboundFrameSizeLimit() {
        return _outboundFrameSizeLimit;
    }
}
