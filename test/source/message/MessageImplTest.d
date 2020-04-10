module message.MessageImplTest;

// import std.stdio;

// import hunt.proton.amqp.Binary;
// import hunt.proton.amqp.messaging.Data;
// import hunt.proton.codec.WritableBuffer;
// import hunt.proton.message.Message;
// import hunt.Assert ;
// import hunt.collection.ByteBuffer;
// import hunt.collection.BufferUtils;
// import io.proton.impl.ProtonWritableBufferImpl;
// import hunt.proton.message.impl.MessageImpl;
// import io.proton.ProtonHelper;
// import hunt.String;

// class MessageImplTest {

//     private static  long DATA_SECTION_ULONG_DESCRIPTOR = 0x0000000000000075L;

//     this() {
//     }

//     private byte[] generateByteArray(int bytesLength)
//     {
//         byte[] bytes = new byte[bytesLength];
//         for(int i = 0; i < bytesLength; i++)
//         {
//             bytes [i] = cast(byte) (i % 10);
//         }

//         return bytes;
//     }

//     byte[] generateExpectedDataSectionBytes(byte[] payloadBytes)
//     {
//         int dataBytesLength = 1;         // 0x00 for described-type constructor start
//         dataBytesLength += 1;            // smallulong encoding format for data section descriptor
//         dataBytesLength += 1;            // smallulong 8bit value
//         dataBytesLength += 1;            // vbin variable-width binary encoding format.
//         if (payloadBytes.length > 255)
//         {
//             dataBytesLength += 4;        // 32bit length field.
//         }
//         else
//         {
//             dataBytesLength += 1;        // 8bit length field.
//         }
//         dataBytesLength += payloadBytes.length; // section payload length.

//         ByteBuffer buffer = BufferUtils.allocate(dataBytesLength);

//         buffer.put(cast(byte) 0x00);                    // 0x00 for described-type constructor start
//         buffer.put(cast(byte) 0x53);                    // smallulong encoding format for data section descriptor
//         buffer.put(cast(byte) DATA_SECTION_ULONG_DESCRIPTOR); // smallulong 8bit value
//         if (payloadBytes.length > 255)
//         {
//             buffer.put(cast(byte) 0xb0);                // vbin32 variable-width binary encoding format.
//             buffer.putInt(cast(int)payloadBytes.length);     // 32bit length field.
//         }
//         else
//         {
//             buffer.put(cast(byte) 0xa0);                // vbin8 variable-width binary encoding format.
//             buffer.put(cast(byte) payloadBytes.length); // 8bit length field.
//         }
//         buffer.put(payloadBytes);                   // The actual content of given length.

//         assertEquals("Unexpected buffer position", dataBytesLength, buffer.position());

//         return buffer.array();
//     }

//     public void doMessageEncodingWithDataBodySectionTestImpl(int bytesLength)
//     {
//         byte[] bytes = generateByteArray(bytesLength);

//         byte[] expectedBytes = generateExpectedDataSectionBytes(bytes);
//         byte[] encodedBytes = new byte[expectedBytes.length];

//         Message msg = Message.Factory.create();
//         msg.setBody(new Data(new Binary(bytes)));

//         int encodedLength = msg.encode(encodedBytes, 0, cast(int)encodedBytes.length);

//         assertArrayEquals("Encoded bytes do not match expectation", expectedBytes, encodedBytes);
//         assertEquals("Encoded length different than expected length", encodedLength, encodedBytes.length);
//     }

//     void doMessageEncodingWithDataBodySectionTestImplUsingWritableBuffer(int bytesLength)
//     {
//         //byte[] bytes = generateByteArray(bytesLength);
//         //
//         //byte[] expectedBytes = generateExpectedDataSectionBytes(bytes);
//         //ByteBufferWrapper encodedBytes = ByteBufferWrapper.allocate(cast(int)expectedBytes.length);
//         //
//         //Message msg = Message.Factory.create();
//         //msg.setBody(new Data(new Binary(bytes)));
//         //
//         //int encodedLength = msg.encode(encodedBytes);
//         //
//         //assertArrayEquals("Encoded bytes do not match expectation", expectedBytes, encodedBytes.byteBuffer().array());
//         //assertEquals("Encoded length different than expected length", encodedLength, encodedBytes.position());
//         Message message = ProtonHelper.message(new String("queue://foo"), new String("Hello World from client"));
//         ProtonWritableBufferImpl buffer = new ProtonWritableBufferImpl();
//         MessageImpl msg = cast(MessageImpl)message;
//         msg.encode(buffer);



//     }

// }

// void main()
// {
//     MessageImplTest test = new MessageImplTest;
//     test.doMessageEncodingWithDataBodySectionTestImpl(1024);

//     test.doMessageEncodingWithDataBodySectionTestImplUsingWritableBuffer(1024);
// }