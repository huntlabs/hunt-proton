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

module hunt.proton.engine.impl.RecordImpl;

import hunt.proton.engine.Record;
import hunt.collection.HashMap;
import hunt.collection.Map;


/**
 * RecordImpl
 *
 */

class RecordImpl : Record
{

    private Map!(string,Object) values ;//= new HashMap<Object,Object>();

    public void set(string key, Object value) {
        values.put(key, value);
    }

    public Object get(string key) {
        return (values.get(key));
    }

    public void clear() {
        values.clear();
    }

    void copy(RecordImpl src) {
        values.putAll(src.values);
    }

    this()
    {
        values = new HashMap!(string,Object)();
    }

}
