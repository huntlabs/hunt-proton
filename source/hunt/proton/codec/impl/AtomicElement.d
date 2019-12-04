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

module hunt.proton.codec.impl.AtomicElement;

import hunt.proton.codec.impl.AbstractElement;
import hunt.proton.codec.impl.Element;
import hunt.Exceptions;

abstract class AtomicElement(T) : AbstractElement!T
{

    this(IElement parent, IElement prev)
    {
        super(parent, prev);
    }

    public IElement child()
    {
        throw new UnsupportedOperationException();
    }

    public void setChild(IElement elt)
    {
        throw new UnsupportedOperationException();
    }


    public bool canEnter()
    {
        return false;
    }

    public IElement checkChild(IElement element)
    {
        throw new UnsupportedOperationException();
    }

    public IElement addChild(IElement element)
    {
        throw new UnsupportedOperationException();
    }

    override
    string startSymbol() {
        throw new UnsupportedOperationException();
    }

    override
    string stopSymbol() {
        throw new UnsupportedOperationException();
    }

}
