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

module hunt.proton.amqp.Symbol;

import std.algorithm.comparison;
import hunt.io.ByteBuffer;
import hunt.collection.HashMap;
import hunt.proton.codec.WritableBuffer;
import hunt.collection.Map;

class Symbol
{
    private  string _underlying;
    private  byte[] _underlyingBytes;


     __gshared Map!(string, Symbol) _symbols ;

    shared static this()
    {
        _symbols = new HashMap!(string, Symbol);
    }

    this (string underlying)
    {
        _underlying = underlying;
        _underlyingBytes = cast(byte[])underlying;
    }

    public string getUnderlying()
    {
        return  _underlying;
    }

    public int length()
    {
        return cast(int)_underlying.length;
    }

    override bool opEquals(Object o) {
        return this._underlying == (cast(Symbol)o)._underlying;
    }

    override int opCmp(Object o)
    {

        return cmp(this._underlying,(cast(Symbol)o)._underlying);
    }


    public char charAt(int index)
    {
        return _underlying[index];
    }

    public string subSequence(int beginIndex, int endIndex)
    {
        return _underlying[beginIndex .. endIndex];
    }

    override
    public string toString()
    {
        return _underlying;
    }

    //override
    public int hashCode()
    {
        return cast(int)(_underlying.hashOf());
    }

    override
    public  size_t toHash() @trusted nothrow
    {
        return  cast(int)(_underlying.hashOf());
    }

    static Symbol valueOf(string symbolVal)
    {
        return getSymbol(symbolVal);
    }

    static Symbol getSymbol(string symbolVal)
    {
        //if(symbolVal is null)
        //{
        //    return null;
        //}

        if (_symbols is null)
        {
            _symbols = new HashMap!(string, Symbol);
        }
        Symbol symbol = null;
      //  synchronized(this)
        {
            symbol = _symbols.get(symbolVal);
            if(symbol is null)
            {
                // symbolVal = symbolVal.intern();
                symbol = new Symbol(symbolVal);
                _symbols.put(symbolVal,symbol);
            }
        }
        return symbol;
    }

    public void writeTo(WritableBuffer buffer)
    {
        buffer.put(_underlyingBytes, 0, cast(int)_underlyingBytes.length);
    }

    public void writeTo(ByteBuffer buffer)
    {
        buffer.put(_underlyingBytes, 0, cast(int)_underlyingBytes.length);
    }
}
