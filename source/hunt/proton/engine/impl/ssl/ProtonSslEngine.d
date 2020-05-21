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
module hunt.proton.engine.impl.ssl.ProtonSslEngine;

import hunt.io.ByteBuffer;

//import javax.net.ssl.SSLEngine;
//import javax.net.ssl.SSLEngineResult;
//import javax.net.ssl.SSLEngineResult.HandshakeStatus;
//import javax.net.ssl.SSLEngineResult.Status;
//import javax.net.ssl.SSLException;
//
///**
// * Thin wrapper around an {@link SSLEngine}.
// */
//interface ProtonSslEngine
//{
//    /**
//     * @see SSLEngine#wrap(ByteBuffer, ByteBuffer)
//     *
//     * Note that wrap really does write <em>one</em> packet worth of data to the
//     * dst byte buffer.  If dst byte buffer is insufficiently large the
//     * pointers within both src and dst are unchanged and the bytesConsumed and
//     * bytesProduced on the returned result are zero.
//     */
//    SSLEngineResult wrap(ByteBuffer src, ByteBuffer dst) throws SSLException;
//
//    /**
//     * @see SSLEngine#unwrap(ByteBuffer, ByteBuffer)
//     *
//     * Note that unwrap does read exactly one packet of encoded data from src
//     * and write to dst.  If src contains insufficient bytes to read a complete
//     * packet {@link Status#BUFFER_UNDERFLOW} occurs.  If underflow occurs the
//     * pointers within both src and dst are unchanged and the bytesConsumed and
//     * bytesProduced on the returned result are zero.
//    */
//    SSLEngineResult unwrap(ByteBuffer src, ByteBuffer dst) throws SSLException;
//
//    Runnable getDelegatedTask();
//    HandshakeStatus getHandshakeStatus();
//
//    /**
//     * Gets the application buffer size.
//     */
//    int getEffectiveApplicationBufferSize();
//
//    int getPacketBufferSize();
//    String getCipherSuite();
//    String getProtocol();
//    boolean getUseClientMode();
//
//}
