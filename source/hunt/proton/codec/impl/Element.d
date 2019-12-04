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

module hunt.proton.codec.impl.Element;

import hunt.collection.ByteBuffer;
import hunt.proton.codec.Data;

interface IElement
{
    int size();
    Data.DataType getDataType();
    int encode(ByteBuffer b);
    IElement replaceWith(IElement elt);

    IElement addChild(IElement element);
    IElement checkChild(IElement element);

    IElement next();
    IElement prev();
    IElement child();
    IElement parent();

    void setNext(IElement elt);
    void setPrev(IElement elt);
    void setParent(IElement elt);
    void setChild(IElement elt);

    bool canEnter();

    void render(string sb);
    Object getValue();
}

interface Element(T) : IElement
{
    //int size();

   // Data.DataType getDataType();
    //int encode(ByteBuffer b);
    //Element!T next();
    //Element!T prev();
    //Element!T child();
    //Element!T parent();

    //void setNext(Element!T elt);
    //void setPrev(Element!T elt);
    //void setParent(Element!T elt);
    //void setChild(Element!T elt);

    //Element!T replaceWith(Element!T elt);
    //
    //Element!T addChild(Element!T element);
    //Element!T checkChild(Element!T element);

    //bool canEnter();
    //
    //void render(string sb);
}
