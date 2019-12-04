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

module hunt.proton.codec.impl.AbstractElement;
import hunt.proton.codec.impl.ArrayElement;
import hunt.proton.codec.impl.Element;
abstract class AbstractElement(T) : Element!T
{
    private IElement _parent;
    private IElement _next;
    private IElement _prev;

    this(IElement parent, IElement prev)
    {
        _parent = parent;
        _prev = prev;
    }

    protected bool isElementOfArray()
    {
        ArrayElement toArry = cast(ArrayElement)_parent;
        if (toArry !is null)
        {  // _parent instanceof ArrayElement && !(((ArrayElement)parent()).isDescribed() && this == _parent.child());
            if(!((cast(ArrayElement)parent()).isDescribed() && this is _parent.child()))
            {
                return true;
            }
        }
        return false;
    }

    override
    public IElement next()
    {
        // TODO
        return _next;
    }

    override
    public IElement prev()
    {
        // TODO
        return _prev;
    }

    override
    public IElement parent()
    {
        // TODO
        return _parent;
    }

    override
    public void setNext(IElement elt)
    {
        _next = cast(Element!T)elt;
    }

    override
    public void setPrev(IElement elt)
    {

        _prev = cast(Element!T)elt;
    }

    override
    public void setParent(IElement elt)
    {
        _parent = cast(Element!T)elt;
    }

    override
    public IElement replaceWith(IElement elt)
    {

        if (_parent !is null) {
            elt = _parent.checkChild(elt);
        }

        elt.setPrev(_prev);
        elt.setNext(_next);
        elt.setParent(_parent);

        if (_prev !is null) {
            _prev.setNext(elt);
        }
        if (_next !is null) {
            _next.setPrev(elt);
        }

        if (_parent !is null && _parent.child() is this) {
            _parent.setChild(elt);
        }

        return elt;
    }

    //override
    //public String toString()
    //{
    //    return String.format("%s[%h]{parent=%h, prev=%h, next=%h}",
    //                         this.getClass().getSimpleName(),
    //                         System.identityHashCode(this),
    //                         System.identityHashCode(_parent),
    //                         System.identityHashCode(_prev),
    //                         System.identityHashCode(_next));
    //}

    abstract string startSymbol();

    abstract string stopSymbol();

    override
    public void render(string sb)
    {
        //if (canEnter()) {
        //    sb ~= startSymbol();
        //    Element el = child();
        //    bool first = true;
        //    while (el != null) {
        //        if (first) {
        //            first = false;
        //        } else {
        //            sb ~= ", ";
        //        }
        //        el.render(sb);
        //        el = el.next();
        //    }
        //    sb ~= stopSymbol();
        //} else {
        //  //  sb.append(getDataType()).append(" ").append(getValue());
        //}
    }

}
