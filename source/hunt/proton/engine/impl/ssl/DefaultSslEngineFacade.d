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
module hunt.proton.engine.impl.ssl.DefaultSslEngineFacade;

//import hunt.collection.ByteBuffer;
//
//import javax.net.ssl.SSLEngine;
//import javax.net.ssl.SSLEngineResult;
//import javax.net.ssl.SSLEngineResult.HandshakeStatus;
//import javax.net.ssl.SSLEngineResult.Status;
//import javax.net.ssl.SSLException;
//import javax.net.ssl.SSLSession;
//
//
//class DefaultSslEngineFacade : ProtonSslEngine
//{
//    private SSLEngine _sslEngine;
//
//    /**
//     * Our testing has shown that application buffers need to be a bit larger
//     * than that provided by {@link SSLSession#getApplicationBufferSize()} otherwise
//     * {@link Status#BUFFER_OVERFLOW} will result on {@link SSLEngine#unwrap}.
//     * Sun's own example uses 50, so we use the same.
//     */
//    private static int APPLICATION_BUFFER_EXTRA = 50;
//
//    DefaultSslEngineFacade(SSLEngine sslEngine)
//    {
//        _sslEngine = sslEngine;
//    }
//
//    @Override
//    public SSLEngineResult wrap(ByteBuffer src, ByteBuffer dst) throws SSLException
//    {
//        return _sslEngine.wrap(src, dst);
//    }
//
//    @Override
//    public SSLEngineResult unwrap(ByteBuffer src, ByteBuffer dst) throws SSLException
//    {
//        return _sslEngine.unwrap(src, dst);
//    }
//
//    /**
//     * @see #APPLICATION_BUFFER_EXTRA
//     */
//    @Override
//    public int getEffectiveApplicationBufferSize()
//    {
//        return getApplicationBufferSize() + APPLICATION_BUFFER_EXTRA;
//    }
//
//    private int getApplicationBufferSize()
//    {
//        return _sslEngine.getSession().getApplicationBufferSize();
//    }
//
//    @Override
//    public int getPacketBufferSize()
//    {
//        return _sslEngine.getSession().getPacketBufferSize();
//    }
//
//    @Override
//    public String getCipherSuite()
//    {
//        return _sslEngine.getSession().getCipherSuite();
//    }
//
//    @Override
//    public String getProtocol()
//    {
//        return _sslEngine.getSession().getProtocol();
//    }
//
//    @Override
//    public Runnable getDelegatedTask()
//    {
//        return _sslEngine.getDelegatedTask();
//    }
//
//    @Override
//    public HandshakeStatus getHandshakeStatus()
//    {
//        return _sslEngine.getHandshakeStatus();
//    }
//
//    @Override
//    public boolean getUseClientMode()
//    {
//        return _sslEngine.getUseClientMode();
//    }
//
//    @Override
//    public String toString()
//    {
//        StringBuilder builder = new StringBuilder();
//        builder.append("DefaultSslEngineFacade [_sslEngine=").append(_sslEngine).append("]");
//        return builder.toString();
//    }
//
//}
