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
module hunt.proton.engine.ProtonJConnection;

import hunt.proton.engine.Connection;
import hunt.proton.engine.ProtonJEndpoint;
import hunt.proton.engine.ProtonJSession;

/**
 * Extends {@link Connection} with functionality that is specific to proton-j
 */
interface ProtonJConnection : Connection, ProtonJEndpoint
{
    void setLocalContainerId(string localContainerId);

    ProtonJSession session();

    int getMaxChannels();
}
