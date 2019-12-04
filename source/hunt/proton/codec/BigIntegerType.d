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

module hunt.proton.codec.BigIntegerType;

/*
import java.math.BigInteger;
import java.util.Arrays;
import hunt.collection.Collection;

class BigIntegerType : AbstractPrimitiveType!(BigInteger) {

    public static interface BigIntegerEncoding : PrimitiveTypeEncoding!(BigInteger)
    {
        void write(BigInteger l);
        void writeValue(BigInteger l);
        public BigInteger readPrimitiveValue();
    }

    private static BigInteger BIG_BYTE_MIN = BigInteger.valueOf(Byte.MIN_VALUE);
    private static BigInteger BIG_BYTE_MAX = BigInteger.valueOf(Byte.MAX_VALUE);
    private static BigInteger BIG_LONG_MIN = BigInteger.valueOf(Long.MIN_VALUE);
    private static BigInteger BIG_LONG_MAX = BigInteger.valueOf(Long.MAX_VALUE);

    private BigIntegerEncoding _BigIntegerEncoding;
    private BigIntegerEncoding _smallBigIntegerEncoding;

    BigIntegerType(EncoderImpl encoder, DecoderImpl decoder)
    {
        _BigIntegerEncoding = new AllBigIntegerEncoding(encoder, decoder);
        _smallBigIntegerEncoding = new SmallBigIntegerEncoding(encoder, decoder);
        encoder.register(BigInteger.class, this);
    }

    public Class!(BigInteger) getTypeClass()
    {
        return BigInteger.class;
    }

    public BigIntegerEncoding getEncoding(BigInteger l)
    {
        return (l.compareTo(BIG_BYTE_MIN) >= 0 && l.compareTo(BIG_BYTE_MAX) <= 0) ? _smallBigIntegerEncoding : _BigIntegerEncoding;
    }


    public BigIntegerEncoding getCanonicalEncoding()
    {
        return _BigIntegerEncoding;
    }

    public Collection!(BigIntegerEncoding) getAllEncodings()
    {
        return Arrays.asList(_smallBigIntegerEncoding, _BigIntegerEncoding);
    }

    private long longValueExact(BigInteger val) {
        if (val.compareTo(BIG_LONG_MIN) < 0 || val.compareTo(BIG_LONG_MAX) > 0) {
            throw new ArithmeticException("cannot encode BigInteger not representable as long");
        }
        return val.longValue();
    }

    private class AllBigIntegerEncoding : FixedSizePrimitiveTypeEncoding!(BigInteger) implements BigIntegerEncoding
    {

        public AllBigIntegerEncoding(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        protected int getFixedSize()
        {
            return 8;
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.LONG;
        }

        public BigIntegerType getType()
        {
            return BigIntegerType.this;
        }

        public void writeValue(BigInteger val)
        {
            getEncoder().writeRaw(longValueExact(val));
        }
        
        public void write(BigInteger l)
        {
            writeConstructor();
            getEncoder().writeRaw(longValueExact(l));
            
        }

        public bool encodesSuperset(TypeEncoding!(BigInteger) encoding)
        {
            return (getType() == encoding.getType());
        }

        public BigInteger readValue()
        {
            return readPrimitiveValue();
        }

        public BigInteger readPrimitiveValue()
        {
            return BigInteger.valueOf(getDecoder().readLong());
        }


        override
        public bool encodesJavaPrimitive()
        {
            return true;
        }
    }

    private class SmallBigIntegerEncoding  : FixedSizePrimitiveTypeEncoding!(BigInteger) implements BigIntegerEncoding
    {
        public SmallBigIntegerEncoding(EncoderImpl encoder, DecoderImpl decoder)
        {
            super(encoder, decoder);
        }

        override
        public byte getEncodingCode()
        {
            return EncodingCodes.SMALLLONG;
        }

        override
        protected int getFixedSize()
        {
            return 1;
        }

        public void write(BigInteger l)
        {
            writeConstructor();
            getEncoder().writeRaw(l.byteValue());
        }

        public BigInteger readPrimitiveValue()
        {
            return BigInteger.valueOf(getDecoder().readRawByte());
        }

        public BigIntegerType getType()
        {
            return BigIntegerType.this;
        }

        public void writeValue(BigInteger val)
        {
            getEncoder().writeRaw(val.byteValue());
        }

        public bool encodesSuperset(TypeEncoding!(BigInteger) encoder)
        {
            return encoder == this;
        }

        public BigInteger readValue()
        {
            return readPrimitiveValue();
        }


        override
        public bool encodesJavaPrimitive()
        {
            return true;
        }
    }
}
*/