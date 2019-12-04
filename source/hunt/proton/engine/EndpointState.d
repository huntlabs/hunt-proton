module hunt.proton.engine.EndpointState;
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


/**
 * Represents the state of a communication endpoint.
 */
enum EndpointState
{
    UNINITIALIZED,
    ACTIVE,
    CLOSED,
}
