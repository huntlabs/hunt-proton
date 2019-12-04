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

module hunt.proton.engine.impl.SaslImpl;
import hunt.String;
import hunt.Exceptions;
import  hunt.proton.engine.impl.ByteBufferUtils;
import hunt.collection.ByteBuffer;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.security.SaslChallenge;
import hunt.proton.amqp.security.SaslCode;
import hunt.proton.amqp.security.SaslFrameBody;
import hunt.proton.amqp.security.SaslInit;
import hunt.proton.amqp.security.SaslMechanisms;
import hunt.proton.amqp.security.SaslResponse;
import hunt.proton.codec.AMQPDefinedTypes;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.engine.Sasl;
import hunt.proton.engine.SaslListener;
import hunt.proton.engine.Transport;
import hunt.proton.engine.TransportException;
import hunt.Object;
import hunt.logging;
import hunt.proton.engine.impl.PlainTransportWrapper;
import hunt.proton.engine.impl.SaslSniffer;
import hunt.proton.engine.impl.TransportInput;
import hunt.proton.engine.impl.TransportOutput;
import hunt.proton.engine.impl.SaslFrameHandler;
import hunt.proton.engine.impl.TransportLayer;
import hunt.proton.engine.impl.TransportImpl;
import hunt.proton.engine.impl.FrameWriter;
import hunt.proton.engine.impl.SaslFrameParser;
import hunt.proton.engine.impl.AmqpHeader;
import hunt.proton.engine.impl.ProtocolTracer;
import hunt.proton.engine.impl.TransportWrapper;
import hunt.collection.ArrayList;
import hunt.proton.amqp.security.SaslOutcome;
import hunt.logging;
import std.conv:to;

class SaslImpl : Sasl, SaslFrameBodyHandler!Void, SaslFrameHandler, TransportLayer
{

    public static byte SASL_FRAME_TYPE = cast(byte) 1;
    private static string HEADER_DESCRIPTION = "SASL";

    private DecoderImpl _decoder ;// = new DecoderImpl();
    private EncoderImpl _encoder ;//= new EncoderImpl(_decoder);

    private TransportImpl _transport;

    private bool _tail_closed = false;
    private bool _head_closed = false;
    private int _maxFrameSize;
    private FrameWriter _frameWriter;

    private ByteBuffer _pending;

    private bool _headerWritten;
    private Binary _challengeResponse;
    private SaslFrameParser _frameParser;
    private bool _initReceived;
    private bool _mechanismsSent;
    private bool _initSent;

    enum Role { CLIENT, SERVER }

    private hunt.proton.engine.Sasl.SaslOutcome _outcome ;// = SaslOutcome.PN_SASL_NONE;
    private SaslState _state ;//= SaslState.PN_SASL_IDLE;

    private string _hostname;
    private bool _done;
    private Symbol[] _mechanisms;

    private Symbol _chosenMechanism;

    private Role _role;
    private bool _allowSkip = true;

    private SaslListener _saslListener;

    /**
     * @param maxFrameSize the size of the input and output buffers
     * {@link SaslTransportWrapper#_inputBuffer} and
     * {@link SaslTransportWrapper#_outputBuffer}.
     */
    this(TransportImpl transport, int maxFrameSize)
    {
        _role  = Role.CLIENT;
        _outcome = hunt.proton.engine.Sasl.SaslOutcome.PN_SASL_NONE;
        _state = SaslState.PN_SASL_IDLE;
        _transport = transport;
        _maxFrameSize = maxFrameSize;
        _decoder = new DecoderImpl();
        _encoder = new EncoderImpl(_decoder);
        AMQPDefinedTypes.registerAllTypes(_decoder,_encoder);
        _frameParser = new SaslFrameParser(this, _decoder, maxFrameSize, _transport);
        _frameWriter = new FrameWriter(_encoder, maxFrameSize, FrameWriter.SASL_FRAME_TYPE, _transport);
    }

    void fail() {
        if ( _role == Role.CLIENT) {
            _role = Role.CLIENT;
            _initSent = true;
            logInfo("_initSent true !!!!!!!");
        } else {
            _initReceived = true;

        }
        _done = true;
        logInfo("_done true !!!!!!!");
        _outcome = hunt.proton.engine.Sasl.SaslOutcome.PN_SASL_SYS;
    }

    override
    public bool isDone()
    {
        return _done && (_role==Role.CLIENT || _initReceived);
    }

    private void process()
    {
        processHeader();

        if(_role == Role.SERVER)
        {
            if(!_mechanismsSent && _mechanisms !is null)
            {
                SaslMechanisms mechanisms = new SaslMechanisms();

                mechanisms.setSaslServerMechanisms(new ArrayList!Symbol (_mechanisms));
               // mechanisms.setSaslServerMechanisms(new ArrayList!Symbol (Symbol.valueOf("ANONYMOUS")));
                writeFrame(mechanisms);
                _mechanismsSent = true;
                _state = SaslState.PN_SASL_STEP;
            }

            if(getState() == SaslState.PN_SASL_STEP && getChallengeResponse() !is null)
            {
                SaslChallenge challenge = new SaslChallenge();
                challenge.setChallenge(getChallengeResponse());
                writeFrame(challenge);
                setChallengeResponse(null);
            }

            if(_done)
            {
                hunt.proton.amqp.security.SaslOutcome.SaslOutcome outcome =
                        new hunt.proton.amqp.security.SaslOutcome.SaslOutcome();
                outcome.setCode(SaslCode.values()[_outcome.getCode()]);
                if (_outcome == hunt.proton.engine.Sasl.SaslOutcome.PN_SASL_OK)
                {
                    outcome.setAdditionalData(getChallengeResponse());
                }
                writeFrame(outcome);
                setChallengeResponse(null);
            }
        }
        else if(_role == Role.CLIENT)
        {
            if(getState() == SaslState.PN_SASL_IDLE && _chosenMechanism !is null)
            {
                processInit();
                _state = SaslState.PN_SASL_STEP;

                //HACK: if we received an outcome before
                //we sent our init, change the state now
                if(_outcome != hunt.proton.engine.Sasl.SaslOutcome.PN_SASL_NONE)
                {
                    _state = classifyStateFromOutcome(_outcome);
                }
            }

            if(getState() == SaslState.PN_SASL_STEP && getChallengeResponse() !is null)
            {
                processResponse();
            }
        }
    }

    private void writeFrame(SaslFrameBody frameBody)
    {
        _frameWriter.writeFrame(cast(Object)frameBody);
    }

    override
    public int recv(byte[] bytes, int offset, int size)
    {
        if(_pending is null)
        {
            return -1;
        }
        int written = ByteBufferUtils.pourBufferToArray(_pending, bytes, offset, size);
        if(!_pending.hasRemaining())
        {
            _pending = null;
        }
        return written;
    }

    override
    public int send(byte[] bytes, int offset, int size)
    {
        byte[] data = new byte[size];
        //System.arraycopy(bytes, offset, data, 0, size);
        data[0 .. size] = bytes[offset .. offset+size];
        setChallengeResponse(new Binary(data));
        return size;
    }

    int processHeader()
    {
        if(!_headerWritten)
        {
            logHeader();
            _frameWriter.writeHeader(AmqpHeader.SASL_HEADER);
            _headerWritten = true;
            return cast(int)(AmqpHeader.SASL_HEADER.length);
        }
        else
        {
            return 0;
        }
    }

    private void logHeader()
    {
        if (_transport.isFrameTracingEnabled())
        {
            _transport.log(TransportImpl.OUTGOING, new String(HEADER_DESCRIPTION));

            ProtocolTracer tracer = _transport.getProtocolTracer();
            if (tracer !is null)
            {
                tracer.sentHeader(HEADER_DESCRIPTION);
            }
        }
    }

    override
    public int pending()
    {
        return _pending is null ? 0 : _pending.remaining();
    }

    void setPending(ByteBuffer pending)
    {
        _pending = pending;
    }

    override
    public SaslState getState()
    {
        return _state;
    }

    Binary getChallengeResponse()
    {
        return _challengeResponse;
    }

    void setChallengeResponse(Binary challengeResponse)
    {
        _challengeResponse = challengeResponse;
    }

    override
    public void setMechanisms(string[] mechanisms)
    {
        if(mechanisms !is null && mechanisms.length != 0)
        {
            _mechanisms = new Symbol[mechanisms.length];
            for(int i = 0; i < mechanisms.length; i++)
            {
                _mechanisms[i] = Symbol.valueOf(mechanisms[i]);
            }
        }

        if(_role == Role.CLIENT)
        {
           // assert mechanisms !is null;
           // assert mechanisms.length == 1;

            _chosenMechanism = Symbol.valueOf(mechanisms[0]);
        }
    }

    override
    public string[] getRemoteMechanisms()
    {
        if(_role == Role.SERVER)
        {
            return _chosenMechanism is null ? [] : [ _chosenMechanism.toString() ];
        }
        else if(_role == Role.CLIENT)
        {
            if(_mechanisms is null)
            {
                return [];
            }
            else
            {
                string[] remoteMechanisms =  new string[_mechanisms.length];
                //string[] remoteMechanisms = ["ANONYMOUS"] ;//= new string[_mechanisms.length];
                //logInfo("length : %d",_mechanisms.length);
                //if (_mechanisms[0] is null)
                //{
                //    logInfo("sssssssssssssssssssssssssssssssssssssss");
                //}
                //logInfo("ccccc %s :",_mechanisms[0].toString);
                foreach (Symbol sy; _mechanisms)
                {
                    remoteMechanisms ~= sy.toString;
                }
                for(int i = 0; i < _mechanisms.length; i++)
                {
                    remoteMechanisms[i] = _mechanisms[i].toString();
                }
                return remoteMechanisms;
            }
        }
        else
        {
            throw new IllegalStateException();
        }
    }

    public void setMechanism(Symbol mechanism)
    {
        _chosenMechanism = mechanism;
    }

    public Symbol getChosenMechanism()
    {
        return _chosenMechanism;
    }

    public void setResponse(Binary initialResponse)
    {
        setPending(initialResponse.asByteBuffer());
    }

    override
    public void handle(SaslFrameBody o, Binary payload)
    {
        SaslMechanisms frameBody = cast(SaslMechanisms)o;
        if (frameBody !is null)
        {
            _transport.log(TransportImpl.INCOMING, frameBody);

            ProtocolTracer tracer = _transport.getProtocolTracer();
            if( tracer !is null )
            {
                tracer.receivedSaslBody(frameBody);
            }

            frameBody.invoke(this, payload, null);
            return;
        }
        hunt.proton.amqp.security.SaslOutcome.SaslOutcome frameBodyOutCome = cast(hunt.proton.amqp.security.SaslOutcome.SaslOutcome)o;
        if (frameBodyOutCome !is null)
        {
            _transport.log(TransportImpl.INCOMING, frameBodyOutCome);

            ProtocolTracer tracer = _transport.getProtocolTracer();
            if( tracer !is null )
            {
                tracer.receivedSaslBody(frameBodyOutCome);
            }

            frameBodyOutCome.invoke(this, payload, null);
            return;
        }
        SaslInit frameBodyInit = cast(SaslInit)o;
        if (frameBodyInit !is null)
        {
            _transport.log(TransportImpl.INCOMING, frameBodyInit);

            ProtocolTracer tracer = _transport.getProtocolTracer();
            if( tracer !is null )
            {
                tracer.receivedSaslBody(frameBodyInit);
            }

            frameBodyInit.invoke(this, payload, null);
            return;
        }

        SaslResponse frameBodyResp = cast(SaslResponse)o;
        if (frameBodyResp !is null)
        {
            _transport.log(TransportImpl.INCOMING, frameBodyResp);

            ProtocolTracer tracer = _transport.getProtocolTracer();
            if( tracer !is null )
            {
                tracer.receivedSaslBody(frameBodyResp);
            }

            frameBodyResp.invoke(this, payload, null);
            return;
        }
        SaslChallenge frameBodyChall = cast(SaslChallenge)o;
        if (frameBodyChall !is null)
        {
            _transport.log(TransportImpl.INCOMING, frameBodyChall);

            ProtocolTracer tracer = _transport.getProtocolTracer();
            if( tracer !is null )
            {
                tracer.receivedSaslBody(frameBodyChall);
            }

            frameBodyChall.invoke(this, payload, null);
            return;
        }


    }

    override
    public void handleInit(SaslInit saslInit, Binary payload, Void context)
    {
        if(_role  == Role.SERVER)
        {
            server();
        }
        checkRole(Role.SERVER);
        _hostname = cast(string)(saslInit.getHostname().getBytes());
        _chosenMechanism = saslInit.getMechanism();
        _initReceived = true;
        if(saslInit.getInitialResponse() !is null)
        {
            setPending(saslInit.getInitialResponse().asByteBuffer());
        }

        if(_saslListener !is null) {
            _saslListener.onSaslInit(this, _transport);
        }
    }

    void invoke(SaslFrameBodyHandler!Void handler, Binary payload, Void context)
    {
        implementationMissing(false);

    }

    override
    public void handleResponse(SaslResponse saslResponse, Binary payload, Void context)
    {
        checkRole(Role.SERVER);
        setPending(saslResponse.getResponse()  is null ? null : saslResponse.getResponse().asByteBuffer());

        if(_saslListener !is null) {
            _saslListener.onSaslResponse(this, _transport);
        }
    }

    override
    public void done(hunt.proton.engine.Sasl.SaslOutcome outcome)
    {
        checkRole(Role.SERVER);
        _outcome = outcome;
        _done = true;
        logInfo("_done true !!!!!!!");
        _state = classifyStateFromOutcome(outcome);
        logInfo("SASL negotiation done");

    }

    private void checkRole(Role role)
    {
        //if(role != _role)
        //{
        //    throw new IllegalStateException("Role is " + to!string(_role) + " but should be " + to!string(role));
        //}
    }

    override
    public void handleMechanisms(SaslMechanisms saslMechanisms, Binary payload, Void context)
    {
        if(_role  == Role.CLIENT)
        {
            client();
        }
        checkRole(Role.CLIENT);
        if (saslMechanisms.getSaslServerMechanisms() is null)
        {
            _mechanisms ~= Symbol.valueOf("ANONYMOUS");
        }
        else {
            _mechanisms = saslMechanisms.getSaslServerMechanisms().toArray();
        }


        if(_saslListener !is null) {
            _saslListener.onSaslMechanisms(this, _transport);
        }
    }

    override
    public void handleChallenge(SaslChallenge saslChallenge, Binary payload, Void context)
    {
        checkRole(Role.CLIENT);
        setPending(saslChallenge.getChallenge()  is null ? null : saslChallenge.getChallenge().asByteBuffer());

        if(_saslListener !is null) {
            _saslListener.onSaslChallenge(this, _transport);
        }
    }

    override
    public void handleOutcome(hunt.proton.amqp.security.SaslOutcome.SaslOutcome saslOutcome,
                              Binary payload,
                              Void context)
    {
        checkRole(Role.CLIENT);
        foreach(hunt.proton.engine.Sasl.SaslOutcome outcome ; hunt.proton.engine.Sasl.SaslOutcome.values())
        {
            setPending(saslOutcome.getAdditionalData()  is null ? null : saslOutcome.getAdditionalData().asByteBuffer());
            if(outcome.getCode() == saslOutcome.getCode().ordinal())
            {
                _outcome = outcome;
                if (_state != SaslState.PN_SASL_IDLE)
                {
                    _state = classifyStateFromOutcome(outcome);
                }
                break;
            }
        }
        _done = true;

        //if(_logger.isLoggable(Level.FINE))
        //{
        //    _logger.fine("Handled outcome: " + this);
        //}

        if(_saslListener !is null) {
            _saslListener.onSaslOutcome(this, _transport);
        }
    }

    private SaslState classifyStateFromOutcome(hunt.proton.engine.Sasl.SaslOutcome outcome)
    {
        return outcome == hunt.proton.engine.Sasl.SaslOutcome.PN_SASL_OK ? SaslState.PN_SASL_PASS : SaslState.PN_SASL_FAIL;
    }

    private void processResponse()
    {
        SaslResponse response = new SaslResponse();
        response.setResponse(getChallengeResponse());
        setChallengeResponse(null);
        writeFrame(response);
    }

    private void processInit()
    {
        SaslInit init = new SaslInit();

        init.setHostname(_hostname is null? null : new String(_hostname));
        init.setMechanism(_chosenMechanism);
        if(getChallengeResponse() !is null)
        {
            init.setInitialResponse(getChallengeResponse());
            setChallengeResponse(null);
        }
        _initSent = true;
        logInfo("_initSent   true !!!!!!!!!!!!!!");
        writeFrame(init);
    }

    public void plain(String username, String password)
    {
        client();
        _chosenMechanism = Symbol.valueOf("PLAIN");
        byte[] usernameBytes = username.getBytes();
        byte[] passwordBytes = password.getBytes();
        byte[] data = new byte[usernameBytes.length+passwordBytes.length+2];
        //System.arraycopy(usernameBytes, 0, data, 1, usernameBytes.length);
        data[1 .. 1+usernameBytes.length] = usernameBytes[0 .. usernameBytes.length ];
      //  System.arraycopy(passwordBytes, 0, data, 2+usernameBytes.length, passwordBytes.length);
        data[2+usernameBytes.length .. 2+usernameBytes.length+passwordBytes.length] = passwordBytes[0 .. passwordBytes.length];
        setChallengeResponse(new Binary(data));
    }

    override
    public hunt.proton.engine.Sasl.SaslOutcome getOutcome()
    {
        return _outcome;
    }

    override
    public void client()
    {
        _role = Role.CLIENT;
        if(_mechanisms !is null)
        {
            //assert _mechanisms.length == 1;

            _chosenMechanism = _mechanisms[0];
        }
    }

    override
    public void server()
    {
        _role = Role.SERVER;
    }

    override
    public void allowSkip(bool allowSkip)
    {
        _allowSkip = allowSkip;
    }

    override
    public TransportWrapper wrap(TransportInput input, TransportOutput output)
    {
        return new class SaslSniffer {

            this()
            {
                super(new SwitchingSaslTransportWrapper(input, output),new PlainTransportWrapper(output, input));
            }

            override
            protected bool isDeterminationMade() {
                if (_role == Role.SERVER && _allowSkip) {
                    return super.isDeterminationMade();
                } else {
                    _selectedTransportWrapper = _wrapper1;
                    return true;
                }
            }
        };
    }

    //override
    //public String toString()
    //{
    //    StringBuilder builder = new StringBuilder();
    //    builder
    //        .append("SaslImpl [_outcome=").append(_outcome)
    //        .append(", state=").append(_state)
    //        .append(", done=").append(_done)
    //        .append(", role=").append(_role)
    //        .append("]");
    //    return builder.toString();
    //}

    class SaslTransportWrapper : TransportWrapper
    {
        private TransportInput _underlyingInput;
        private TransportOutput _underlyingOutput;
        private bool _outputComplete;

        private ByteBuffer _outputBuffer;
        private ByteBuffer _inputBuffer;
        private ByteBuffer _head;

        private SwitchingSaslTransportWrapper _parent;

        this(SwitchingSaslTransportWrapper parent, TransportInput input, TransportOutput output)
        {
            _underlyingInput = input;
            _underlyingOutput = output;

            _inputBuffer = ByteBufferUtils.newWriteableBuffer(_maxFrameSize);
            _outputBuffer = ByteBufferUtils.newWriteableBuffer(_maxFrameSize);

            _parent = parent;

            if (_transport.isUseReadOnlyOutputBuffer()) {
                _head = _outputBuffer.asReadOnlyBuffer();
            } else {
                _head = _outputBuffer.duplicate();
            }

            _head.limit(0);
        }

        private void fillOutputBuffer()
        {
            if(isOutputInSaslMode())
            {
                writeSaslOutput();
                if(_done)
                {
                    _outputComplete = true;
                }
            }
        }

        /**
         * TODO rationalise this method with respect to the other similar checks of _role/_initReceived etc
         * @see SaslImpl#isDone()
         */
        private bool isInputInSaslMode()
        {
            return  (_role == Role.CLIENT && !_done) || (_role == Role.SERVER && (!_initReceived || !_done));
        }

        private bool isOutputInSaslMode()
        {
            return  (_role == Role.CLIENT && (!_done || !_initSent)) || (_role == Role.SERVER && !_outputComplete);
        }

        override
        public int capacity()
        {
            if (_tail_closed) return Transport.END_OF_STREAM;
            if (isInputInSaslMode())
            {
                return _inputBuffer.remaining();
            }
            else
            {
                return _underlyingInput.capacity();
            }
        }

        override
        public int position()
        {
            if (_tail_closed) return Transport.END_OF_STREAM;
            if (isInputInSaslMode())
            {
                return _inputBuffer.position();
            }
            else
            {
                return _underlyingInput.position();
            }
        }

        override
        public ByteBuffer tail()
        {
            if (!isInputInSaslMode())
            {
                return _underlyingInput.tail();
            }

            return _inputBuffer;
        }

        override
        public void process()
        {
            _inputBuffer.flip();

            try
            {
                reallyProcessInput();
            }
            finally
            {
                _inputBuffer.compact();
            }
        }

        override
        public void close_tail()
        {
            _tail_closed = true;
            if (isInputInSaslMode()) {
                _head_closed = true;
                _underlyingInput.close_tail();
            } else {
                _underlyingInput.close_tail();
            }
        }

        private void reallyProcessInput()
        {
            if(isInputInSaslMode())
            {
                //if(_logger.isLoggable(Level.FINER))
                //{
                //    _logger.log(Level.FINER, SaslImpl.this + " about to call input.");
                //}

                _frameParser.input(_inputBuffer);
            }

            if(!isInputInSaslMode())
            {
                //if(_logger.isLoggable(Level.FINER))
                //{
                //    _logger.log(Level.FINER, SaslImpl.this + " about to call plain input");
                //}

                if (_inputBuffer.hasRemaining())
                {
                    int bytes = ByteBufferUtils.pourAll(_inputBuffer, _underlyingInput);
                    if (bytes == Transport.END_OF_STREAM)
                    {
                        _tail_closed = true;
                    }

                    if (!_inputBuffer.hasRemaining())
                    {
                        _parent.switchToNextInput();
                    }
                }
                else
                {
                    _parent.switchToNextInput();
                }

                _underlyingInput.process();
            }
        }

        override
        public int pending()
        {
            logInfo("isOutputInSaslMode : %d  -----------pos: %d",isOutputInSaslMode(),_outputBuffer.position());
            if (isOutputInSaslMode() || _outputBuffer.position() != 0)
            {
                logInfo("saslimpl pending ...... in !!!!!");
                fillOutputBuffer();
                _head.limit(_outputBuffer.position());

                if (_head_closed && _outputBuffer.position() == 0)
                {
                    return Transport.END_OF_STREAM;
                }
                else
                {
                    return _outputBuffer.position();
                }
            }
            else
            {
                logInfo("saslimpl pending ...... out !!!!!");
                _parent.switchToNextOutput();
                return _underlyingOutput.pending();
            }
        }

        override
        public ByteBuffer head()
        {
            if (isOutputInSaslMode() || _outputBuffer.position() != 0)
            {
                pending();
                return _head;
            }
            else
            {
                _parent.switchToNextOutput();
                return _underlyingOutput.head();
            }
        }

        override
        public void pop(int bytes)
        {
            if (isOutputInSaslMode() || _outputBuffer.position() != 0)
            {
                _outputBuffer.flip();
                _outputBuffer.position(bytes);
                _outputBuffer.compact();
                _head.position(0);
                _head.limit(_outputBuffer.position());
            }
            else
            {
                _parent.switchToNextOutput();
                _underlyingOutput.pop(bytes);
            }
        }

        override
        public void close_head()
        {
            _parent.switchToNextOutput();
            _underlyingOutput.close_head();
        }

        private void writeSaslOutput()
        {
            this.outer.process();
            _frameWriter.readBytes(_outputBuffer);
            //logInfo("Finished writing SASL output. Output Buffer : %s", _outputBuffer.getRemaining());

            //if(_logger.isLoggable(Level.FINER))
            //{
            //    _logger.log(Level.FINER, "Finished writing SASL output. Output Buffer : " + _outputBuffer);
            //}
        }
    }

     class SwitchingSaslTransportWrapper : TransportWrapper {

        private TransportInput _underlyingInput;
        private TransportOutput _underlyingOutput;

        private TransportInput currentInput;
        private TransportOutput currentOutput;

        this(TransportInput input, TransportOutput output) {
            _underlyingInput = input;
            _underlyingOutput = output;

            // The wrapper can be GC'd after both current's are switched to next.
            SaslTransportWrapper saslProcessor = new SaslTransportWrapper(this, input, output);

            currentInput = saslProcessor;
            currentOutput = saslProcessor;
        }

        public int capacity() {
            return currentInput.capacity();
        }

        public int position() {
            return currentInput.position();
        }

        public ByteBuffer tail()  {
            return currentInput.tail();
        }

        public void process()  {
            currentInput.process();
        }

        public void close_tail() {
            currentInput.close_tail();
        }

        public int pending() {
            return currentOutput.pending();
        }

        public ByteBuffer head() {
            return currentOutput.head();
        }

        public void pop(int bytes) {
            currentOutput.pop(bytes);
        }

        public void close_head() {
            currentOutput.close_head();
        }

        void switchToNextInput() {
            currentInput = _underlyingInput;
        }

        void switchToNextOutput() {
            currentOutput = _underlyingOutput;
        }
    }

    public string getHostname()
    {
        //if(_role = Role.CLIENT)
        //{
        //    checkRole(Role.SERVER);
        //}

        return _hostname;
    }

    public void setRemoteHostname(string hostname)
    {
        //if(_role !is null)
        //{
        //    checkRole(Role.CLIENT);
        //}

        _hostname = hostname;
    }

    override
    public void setListener(SaslListener saslListener) {
        _saslListener = saslListener;
    }
}
