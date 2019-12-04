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


module hunt.proton.amqp.messaging.DeleteOnClose;

import hunt.proton.amqp.messaging.LifetimePolicy;

class DeleteOnClose : LifetimePolicy
{
   // private static DeleteOnClose INSTANCE = new DeleteOnClose();
    __gshared DeleteOnClose INSTANCE = null;


    this()
    {
    }


    public static DeleteOnClose getInstance()
    {
        if (INSTANCE is null)
            INSTANCE = new DeleteOnClose();
        return INSTANCE;
    }
}
  