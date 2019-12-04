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

module hunt.proton.engine.impl.TransportInternal;
import hunt.proton.engine.impl.TransportLayer;
import hunt.proton.engine.Transport;

/**
 * Extended Transport interface providing access to certain methods intended mainly for internal
 * use, or use in extending implementation details not strictly considered part of the public
 * Transport API.
 */
interface TransportInternal : Transport
{
    /**
     * Add a {@link TransportLayer} to the transport, wrapping the input and output process handlers
     * in the state they currently exist. No effect if the given layer was previously added.
     *
     * @param layer the layer to add (if it was not previously added)
     * @throws IllegalStateException if processing has already started.
     */
    void addTransportLayer(TransportLayer layer);

    void setUseReadOnlyOutputBuffer(bool value);

    bool isUseReadOnlyOutputBuffer();

}
