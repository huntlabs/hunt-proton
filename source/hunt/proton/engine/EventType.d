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

module hunt.proton.engine.EventType;

/**
 * Entry point for external libraries to add event types. Event types should be
 * <code>static</code> fields. EventType instances are compared by
 * reference.
 * <p>
 * Event types are best described by an <code>enum</code> that implements the
 * {@link EventType} interface, see {@link Event.Type}.
 * 
 */
interface EventType {

    /**
     * @return false if this particular EventType instance does not represent a
     *         real event type but a guard value, example: extra enum value for
     *         switch statements, see {@link Event.Type#NON_CORE_EVENT}
     */
    public bool isValid();
}
