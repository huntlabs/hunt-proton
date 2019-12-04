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

module hunt.proton.codec.DynamicTypeConstructor;

import hunt.proton.codec.TypeConstructor;
import hunt.proton.codec.DescribedTypeConstructor;
import hunt.logging;
import hunt.Exceptions;
class DynamicTypeConstructor : ITypeConstructor
{
    private IDescribedTypeConstructor _describedTypeConstructor;
    private ITypeConstructor _underlyingEncoding;

    this(IDescribedTypeConstructor dtc,ITypeConstructor underlyingEncoding)
    {
        _describedTypeConstructor = dtc;
        _underlyingEncoding = underlyingEncoding;
    }

    public Object readValue()
    {
        try
        {
            return _describedTypeConstructor.newInstance(_underlyingEncoding.readValue());
        }
        catch (NullPointerException npe)
        {
           // throw new DecodeException("Unexpected null value - mandatory field not set? ("+npe.getMessage()+")", npe);
            logError("Unexpected null value");
        }
        catch (ClassCastException cce)
        {
         //   throw new DecodeException("Incorrect type used", cce);
            logError("Incorrect type used");
        }
        return null;
    }

    public bool encodesJavaPrimitive()
    {
        return false;
    }

    public void skipValue()
    {
        _underlyingEncoding.skipValue();
    }

    public TypeInfo getTypeClass()
    {

        return _describedTypeConstructor.getTypeClass();
    }
}