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
module hunt.proton.engine.impl.ssl.SslTransportWrapper;

import hunt.proton.engine.impl.TransportWrapper;

interface SslTransportWrapper : TransportWrapper
{
    string getCipherName();
    string getProtocolName();
}
