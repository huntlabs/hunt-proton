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

module hunt.proton.engine.Engine;

/**
 * Engine
 *
 */
import hunt.proton.engine.Collector;
import hunt.proton.engine.Connection;
import hunt.proton.engine.Transport;
import hunt.proton.engine.SslDomain;
import hunt.proton.engine.SslPeerDetails;

class Engine
{

    this()
    {
    }

    public static Collector collector()
    {
        return Collector.Factory.create();
    }

    public static Connection connection()
    {
        return Connection.Factory.create();
    }

    public static Transport transport()
    {
        return Transport.Factory.create();
    }

    public static SslDomain sslDomain()
    {
        return SslDomain.Factory.create();
    }

    public static SslPeerDetails sslPeerDetails(string hostname, int port)
    {
        return SslPeerDetails.Factory.create(hostname, port);
    }

}
