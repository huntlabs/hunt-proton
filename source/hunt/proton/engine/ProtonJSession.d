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
module hunt.proton.engine.ProtonJSession;

import hunt.proton.engine.Sender;
import hunt.proton.engine.Session;
import hunt.proton.engine.ProtonJEndpoint;
/**
 * Extends {@link Session} with functionality that is specific to proton-j
 */
interface ProtonJSession : Session, ProtonJEndpoint
{
    Sender sender(string name);
}
