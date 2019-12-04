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
module hunt.proton.codec.FastPathDescribedTypeConstructor;

/**
 * Marker interface that indicates the TypeConstructor can decode known Proton-J types
 * using a fast path read / write operation.  These types may result in an encode that
 * does not always write the smallest form of the given type to save time.
 *
 * @param <V> The type that this constructor handles
 */
import hunt.proton.codec.TypeConstructor;

interface FastPathDescribedTypeConstructor(V) : TypeConstructor!(V) {

}
