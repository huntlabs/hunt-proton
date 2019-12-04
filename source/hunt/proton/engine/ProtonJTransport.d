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
module hunt.proton.engine.ProtonJTransport;

import hunt.proton.engine.Transport;
import hunt.proton.engine.impl.ProtocolTracer;


/**
 * Extends {@link Transport} with functionality that is specific to proton-j
 */
interface ProtonJTransport : Transport
{
    void setProtocolTracer(ProtocolTracer protocolTracer);

    ProtocolTracer getProtocolTracer();
}
