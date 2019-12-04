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

module hunt.proton.codec.SymbolType;

import hunt.proton.codec.SmallFloatingSizePrimitiveTypeEncoding;
import hunt.proton.codec.LargeFloatingSizePrimitiveTypeEncoding;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.collection.Collection;
import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.collection.ArrayList;
import hunt.proton.codec.TypeEncoding;

import hunt.proton.amqp.Symbol;
import hunt.String;
import hunt.collection.List;

class SymbolType : AbstractPrimitiveType!(Symbol)
{
    //private static Charset ASCII_CHARSET = Charset.forName("US-ASCII");
    private SymbolEncoding _symbolEncoding;
    private SymbolEncoding _shortSymbolEncoding;

    private Map!(ReadableBuffer, Symbol) _symbolCache;
    private DecoderImpl.TypeDecoder!(Symbol) _symbolCreator ;

    interface SymbolEncoding : PrimitiveTypeEncoding!(Symbol)
    {

    }

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        _symbolCreator = new class DecoderImpl.TypeDecoder!(Symbol)
        {
            override
            public Symbol decode(DecoderImpl decoder, ReadableBuffer buffer)
            {
                Symbol symbol = _symbolCache.get(buffer);
                if (symbol is null)
                {
                    byte[] bytes = new byte[buffer.limit()];
                    buffer.get(bytes);

                    // String str = new String(cast(string)bytes);
                    symbol = Symbol.getSymbol(cast(string)bytes);

                    _symbolCache.put(ByteBufferReader.wrap(bytes), symbol);
                }
                return symbol;
            }
        };
        _symbolCache  =  new HashMap!(ReadableBuffer, Symbol);
        _symbolEncoding =  new LongSymbolEncoding(encoder, decoder);
        _shortSymbolEncoding = new ShortSymbolEncoding(encoder, decoder);
        encoder.register(typeid(Symbol), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(Symbol);
    }

    public void fastWrite(EncoderImpl encoder, Symbol symbol)
    {
        if (symbol.length() <= 255)
        {
            // Reserve size of body + type encoding and single byte size
            encoder.getBuffer().ensureRemaining(2 + symbol.length());
            encoder.writeRaw(EncodingCodes.SYM8);
            encoder.writeRaw(cast(byte) symbol.length());
            symbol.writeTo(encoder.getBuffer());
        }
        else
        {
            // Reserve size of body + type encoding and four byte size
            encoder.getBuffer().ensureRemaining(5 + symbol.length());
            encoder.writeRaw(EncodingCodes.SYM32);
            encoder.writeRaw(symbol.length());
            symbol.writeTo(encoder.getBuffer());
        }
    }

    public ITypeEncoding getEncoding(Object val)
    {
        return (cast(Symbol)val).length() <= 255 ? _shortSymbolEncoding : _symbolEncoding;
    }

    public SymbolEncoding getCanonicalEncoding()
    {
        return _symbolEncoding;
    }

    public Collection!(TypeEncoding!(Symbol)) getAllEncodings()
    {
        List!(TypeEncoding!(Symbol)) lst = new ArrayList!(TypeEncoding!(Symbol));
        lst.add(_shortSymbolEncoding);
        lst.add(_symbolEncoding);
        return lst;
        //return Arrays.asList(_shortSymbolEncoding, _symbolEncoding);
    }


    //Collection!(PrimitiveTypeEncoding!(Symbol)) getAllEncodings()
    //{
    //    return super.getAllEncodings();
    //}

    class LongSymbolEncoding
            : LargeFloatingSizePrimitiveTypeEncoding!(Symbol)
            , SymbolEncoding
    {

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected void writeEncodedValue(Symbol val)
        {
            getEncoder().getBuffer().ensureRemaining(getEncodedValueSize(val));
            val.writeTo(getEncoder().getBuffer());
        }

        override
        protected int getEncodedValueSize(Symbol val)
        {
            return val.length();
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.SYM32;
        }

        override
        public SymbolType getType()
        {
            return this.outer;
        }

        override
        public bool encodesSuperset(TypeEncoding!(Symbol) encoding)
        {
            return (getType() == encoding.getType());
        }

        override
        public Object readValue()
        {
            DecoderImpl decoder = getDecoder();
            int size = decoder.readRawInt();
            return decoder.readRaw(_symbolCreator, size);
        }

        override
        public void skipValue()
        {
            DecoderImpl decoder = getDecoder();
            ReadableBuffer buffer = decoder.getBuffer();
            int size = decoder.readRawInt();
            buffer.position(buffer.position() + size);
        }

        override  bool encodesJavaPrimitive()
        {
            return super.encodesJavaPrimitive();
        }

        override TypeInfo getTypeClass()
        {
            return super.getTypeClass();
        }

        override void writeConstructor()
        {
            return super.writeConstructor();
        }

        override  int getConstructorSize()
        {
            return super.getConstructorSize();
        }
    }

    class ShortSymbolEncoding
            : SmallFloatingSizePrimitiveTypeEncoding!(Symbol)
            , SymbolEncoding
    {

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected void writeEncodedValue(Symbol val)
        {
            getEncoder().getBuffer().ensureRemaining(getEncodedValueSize(val));
            val.writeTo(getEncoder().getBuffer());
        }

        override
        protected int getEncodedValueSize(Symbol val)
        {
            return val.length();
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.SYM8;
        }

        override
        public SymbolType getType()
        {
            return this.outer;
        }

        override
        public bool encodesSuperset(TypeEncoding!(Symbol) encoder)
        {
            return encoder == this;
        }

        override
        public Symbol readValue()
        {
            DecoderImpl decoder = getDecoder();
            int size = (cast(int)decoder.readRawByte()) & 0xff;
            return decoder.readRaw(_symbolCreator, size);
        }

        override
        public void skipValue()
        {
            DecoderImpl decoder = getDecoder();
            ReadableBuffer buffer = decoder.getBuffer();
            int size = (cast(int)decoder.readRawByte()) & 0xff;
            buffer.position(buffer.position() + size);
        }

        override bool encodesJavaPrimitive()
        {
            return super.encodesJavaPrimitive();
        }

        override TypeInfo getTypeClass()
        {
            return super.getTypeClass();
        }

        override void writeConstructor()
        {
            return super.writeConstructor();
        }

        override  int getConstructorSize()
        {
            return super.getConstructorSize();
        }
    }
}
