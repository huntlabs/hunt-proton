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

module hunt.proton.engine.impl.ssl.SslHandshakeSniffingTransportWrapper;

import hunt.proton.engine.impl.HandshakeSniffingTransportWrapper;
import hunt.proton.engine.impl.TransportWrapper;
import hunt.proton.engine.impl.ssl.SslTransportWrapper;
import std.conv:to;
import hunt.Exceptions;
import hunt.io.ByteBuffer;
/**
 * SslHandshakeSniffingTransportWrapper
 *
 */

class SslHandshakeSniffingTransportWrapper : HandshakeSniffingTransportWrapper!(SslTransportWrapper, TransportWrapper)
    , SslTransportWrapper
{

    this(SslTransportWrapper ssl, TransportWrapper plain) {
        super(ssl, plain);
    }

    public string getCipherName()
    {
        if(isSecureWrapperSelected())
        {
            return _wrapper1.getCipherName();
        }
        else
        {
            return null;
        }
    }


    public string getProtocolName()
    {
        if (isSecureWrapperSelected())
        {
            return _wrapper1.getProtocolName();
        }
        else
        {
            return null;
        }
    }

    override
    int pending()
    {
        return super.pending();
    }

    override
     ByteBuffer head()
     {
         return super.head();
     }

    override void pop(int bytes)
    {
        return super.pop(bytes);
    }

    override void close_head()
    {
        super.close_head();
    }

    private bool isSecureWrapperSelected()
    {
        return _selectedTransportWrapper == _wrapper1;
    }

    override
    protected int bufferSize() {
        // minimum length for determination
        return 5;
    }

    override
    protected void makeDetermination(byte[] bytesInput)
    {
        bool isSecure = checkForSslHandshake(bytesInput);
        if (isSecure)
        {
            _selectedTransportWrapper = _wrapper1;
        }
        else
        {
            _selectedTransportWrapper = _wrapper2;
        }
    }

    // TODO perhaps the sniffer should save up the bytes from each
    // input call until it has sufficient bytes to make the determination
    // and only then pass them to the secure or plain wrapped transport?
    private bool checkForSslHandshake(byte[] buf)
    {
        if (buf.length >= bufferSize())
        {
            /*
             * SSLv2 Client Hello format
             * http://www.mozilla.org/projects/security/pki/nss/ssl/draft02.html
             *
             * Bytes 0-1: RECORD-LENGTH Byte 2: MSG-CLIENT-HELLO (1) Byte 3:
             * CLIENT-VERSION-MSB Byte 4: CLIENT-VERSION-LSB
             *
             * Allowed versions: 2.0 - SSLv2 3.0 - SSLv3 3.1 - TLS 1.0 3.2 - TLS
             * 1.1 3.3 - TLS 1.2
             *
             * The version sent in the Client-Hello is the latest version
             * supported by the client. NSS may send version 3.x in an SSLv2
             * header for maximum compatibility.
             */
            bool isSSL2Handshake = buf[2] == 1 && // MSG-CLIENT-HELLO
                    ((buf[3] == 3 && buf[4] <= 3) || // SSL 3.0 & TLS 1.0-1.2
                                                     // (v3.1-3.3)
                    (buf[3] == 2 && buf[4] == 0)); // SSL 2

            /*
             * SSLv3/TLS Client Hello format RFC 2246
             *
             * Byte 0: ContentType (handshake - 22) Bytes 1-2: ProtocolVersion
             * {major, minor}
             *
             * Allowed versions: 3.0 - SSLv3 3.1 - TLS 1.0 3.2 - TLS 1.1 3.3 -
             * TLS 1.2
             */
            bool isSSL3Handshake = buf[0] == 22 && // handshake
                    (buf[1] == 3 && buf[2] <= 3); // SSL 3.0 & TLS 1.0-1.2
                                                  // (v3.1-3.3)

            return (isSSL2Handshake || isSSL3Handshake);
        }
        else
        {
            throw new IllegalArgumentException("Too few bytes (" ~ to!string(buf.length) ~ ") to make SSL/plain  determination.");
        }
    }

}
