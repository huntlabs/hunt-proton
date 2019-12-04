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
module hunt.proton.engine.SslPeerDetails;

import hunt.proton.engine.impl.ssl.SslPeerDetailsImpl;

/**
 * The details of the remote peer involved in an SSL session.
 *
 * Used when creating an SSL session to hint that the underlying SSL implementation
 * should attempt to resume a previous session if one exists for the same peer details,
 * e.g. using session identifiers (http://tools.ietf.org/html/rfc5246) or session tickets
 * (http://tools.ietf.org/html/rfc5077).
 */
interface SslPeerDetails
{

    class Factory
    {
        public static SslPeerDetails create(string hostname, int port) {
            return new SslPeerDetailsImpl(hostname, port);
        }
    }

    string getHostname();
    int getPort();
}
