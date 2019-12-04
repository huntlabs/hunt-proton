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

module hunt.proton.engine.impl.SaslSniffer;

import hunt.proton.engine.impl.TransportWrapper;
import hunt.proton.engine.impl.HandshakeSniffingTransportWrapper;
import hunt.proton.engine.impl.AmqpHeader;
import hunt.Exceptions;
/**
 * SaslSniffer
 *
 */

class SaslSniffer : HandshakeSniffingTransportWrapper!(TransportWrapper, TransportWrapper)
{

    this(TransportWrapper sasl, TransportWrapper other) {
        super(sasl, other);
    }

    override
    protected int bufferSize() { return cast(int)(AmqpHeader.SASL_HEADER.length); }

    override
    protected void makeDetermination(byte[] bytes) {
        if (bytes.length < bufferSize()) {
            throw new IllegalArgumentException("insufficient bytes");
        }

        for (int i = 0; i < AmqpHeader.SASL_HEADER.length; i++) {
            if (bytes[i] != AmqpHeader.SASL_HEADER[i]) {
                _selectedTransportWrapper = _wrapper2;
                return;
            }
        }

        _selectedTransportWrapper = _wrapper1;
    }

}
