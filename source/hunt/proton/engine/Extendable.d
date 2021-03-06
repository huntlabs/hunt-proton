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

module hunt.proton.engine.Extendable;
import hunt.proton.engine.Record;

/**
 * Extendable
 *
 */

interface Extendable
{

    Record attachments();

}
