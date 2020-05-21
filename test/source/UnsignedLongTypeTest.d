module UnsignedLongTypeTest;

import std.stdio;
import hunt.Assert ;
import hunt.String;
import  hunt.proton.codec.TypeConstructor;
import hunt.Assert ;
import hunt.logging;
import hunt.collection.Map;
import hunt.collection.LinkedHashMap;
import hunt.proton.codec.messaging.ApplicationPropertiesType;
import hunt.proton.amqp.messaging.ApplicationProperties;
import hunt.proton.amqp.messaging.Properties;
import hunt.time.LocalDateTime;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;

import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.AMQPDefinedTypes;
import hunt.io.ByteBuffer;
import hunt.io.BufferUtils;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.codec.UnsignedIntegerType;
import hunt.proton.codec.EncodingCodes;
import hunt.Integer;
import hunt.proton.codec.UnsignedLongType;
import hunt.proton.amqp.UnsignedLong;
import hunt.Long;
import hunt.math.BigInteger;

class UnsignedLongTypeTest {

    this() {
    }

    public void testGetEncodingWithZero()
    {
        DecoderImpl decoder = new DecoderImpl();
        EncoderImpl encoder = new EncoderImpl(decoder);
        UnsignedLongType ult = new UnsignedLongType(encoder, decoder);

        //values of 0 are encoded as a specific type
        UnsignedLongEncoding encoding = cast(UnsignedLongEncoding)ult.getEncoding(UnsignedLong.valueOf(0L));
        assertEquals("incorrect encoding returned", EncodingCodes.ULONG0, encoding.getEncodingCode());
    }

    public void testGetEncodingWithSmallPositiveValue()
    {
        DecoderImpl decoder = new DecoderImpl();
        EncoderImpl encoder = new EncoderImpl(decoder);
        UnsignedLongType ult = new UnsignedLongType(encoder, decoder);

        //values between 0 and 255 are encoded as a specific 'small' type using a single byte
        UnsignedLongEncoding encoding = cast(UnsignedLongEncoding)ult.getEncoding(UnsignedLong.valueOf(1L));
        assertEquals("incorrect encoding returned", EncodingCodes.SMALLULONG, encoding.getEncodingCode());
    }

    //public void testGetEncodingWithTwoToSixtyThree()
    //{
    //    DecoderImpl decoder = new DecoderImpl();
    //    EncoderImpl encoder = new EncoderImpl(decoder);
    //    UnsignedLongType ult = new UnsignedLongType(encoder, decoder);
    //
    //    BigInteger bigInt = BigInteger.valueOf(Long.MAX_VALUE).add(BigInteger.ONE);
    //    UnsignedLongEncoding encoding = ult.getEncoding(UnsignedLong.valueOf(bigInt));
    //    assertEquals("incorrect encoding returned", EncodingCodes.ULONG, encoding.getEncodingCode());
    //}


       public void testSkipValue()
    {
         DecoderImpl decoder = new DecoderImpl();
         EncoderImpl encoder = new EncoderImpl(decoder);
        AMQPDefinedTypes.registerAllTypes(decoder, encoder);
         ByteBuffer buffer = BufferUtils.allocate(64);

        decoder.setByteBuffer(buffer);
        encoder.setByteBuffer(buffer);

        encoder.writeUnsignedLong(UnsignedLong.ZERO);
        encoder.writeUnsignedLong(UnsignedLong.valueOf(1));

        buffer.clear();

        ITypeConstructor type = decoder.readConstructor();
        type.skipValue();

        UnsignedLong result = decoder.readUnsignedLong();
        assertEquals(UnsignedLong.valueOf(1), result);
    }
}


//void main()
//{
//    UnsignedLongTypeTest test = new UnsignedLongTypeTest;
//    //test.testGetEncodingWithZero;
//    test.testSkipValue;
//}