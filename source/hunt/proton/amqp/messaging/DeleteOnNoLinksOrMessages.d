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


module hunt.proton.amqp.messaging.DeleteOnNoLinksOrMessages;

import hunt.proton.amqp.messaging.LifetimePolicy;
class DeleteOnNoLinksOrMessages : LifetimePolicy
{
     __gshared DeleteOnNoLinksOrMessages INSTANCE = null;

    public static DeleteOnNoLinksOrMessages getInstance()
    {
        if (INSTANCE is null)
            INSTANCE = new DeleteOnNoLinksOrMessages();
        return INSTANCE;
    }
}
  