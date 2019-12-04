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

module hunt.proton.engine.impl.Ref;


/**
 * Ref
 *
 */

class Ref(T)
{

    T value;

    this(T initial) {
        value = initial;
    }

    public T get() {
        return value;
    }

    public void set(T value) {
        this.value = value;
    }

}
