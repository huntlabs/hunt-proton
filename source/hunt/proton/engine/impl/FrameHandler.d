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

module hunt.proton.engine.impl.FrameHandler;

import hunt.proton.engine.TransportException;
import hunt.proton.framing.TransportFrame;

interface FrameHandler
{
    /**
     * @throws IllegalStateException if I am not currently accepting input
     * @see #isHandlingFrames()
     * @return false on end of stream
     */
    bool handleFrame(TransportFrame frame);

    void closed(TransportException error);

    /**
     * Returns whether I am currently able to handle frames.
     * MUST be checked before calling {@link #handleFrame(TransportFrame)}.
     */
    bool isHandlingFrames();

}
