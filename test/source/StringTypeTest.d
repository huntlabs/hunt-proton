module StringTypeTest;

import std.stdio;
import CodecTestSupport;
import hunt.Assert ;
import hunt.String;
import  hunt.proton.codec.TypeConstructor;
import hunt.Assert ;
import hunt.logging;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.AMQPDefinedTypes;
import hunt.io.ByteBuffer;
import hunt.io.BufferUtils;
import hunt.proton.amqp.messaging.AmqpValue;
import hunt.proton.codec.CompositeReadableBuffer;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.WritableBuffer;
import hunt.Boolean;

 class WritableBufferWithoutPutStringOverride : WritableBuffer {

        private  ByteBufferWrapper delegat;

        this(int capacity) {
            delegat = ByteBufferWrapper.allocate(capacity);
        }

        public byte[] getArray() {
            return delegat.byteBuffer().array();
        }

        public int getArrayLength() {
            return delegat.byteBuffer().position();
        }

        override
        public void put(byte b) {
            delegat.put(b);
        }

        override
        public void putShort(short value) {
            delegat.putShort(value);
        }

        override
        public void putInt(int value) {
            delegat.putInt(value);
        }

        override
        public void putLong(long value) {
            delegat.putLong(value);
        }

        override
        public void putFloat(float value) {
            delegat.putFloat(value);
        }

        override
        public void putDouble(double value) {
            delegat.putDouble(value);
        }

        override
        public void put(byte[] src, int offset, int length) {
            delegat.put(src, offset, length);
        }

        override
        public bool hasRemaining() {
            return delegat.hasRemaining();
        }

        override
        public int remaining() {
            return delegat.remaining();
        }

        override
        public int position() {
            return delegat.position();
        }

        override
        public void position(int position) {
            delegat.position(position);
        }

        override
        public void put(ByteBuffer payload) {
            delegat.put(payload);
        }

        override
        public int limit() {
            return delegat.limit();
        }

        override
        public void put(ReadableBuffer src) {
            delegat.put(src);
        }
    }


class StringTypeTest {

    this() {
    }

    public void encodeDecodeStrings()
    {
         DecoderImpl decoder = new DecoderImpl();
         EncoderImpl encoder = new EncoderImpl(decoder);
         AMQPDefinedTypes.registerAllTypes(decoder, encoder);
         ByteBuffer bb = BufferUtils.allocate(12);

         String [] TEST_DATA = [new String("123sdf"), new String("234$")];

        foreach ( String input ; TEST_DATA)
        {
            bb.clear();
            AmqpValue inputValue = new AmqpValue(input);
            encoder.setByteBuffer(bb);
            encoder.writeObject(inputValue);
            bb.clear();
            decoder.setByteBuffer(bb);
            AmqpValue outputValue = cast(AmqpValue) decoder.readObject();
            assertEquals("Failed to round trip String correctly: ", input, outputValue.getValue());
        }
    }

     public void testSkipString()
    {
         DecoderImpl decoder = new DecoderImpl();
         EncoderImpl encoder = new EncoderImpl(decoder);
        AMQPDefinedTypes.registerAllTypes(decoder, encoder);
         ByteBuffer buffer = BufferUtils.allocate(64);

        decoder.setByteBuffer(buffer);
        encoder.setByteBuffer(buffer);

        encoder.writeString(new String("skipped"));
        encoder.writeString(new String("read"));

        buffer.clear();

        ITypeConstructor stringType = decoder.readConstructor();
        stringType.skipValue();

        String result = decoder.readString();
        assertEquals(new String("read"), result);
    }

     public void testEncodeAndDecodeEmptyString() {
         DecoderImpl decoder = new DecoderImpl();
         EncoderImpl encoder = new EncoderImpl(decoder);
        AMQPDefinedTypes.registerAllTypes(decoder, encoder);

         ByteBuffer buffer = BufferUtils.allocate(64);

        encoder.setByteBuffer(buffer);
        decoder.setByteBuffer(buffer);

        encoder.writeString(new String("a"));
        encoder.writeString(new String(""));
        encoder.writeString(new String("b"));

        buffer.clear();

        ITypeConstructor stringType = decoder.readConstructor();
        stringType.skipValue();

        String result = decoder.readString();
        assertEquals(new String(""), result);
        result = decoder.readString();
        assertEquals(new String("b"), result);
    }


    void doTestEmptyStringEncodeAsGivenType(byte encodingCode) {
         DecoderImpl decoder = new DecoderImpl();
         EncoderImpl encoder = new EncoderImpl(decoder);
        AMQPDefinedTypes.registerAllTypes(decoder, encoder);

         ByteBuffer buffer = BufferUtils.allocate(64);

        buffer.put(encodingCode);
        buffer.putInt(0);
        buffer.clear();

        byte[] copy = new byte[buffer.remaining()];
        buffer.get(copy);

        CompositeReadableBuffer composite = new CompositeReadableBuffer();
        composite.append(copy);

        decoder.setBuffer(composite);

        ITypeConstructor stringType = decoder.readConstructor();

        String result = cast(String) stringType.readValue();
        assertEquals(new String(""), result);
    }

      public void testEncodeAndDecodeUsingWritableBufferDefaultPutString()  {
         DecoderImpl decoder = new DecoderImpl();
         EncoderImpl encoder = new EncoderImpl(decoder);
        AMQPDefinedTypes.registerAllTypes(decoder, encoder);

        // Verify that the default put(String) impl is being used by the buffers
        String [] TEST_DATA = [new String("123sdf"), new String("234$")];
        foreach ( String input ; TEST_DATA) {
             WritableBufferWithoutPutStringOverride sink = new WritableBufferWithoutPutStringOverride(16);
             AmqpValue inputValue = new AmqpValue(input);
            encoder.setByteBuffer(sink);
            encoder.writeObject(inputValue);
            ReadableBuffer source = new ByteBufferReader(BufferUtils.wrap(sink.getArray(), 0, sink.getArrayLength()));
            decoder.setBuffer(source);
             AmqpValue outputValue = cast(AmqpValue) decoder.readObject();
            assertEquals("Failed to round trip String correctly: ", input, outputValue.getValue());
        }
    }
}


//void main()
//{
//    StringTypeTest test = new StringTypeTest;
//    test.testEncodeAndDecodeUsingWritableBufferDefaultPutString;
//    //test.encodeDecodeStrings;
//    //test.testEncodeAndDecodeEmptyString;
//    //test.testSkipString;
//    //test.doTestEmptyStringEncodeAsGivenType(EncodingCodes.STR32);
//}