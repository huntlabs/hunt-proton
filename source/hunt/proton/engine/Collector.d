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

module hunt.proton.engine.Collector;

import hunt.proton.engine.impl.CollectorImpl;
import hunt.proton.engine.Event;
/**
 * Collector
 *
 */
import hunt.proton.engine.Event;

interface Collector
{

    class Factory
    {
        public static Collector create() {
            return new CollectorImpl();
        }
    }

    Event peek();

    void pop();

    bool more();
}
