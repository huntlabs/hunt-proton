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

module hunt.proton.engine.impl.TransportLayer;

import hunt.proton.engine.impl.TransportInput;
import hunt.proton.engine.impl.TransportOutput;
import hunt.proton.engine.impl.TransportWrapper;

interface TransportLayer
{
    public TransportWrapper wrap(TransportInput input, TransportOutput output);
}