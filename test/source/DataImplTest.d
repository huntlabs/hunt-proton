module DataImplTest;

import std.stdio;

import hunt.proton.codec.impl.DataImpl;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.Symbol;
import hunt.proton.codec.Data;
import hunt.proton.amqp.Binary;
import hunt.Assert;
import hunt.collection.List;
import hunt.logging;
import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.String;
import hunt.Long;

class DataImplTest {

    this() {
    }

    void testEncodeDecodeSymbolArrayUsingPutArray() {
        Symbol symbol1 = Symbol.valueOf("testRoundtripSymbolArray1");
        Symbol symbol2 = Symbol.valueOf("testRoundtripSymbolArray2");

        Data data1 = new DataImpl();
        data1.putArray(false, Data.DataType.SYMBOL);
        data1.enter();
        data1.putSymbol(symbol1);
        data1.putSymbol(symbol2);
        data1.exit();

        Binary encoded = data1.encode();
        writefln("%s", encoded.getArray);
        encoded.asByteBuffer();

        Data data2 = new DataImpl();
        data2.decode(encoded.asByteBuffer());

        assertEquals("unexpected array length", 2, data2.getArray());
        assertEquals("unexpected array length", Data.DataType.SYMBOL, data2.getArrayType());

        List!Object array = data2.getJavaArray();
        assertNotNull("Array should not be null", array);
        if (cast(int) array.size() != 2) {
            logError("Error");
        }
        assertEquals("unexpected value", symbol1, cast(Symbol) array.get(0));
        assertEquals("unexpected value", symbol2, cast(Symbol) array.get(1));
    }

    void testEncodeArrayOfLists() {
        // encode an array of two empty lists
        Data data = new DataImpl();
        data.putArray(false, Data.DataType.LIST);
        data.enter();
        data.putList();
        data.putList();
        data.exit();

        int expectedEncodedSize = 4; // 1b type + 1b size + 1b length + 1b element constructor

        Binary encoded = data.encode();
        assertEquals("unexpected encoding size", expectedEncodedSize, encoded.getLength());

        ByteBuffer expectedEncoding = BufferUtils.allocate(expectedEncodedSize);
        expectedEncoding.put(cast(byte) 0xe0); // constructor
        expectedEncoding.put(cast(byte) 2); // size
        expectedEncoding.put(cast(byte) 2); // count
        expectedEncoding.put(cast(byte) 0x45); // element constructor

        assertEquals("unexpected encoding", new Binary(expectedEncoding.array()), encoded);

        data = new DataImpl();
        data.putArray(false, Data.DataType.LIST);
        data.enter();
        data.putList();
        data.putList();
        data.putList();
        data.enter();
        data.putNull();
        data.exit();
        data.exit();

        expectedEncodedSize = 11; // 1b type + 1b size + 1b length + 1b element constructor + 3 * (1b size + 1b count) + 1b null elt

        encoded = data.encode();
        assertEquals("unexpected encoding size", expectedEncodedSize, encoded.getLength());

        expectedEncoding = BufferUtils.allocate(expectedEncodedSize);
        expectedEncoding.put(cast(byte) 0xe0); // constructor
        expectedEncoding.put(cast(byte) 9); // size
        expectedEncoding.put(cast(byte) 3); // count
        expectedEncoding.put(cast(byte) 0xc0); // element constructor
        expectedEncoding.put(cast(byte) 1); // size
        expectedEncoding.put(cast(byte) 0); // count
        expectedEncoding.put(cast(byte) 1); // size
        expectedEncoding.put(cast(byte) 0); // count
        expectedEncoding.put(cast(byte) 2); // size
        expectedEncoding.put(cast(byte) 1); // count
        expectedEncoding.put(cast(byte) 0x40); // null value

        assertEquals("unexpected encoding", new Binary(expectedEncoding.array()), encoded);

        data = new DataImpl();
        data.putArray(false, Data.DataType.LIST);
        data.enter();
        data.putList();
        data.putList();
        data.putList();
        data.enter();
        for (int i = 0; i < 256; i++) {
            data.putNull();
        }
        data.exit();
        data.exit();

        expectedEncodedSize = 290; // 1b type + 4b size + 4b length + 1b element constructor + 3 * (4b size + 4b count) + (256 * 1b) null elt
        encoded = data.encode();
        assertEquals("unexpected encoding size", expectedEncodedSize, encoded.getLength());

        expectedEncoding = BufferUtils.allocate(expectedEncodedSize);
        expectedEncoding.put(cast(byte) 0xf0); // constructor
        expectedEncoding.putInt(285); // size
        expectedEncoding.putInt(3); // count
        expectedEncoding.put(cast(byte) 0xd0); // element constructor
        expectedEncoding.putInt(4); // size
        expectedEncoding.putInt(0); // count
        expectedEncoding.putInt(4); // size
        expectedEncoding.putInt(0); // count
        expectedEncoding.putInt(260); // size
        expectedEncoding.putInt(256); // count
        for (int i = 0; i < 256; i++) {
            expectedEncoding.put(cast(byte) 0x40); // null value
        }

        assertEquals("unexpected encoding", new Binary(expectedEncoding.array()), encoded);

    }

    void testEncodeArrayOfMaps() {
        // encode an array of two empty maps
        Data data = new DataImpl();
        data.putArray(false, Data.DataType.MAP);
        data.enter();
        data.putMap();
        data.putMap();
        data.exit();

        int expectedEncodedSize = 8; // 1b type + 1b size + 1b length + 1b element constructor + 2 * (1b size + 1b count)

        Binary encoded = data.encode();
        assertEquals("unexpected encoding size", expectedEncodedSize, encoded.getLength());

        ByteBuffer expectedEncoding = BufferUtils.allocate(expectedEncodedSize);
        expectedEncoding.put(cast(byte) 0xe0); // constructor
        expectedEncoding.put(cast(byte) 6); // size
        expectedEncoding.put(cast(byte) 2); // count
        expectedEncoding.put(cast(byte) 0xc1); // element constructor
        expectedEncoding.put(cast(byte) 1); // size
        expectedEncoding.put(cast(byte) 0); // count
        expectedEncoding.put(cast(byte) 1); // size
        expectedEncoding.put(cast(byte) 0); // count

        assertEquals("unexpected encoding", new Binary(expectedEncoding.array()), encoded);

    }

    private byte[] createStringPayloadBytes(int length) {
        byte[] payload = new byte[length];
        for (int i = 0; i < length; i++) {
            payload[i] = cast(byte)((i % 10) + 48);
        }

        return payload;
    }

    void testEncodeString32() {
        byte[] strPayload = createStringPayloadBytes(256);
        //String content = new String(cast(string)strPayload);
        // assertTrue("Length must be over 255 to ensure use of str32 encoding", cast(int)content.length() > 255);

        int encodedSize = 1 + 4 + cast(int) strPayload.length; // 1b type + 4b length + content
        ByteBuffer expectedEncoding = BufferUtils.allocate(encodedSize);
        expectedEncoding.put(cast(byte) 0xB1);
        expectedEncoding.putInt(cast(int) strPayload.length);
        expectedEncoding.put(strPayload);

        Data data = new DataImpl();
        data.putString(cast(string) strPayload);

        Binary encoded = data.encode();

        assertEquals("unexpected encoding", new Binary(expectedEncoding.array()), encoded);
    }

    void testEncodeStringBinary32() {
        byte[] payload = createStringPayloadBytes(1372);
        // assertTrue("Length must be over 255 to ensure use of vbin32 encoding", payload.length > 255);

        int encodedSize = 1 + 4 + cast(int) payload.length; // 1b type + 4b length + content
        ByteBuffer expectedEncoding = BufferUtils.allocate(encodedSize);
        expectedEncoding.put(cast(byte) 0xB0);
        expectedEncoding.putInt(cast(int) payload.length);
        expectedEncoding.put(payload);

        Data data = new DataImpl();
        data.putBinary(new Binary(payload));

        Binary encoded = data.encode();

        assertEquals("unexpected encoding", new Binary(expectedEncoding.array()), encoded);
    }

    private byte[] doEncodeDecodeBinaryTestImpl(byte[] payload) {
        Data data = new DataImpl();
        data.putBinary(payload);

        Binary encoded = data.encode();

        ByteBuffer byteBuffer = encoded.asByteBuffer();
        Data data2 = new DataImpl();
        long decodeResult = data2.decode(byteBuffer);
        //  assertTrue(Long.toString(decodeResult), decodeResult > 0);

        assertEquals("unexpected type", Data.DataType.BINARY, data2.type());
        return data2.getBinary().getArray();
    }

    void testEncodeDecodeBinary32() {
        byte[] initialPayload = createStringPayloadBytes(1025);
        String initialContent = new String(cast(string) initialPayload);
        //   assertTrue("Length must be over 255 to ensure use of str32 encoding", initialContent.length() > 255);

        byte[] bytesReadBack = doEncodeDecodeBinaryTestImpl(initialPayload);
        String readBackContent = new String(cast(string) bytesReadBack);
        assertEquals(initialContent, readBackContent);
    }
}

//void main()
//{
//    DataImplTest test = new DataImplTest;
//   // test.testEncodeDecodeSymbolArrayUsingPutArray;
//  //  test.testEncodeArrayOfLists;
//  //  test.testEncodeArrayOfMaps;
//  //  test.testEncodeString32;
//    //test.testEncodeStringBinary32;
//    test.testEncodeDecodeBinary32;
//}
