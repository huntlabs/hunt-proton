module UnsignedIntegerTypeTest;

import std.stdio;
import CodecTestSupport;
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
import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.codec.UnsignedIntegerType;
import hunt.proton.codec.EncodingCodes;
import hunt.Integer;

class UnsignedIntegerTypeTest   {

    this() {
    }

    public void testGetEncodingWithZero()
    {
        DecoderImpl decoder = new DecoderImpl();
        EncoderImpl encoder = new EncoderImpl(decoder);
        UnsignedIntegerType ult = new UnsignedIntegerType(encoder, decoder);

        //values of 0 are encoded as a specific type
        UnsignedIntegerEncoding encoding = cast(UnsignedIntegerEncoding)ult.getEncoding(cast(Object)(UnsignedInteger.valueOf(0L)));
        assertEquals("incorrect encoding returned", EncodingCodes.UINT0, encoding.getEncodingCode());
    }

    public void testGetEncodingWithSmallPositiveValue()
    {
        DecoderImpl decoder = new DecoderImpl();
        EncoderImpl encoder = new EncoderImpl(decoder);
        UnsignedIntegerType ult = new UnsignedIntegerType(encoder, decoder);

        //values between 0 and 255 are encoded as a specific 'small' type using a single byte
        UnsignedIntegerEncoding encoding = cast(UnsignedIntegerEncoding)ult.getEncoding(UnsignedInteger.valueOf(1L));
        assertEquals("incorrect encoding returned", EncodingCodes.SMALLUINT, encoding.getEncodingCode());
    }

    public void testGetEncodingWithTwoToThirtyOne()
    {
        DecoderImpl decoder = new DecoderImpl();
        EncoderImpl encoder = new EncoderImpl(decoder);
        UnsignedIntegerType ult = new UnsignedIntegerType(encoder, decoder);

        long a = 2147483647;
        UnsignedInteger  _outgoingWindowSize = UnsignedInteger.valueOf(a);
        writefln("%d",_outgoingWindowSize.intValue);
        //long val = Integer.MAX_VALUE + 1L;
        //UnsignedIntegerEncoding encoding = cast(UnsignedIntegerEncoding)ult.getEncoding(UnsignedInteger.valueOf(val));
        //assertEquals("incorrect encoding returned", EncodingCodes.UINT, encoding.getEncodingCode());
    }

     public void testSkipValue()
    {
         DecoderImpl decoder = new DecoderImpl();
         EncoderImpl encoder = new EncoderImpl(decoder);
        AMQPDefinedTypes.registerAllTypes(decoder, encoder);
         ByteBuffer buffer = BufferUtils.allocate(64);

        decoder.setByteBuffer(buffer);
        encoder.setByteBuffer(buffer);

        encoder.writeUnsignedInteger(UnsignedInteger.ZERO);
        encoder.writeUnsignedInteger(UnsignedInteger.ONE);

        buffer.clear();

        ITypeConstructor type = decoder.readConstructor();
        type.skipValue();

        UnsignedInteger result = decoder.readUnsignedInteger();
        assertEquals(UnsignedInteger.ONE, result);
    }
}

//void main()
//{
//    UnsignedIntegerTypeTest test = new UnsignedIntegerTypeTest;
//
//
//   // test.testGetEncodingWithZero;
//  //  test.testGetEncodingWithSmallPositiveValue;
//   // test.testGetEncodingWithTwoToThirtyOne;
//    test.testGetEncodingWithTwoToThirtyOne;
//}
