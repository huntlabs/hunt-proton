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
module hunt.proton.engine.impl.ssl.SslPeerDetailsImpl;

import hunt.proton.engine.ProtonJSslPeerDetails;


class SslPeerDetailsImpl : ProtonJSslPeerDetails
{
    private string _hostname;
    private int _port;

    /**
     * Application code should use {@link hunt.proton.engine.SslPeerDetails.Factory#create(String, int)} instead.
     */
    this(string hostname, int port)
    {
        _hostname = hostname;
        _port = port;
    }

    public string getHostname()
    {
        return _hostname;
    }

    public int getPort()
    {
        return _port;
    }
}
