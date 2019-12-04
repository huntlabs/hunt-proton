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

module hunt.proton.engine.ReactorChild;

/**
 * Interface used to identify classes that can be a child of a reactor.
 */
interface ReactorChild {

    /** Frees any resources associated with this child. */
    void free();

    int opCmp(ReactorChild o );
}
