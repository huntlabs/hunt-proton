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

module hunt.proton.codec.StringType;

import hunt.proton.codec.SmallFloatingSizePrimitiveTypeEncoding;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.PrimitiveTypeEncoding;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.AbstractPrimitiveType;
import hunt.proton.codec.DecoderImpl;
import hunt.collection.Collection;
import hunt.Exceptions;
import hunt.String;
import hunt.collection.ArrayList;

import hunt.proton.codec.LargeFloatingSizePrimitiveTypeEncoding;
import hunt.logging;


interface StringEncoding : PrimitiveTypeEncoding!(String)
{
    void setValue(String val, int length);
}


class StringType : AbstractPrimitiveType!(String)
{
    private static DecoderImpl.TypeDecoder!(String) _stringCreator ;

    private StringEncoding _stringEncoding;
    private StringEncoding _shortStringEncoding;

    this(EncoderImpl encoder, DecoderImpl decoder)
    {
        StringType._stringCreator = new class DecoderImpl.TypeDecoder!(String)
        {
            override
            public String decode(DecoderImpl decoder, ReadableBuffer buffer)
            {
                //  CharsetDecoder charsetDecoder = decoder.getCharsetDecoder();
                try
                {
                    return new String(buffer.readUTF8());
                }
                catch (CharacterCodingException e)
                {
                    throw new IllegalArgumentException("Cannot parse String");
                }
                //finally
                //{
                //    charsetDecoder.reset();
                //}
            }
        };
        _stringEncoding = new AllStringEncoding(encoder, decoder);
        _shortStringEncoding = new ShortStringEncoding(encoder, decoder);
        encoder.register(typeid(String), this);
        decoder.register(this);
    }

    public TypeInfo getTypeClass()
    {
        return typeid(String);
    }

    public ITypeEncoding getEncoding(Object val)
    {
        int length = calculateUTF8Length(cast(String)val);
        StringEncoding encoding = length <= 255
                ? _shortStringEncoding
                : _stringEncoding;
        encoding.setValue(cast(String)val, length);
        return encoding;
    }

    static int calculateUTF8Length(String str)
    {
        string s = str.value;
       // int stringLength = cast(int)((cast(byte[])s).length);

        // ASCII Optimized length case
        //int utf8len = stringLength;
        //int processed = 0;
        //for (; processed < stringLength && s[processed] < 0x80; processed++) {}
        //
        //if (processed < stringLength)
        //{
        //    // Non-ASCII length remainder
        //    utf8len = extendedCalculateUTF8Length(str, processed, stringLength, utf8len);
        //}

        return cast(int)(s.length);
    }

    static int extendedCalculateUTF8Length(String str, int index, int length, int utf8len) {
        string s = str.value;
        for (; index < length; index++)
        {
            int c = s[index];
            if ((c & 0xFF80) != 0)         /* U+0080..    */
            {
                utf8len++;
                if(((c & 0xF800) != 0))    /* U+0800..    */
                {
                    utf8len++;
                    // surrogate pairs should always combine to create a code point with a 4 octet representation
                    if ((c & 0xD800) == 0xD800 && c < 0xDC00)
                    {
                        index++;
                    }
                }
            }
        }

        return utf8len;
    }

    public StringEncoding getCanonicalEncoding()
    {
        return _stringEncoding;
    }

    public Collection!(TypeEncoding!(String)) getAllEncodings()
    {
        ArrayList!(TypeEncoding!(String)) lst = new ArrayList!(TypeEncoding!(String))();
        lst.add(_shortStringEncoding);
        lst.add(_stringEncoding);
        return lst;
    }

    //Collection!(PrimitiveTypeEncoding!(String)) getAllEncodings()
    //{
    //    return super.getAllEncodings();
    //}


    class AllStringEncoding
            : LargeFloatingSizePrimitiveTypeEncoding!(String)
            , StringEncoding
    {
        private String _value;
        private int _length;

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected void writeEncodedValue(String val)
        {
            getEncoder().getBuffer().ensureRemaining(getEncodedValueSize(val));
            getEncoder().writeRaw(val);
        }

        override
        protected int getEncodedValueSize(String val)
        {
            return (val == _value) ? _length : calculateUTF8Length(val);
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.STR32;
        }

        override
        public StringType getType()
        {
            return this.outer;
        }

        override
        public bool encodesSuperset(TypeEncoding!(String) encoding)
        {
            return (getType() == encoding.getType());
        }

        override
        public Object readValue()
        {
            DecoderImpl decoder = getDecoder();
            int size = decoder.readRawInt();
            return size == 0 ? new String("") : decoder.readRaw(_stringCreator, size);
        }

        override
        public void setValue(String val, int length)
        {
            _value = val;
            _length = length;
        }

        override
        public void skipValue()
        {
            DecoderImpl decoder = getDecoder();
            ReadableBuffer buffer = decoder.getBuffer();
            int size = decoder.readRawInt();
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

    class ShortStringEncoding
            : SmallFloatingSizePrimitiveTypeEncoding!(String)
            , StringEncoding
    {
        private String _value;
        private int _length;

        this(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected void writeEncodedValue(String val)
        {
            getEncoder().getBuffer().ensureRemaining(getEncodedValueSize(val));
            getEncoder().writeRaw(val);
        }

        override
        protected int getEncodedValueSize(String val)
        {
          //  logInfof("size : %d",(val == _value) ? _length : calculateUTF8Length(val));
            return (val == _value) ? _length : calculateUTF8Length(val);
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.STR8;
        }

        override
        public StringType getType()
        {
            return this.outer;
        }

        override
        public bool encodesSuperset(TypeEncoding!(String) encoder)
        {
            return encoder == this;
        }

        override
        public Object readValue()
        {
            DecoderImpl decoder = getDecoder();
            int size = (cast(int)decoder.readRawByte()) & 0xff;
            String a;
            if (size == 0)
            {
                a = new String("");
            }
            else
            {
                a =decoder.readRaw(_stringCreator, size);
            }
            //return size == 0 ? new String("") : decoder.readRaw(_stringCreator, size);
           // logInfof("dddddddddddddddddd  %s",a);
            return a;
        }

        override
        public void setValue(String val, int length)
        {
            _value = val;
            _length = length;
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
