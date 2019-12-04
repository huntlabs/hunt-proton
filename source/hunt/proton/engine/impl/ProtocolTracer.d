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

module hunt.proton.engine.impl.ProtocolTracer;

import hunt.proton.amqp.security.SaslFrameBody;
import hunt.proton.framing.TransportFrame;

/**
 * @author <a href="http://hiramchirino.com">Hiram Chirino</a>
 */

interface ProtocolTracer
{
    public void receivedFrame(TransportFrame transportFrame);
    public void sentFrame(TransportFrame transportFrame);

     void receivedSaslBody(SaslFrameBody saslFrameBody);
     void sentSaslBody(SaslFrameBody saslFrameBody);

     void receivedHeader(string header) ;
     void sentHeader(string header) ;
}
