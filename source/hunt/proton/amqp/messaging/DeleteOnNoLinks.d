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


module hunt.proton.amqp.messaging.DeleteOnNoLinks;

import hunt.proton.amqp.messaging.LifetimePolicy;

class DeleteOnNoLinks : LifetimePolicy
{

   // private static DeleteOnNoLinks INSTANCE = new DeleteOnNoLinks();
    __gshared DeleteOnNoLinks INSTANCE = null;

    public static DeleteOnNoLinks getInstance()
    {
        if (INSTANCE is null)
            INSTANCE = new DeleteOnNoLinks();
        return INSTANCE;
    }
}
  