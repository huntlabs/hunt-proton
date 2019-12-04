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

module hunt.proton.engine.ExtendableAccessor;

import hunt.proton.engine.Extendable;
import hunt.proton.engine.Record;
import hunt.Exceptions;

/**
 * A typesafe convenience class for associating additional data with {@link Extendable} classes.
 * <p>
 * An instance of <code>ExtendableAccessor</code> uses itself as the key in the {@link Extendable#attachments()}
 * so it's best instantiated as a static member.
 * <pre><code>
 *   class Foo extends BaseHandler {
 *     private static ExtendableAccessor&lt;Link, Bar&gt; LINK_BAR = new ExtendableAccessor&lt;&gt;(Bar.class);
 *     void onLinkRemoteOpen(Event e) {
 *       Bar bar = LINK_BAR.get(e.getLink());
 *       if (bar is null) {
 *         bar = new Bar();
 *         LINK_BAR.set(e.getLink(), bar);
 *         }
 *       }
 *     }
 * </code></pre>
 * 
 * @param <E> An {@link Extendable} type where the data is to be stored
 * @param <T> The type of the data to be stored
 */
class ExtendableAccessor(E,T) : Extendable {
    private  TypeInfo klass;
    this() {
        this.klass = typeid(T);
    }

    public T get(E e, string key) {
        return cast(T)(e.attachments().get(key));
    }

    public void set(E e, T value ,string key) {
        e.attachments().set(key, cast(Object)value);
    }

    Record attachments() {
        implementationMissing(false);
        return null;
    }
}