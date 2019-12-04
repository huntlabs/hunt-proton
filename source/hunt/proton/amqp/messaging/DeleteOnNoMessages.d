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


module hunt.proton.amqp.messaging.DeleteOnNoMessages;

import hunt.proton.amqp.messaging.LifetimePolicy;

class DeleteOnNoMessages : LifetimePolicy
{
    __gshared DeleteOnNoMessages INSTANCE = null;

    public static DeleteOnNoMessages getInstance()
    {
        if (INSTANCE is null)
            INSTANCE = new DeleteOnNoMessages();
        return INSTANCE;
    }
}
  