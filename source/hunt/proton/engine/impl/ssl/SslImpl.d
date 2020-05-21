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

module hunt.proton.engine.impl.ssl.SslImpl;

import hunt.io.ByteBuffer;

import hunt.proton.engine.impl.ssl.SslHandshakeSniffingTransportWrapper;
import hunt.proton.engine.Ssl;
import hunt.proton.engine.SslDomain;
import hunt.proton.engine.SslPeerDetails;
import hunt.proton.engine.Transport;
import hunt.proton.engine.TransportException;
import hunt.proton.engine.impl.PlainTransportWrapper;
import hunt.proton.engine.impl.TransportInput;
import hunt.proton.engine.impl.TransportLayer;
import hunt.proton.engine.impl.TransportOutput;
import hunt.proton.engine.impl.TransportWrapper;
import hunt.proton.engine.impl.ssl.SslTransportWrapper;
import hunt.proton.engine.impl.ssl.ProtonSslEngineProvider;
import hunt.proton.engine.impl.ssl.SimpleSslTransportWrapper;
import hunt.Exceptions;

//class SslImpl : Ssl, TransportLayer
//{
//    private SslTransportWrapper _unsecureClientAwareTransportWrapper;
//
//    private SslDomain _domain;
//    private ProtonSslEngineProvider _protonSslEngineProvider;
//
//    private SslPeerDetails _peerDetails;
//    private TransportException _initException;
//
//    /**
//     * @param domain must implement {@link hunt.proton.engine.impl.ssl.ProtonSslEngineProvider}. This is not possible
//     * enforce at the API level because {@link hunt.proton.engine.impl.ssl.ProtonSslEngineProvider} is not part of the
//     * public Proton API.
//     */
//    this(SslDomain domain, SslPeerDetails peerDetails)
//    {
//        _domain = domain;
//        _protonSslEngineProvider = cast(ProtonSslEngineProvider)domain;
//        _peerDetails = peerDetails;
//
//        if(_domain.getMode() is null) {
//            throw new IllegalStateException("Client/server mode must be configured, SslDomain must have init called.");
//        }
//
//        if(_peerDetails is null && _domain.getPeerAuthentication() == VerifyMode.VERIFY_PEER_NAME) {
//            throw new IllegalArgumentException("Peer hostname verification is enabled, but no peer details were provided");
//        }
//    }
//
//    public TransportWrapper wrap(TransportInput inputProcessor, TransportOutput outputProcessor)
//    {
//        if (_unsecureClientAwareTransportWrapper !is null)
//        {
//            throw new IllegalStateException("Transport already wrapped");
//        }
//
//        _unsecureClientAwareTransportWrapper = new UnsecureClientAwareTransportWrapper(inputProcessor, outputProcessor);
//        return _unsecureClientAwareTransportWrapper;
//    }
//
//
//    public string getCipherName()
//    {
//        if(_unsecureClientAwareTransportWrapper is null)
//        {
//            throw new IllegalStateException("Transport wrapper is uninitialised");
//        }
//
//        return _unsecureClientAwareTransportWrapper.getCipherName();
//    }
//
//
//    public string getProtocolName()
//    {
//        if(_unsecureClientAwareTransportWrapper is null)
//        {
//            throw new IllegalStateException("Transport wrapper is uninitialised");
//        }
//
//        return _unsecureClientAwareTransportWrapper.getProtocolName();
//    }
//
//    class UnsecureClientAwareTransportWrapper : SslTransportWrapper
//    {
//        private TransportInput _inputProcessor;
//        private TransportOutput _outputProcessor;
//        private SslTransportWrapper _transportWrapper;
//
//        this(TransportInput inputProcessor,
//                TransportOutput outputProcessor)
//        {
//            _inputProcessor = inputProcessor;
//            _outputProcessor = outputProcessor;
//        }
//
//
//        public int capacity()
//        {
//            initTransportWrapperOnFirstIO();
//            if (_initException is null) {
//                return _transportWrapper.capacity();
//            } else {
//                return Transport.END_OF_STREAM;
//            }
//        }
//
//
//        public int position()
//        {
//            initTransportWrapperOnFirstIO();
//            if (_initException is null) {
//                return _transportWrapper.position();
//            } else {
//                return Transport.END_OF_STREAM;
//            }
//        }
//
//
//        public ByteBuffer tail()
//        {
//            initTransportWrapperOnFirstIO();
//            if (_initException is null) {
//                return _transportWrapper.tail();
//            } else {
//                return null;
//            }
//        }
//
//
//
//        public void process()
//        {
//            initTransportWrapperOnFirstIO();
//            if (_initException is null) {
//                _transportWrapper.process();
//            } else {
//                throw new TransportException(_initException);
//            }
//        }
//
//
//        public void close_tail()
//        {
//            initTransportWrapperOnFirstIO();
//            if (_initException is null) {
//                _transportWrapper.close_tail();
//            }
//        }
//
//
//        public int pending()
//        {
//            initTransportWrapperOnFirstIO();
//            if (_initException is null) {
//                return _transportWrapper.pending();
//            } else {
//                throw new TransportException(_initException);
//            }
//        }
//
//
//        public ByteBuffer head()
//        {
//            initTransportWrapperOnFirstIO();
//            if (_initException is null) {
//                return _transportWrapper.head();
//            } else {
//                return null;
//            }
//        }
//
//
//        public void pop(int bytes)
//        {
//            initTransportWrapperOnFirstIO();
//            if (_initException is null) {
//                _transportWrapper.pop(bytes);
//            }
//        }
//
//
//        public void close_head()
//        {
//            initTransportWrapperOnFirstIO();
//            if (_initException is null) {
//                _transportWrapper.close_head();
//            }
//        }
//
//
//        public string getCipherName()
//        {
//            if (_transportWrapper is null)
//            {
//                return null;
//            }
//            else
//            {
//                return _transportWrapper.getCipherName();
//            }
//        }
//
//
//        public string getProtocolName()
//        {
//            if(_transportWrapper is null)
//            {
//                return null;
//            }
//            else
//            {
//                return _transportWrapper.getProtocolName();
//            }
//        }
//
//        private void initTransportWrapperOnFirstIO()
//        {
//            try {
//                if (_initException is null && _transportWrapper is null)
//                {
//                    SslTransportWrapper sslTransportWrapper = new SimpleSslTransportWrapper
//                        (_protonSslEngineProvider.createSslEngine(_peerDetails),
//                         _inputProcessor, _outputProcessor);
//
//                    if (_domain.allowUnsecuredClient() && _domain.getMode() == SslDomain.Mode.SERVER)
//                    {
//                        TransportWrapper plainTransportWrapper = new PlainTransportWrapper
//                            (_outputProcessor, _inputProcessor);
//                        _transportWrapper = new SslHandshakeSniffingTransportWrapper
//                            (sslTransportWrapper, plainTransportWrapper);
//                    }
//                    else
//                    {
//                        _transportWrapper = sslTransportWrapper;
//                    }
//                }
//            } catch (TransportException e) {
//                _initException = e;
//            }
//        }
//    }
//
//    /**
//     * {@inheritDoc}
//     * @throws ProtonUnsupportedOperationException
//     */
//
//    public void setPeerHostname(string hostname)
//    {
//        implementationMissing(false);
//        //throw new ProtonUnsupportedOperationException();
//    }
//
//    /**
//     * {@inheritDoc}
//     * @throws ProtonUnsupportedOperationException
//     */
//
//    public string getPeerHostname()
//    {
//        implementationMissing(false);
//       // throw new ProtonUnsupportedOperationException();
//    }
//}
