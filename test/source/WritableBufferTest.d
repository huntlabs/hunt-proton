module WritableBufferTest;

import std.stdio;
import CodecTestSupport;
import hunt.Assert ;
import hunt.String;
import  hunt.proton.codec.TypeConstructor;
import hunt.Assert ;
import hunt.logging;
import hunt.Exceptions;
import hunt.Boolean;
import hunt.io.ByteBuffer;
import hunt.io.BufferUtils;
import hunt.proton.codec.ReadableBuffer;
import hunt.collection.List;
import hunt.Float;
import hunt.Double;
import hunt.proton.codec.WritableBuffer;


class DefaultWritableBuffer : WritableBuffer {

        private  WritableBuffer backing;

        this(){
            backing = ByteBufferWrapper.allocate(1024);
        }

        override
        public void put(byte b) {
            backing.put(b);
        }

        override
        public void putFloat(float f) {
            backing.putFloat(f);
        }

        override
        public void putDouble(double d) {
            backing.putDouble(d);
        }

        override
        public void put(byte[] src, int offset, int length) {
            backing.put(src, offset, length);
        }

        override
        public void putShort(short s) {
            backing.putShort(s);
        }

        override
        public void putInt(int i) {
            backing.putInt(i);
        }

        override
        public void putLong(long l) {
            backing.putLong(l);
        }

        override
        public bool hasRemaining() {
            return backing.hasRemaining();
        }

        override
        public int remaining() {
            return backing.remaining();
        }

        override
        public int position() {
            return backing.position();
        }

        override
        public void position(int position) {
            backing.position(position);
        }

        override
        public void put(ByteBuffer payload) {
            backing.put(payload);
        }

        override
        public void put(ReadableBuffer payload) {
            backing.put(payload);
        }

        override
        public int limit() {
            return backing.limit();
        }
    }

class WritableBufferTest {

    this() {
    }
    public void testCreateAllocatedWrapper() {
        WritableBuffer buffer = ByteBufferWrapper.allocate(10);

        assertEquals(10, buffer.remaining());
        assertEquals(0, buffer.position());
        assertTrue(buffer.hasRemaining());
    }

        public void testCreateByteArrayWrapper() {
        byte[] data =  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
        WritableBuffer buffer = ByteBufferWrapper.wrap(data);

        assertEquals(10, buffer.remaining());
        assertEquals(0, buffer.position());
        assertTrue(buffer.hasRemaining());
    }

    public void testLimit() {
        ByteBuffer data = BufferUtils.allocate(100);
        WritableBuffer buffer = ByteBufferWrapper.wrap(data);

        assertEquals(data.capacity(), buffer.limit());
    }

        public void testRemaining() {
        ByteBuffer data = BufferUtils.allocate(100);
        WritableBuffer buffer = ByteBufferWrapper.wrap(data);

        assertEquals(data.limit(), buffer.remaining());
        buffer.put(cast(byte) 0);
        assertEquals(data.limit() - 1, buffer.remaining());
    }

    // -----------------------------------

     public void testHasRemaining() {
        ByteBuffer data = BufferUtils.allocate(100);
        WritableBuffer buffer = ByteBufferWrapper.wrap(data);

        assertTrue(buffer.hasRemaining());
        buffer.put(cast(byte) 0);
        assertTrue(buffer.hasRemaining());
        data.position(data.limit());
        assertFalse(buffer.hasRemaining());
    }

    public void testEnsureRemainingThrowsWhenExpected() {
        ByteBuffer data = BufferUtils.allocate(100);
        WritableBuffer buffer = ByteBufferWrapper.wrap(data);

        assertEquals(data.capacity(), buffer.limit());
        try {
            buffer.ensureRemaining(1024);
            fail("Should have thrown an error on request for more than is available.");
        } catch (BufferOverflowException boe) {}

        try {
            buffer.ensureRemaining(-1);
            fail("Should have thrown an error on request for negative space.");
        } catch (IllegalArgumentException iae) {}
    }

    public void testEnsureRemainingDefaultImplementation() {
        WritableBuffer buffer = new DefaultWritableBuffer();

        try {
            buffer.ensureRemaining(1024);
        } catch (IndexOutOfBoundsException iobe) {
            fail("Should not have thrown an error on request for more than is available.");
        }

        try {
            buffer.ensureRemaining(-1);
        } catch (IllegalArgumentException iae) {
            fail("Should not have thrown an error on request for negative space.");
        }
    }

    public void testGetPosition() {
        ByteBuffer data = BufferUtils.allocate(100);
        WritableBuffer buffer = ByteBufferWrapper.wrap(data);

        assertEquals(0, buffer.position());
        data.put(cast(byte) 0);
        assertEquals(1, buffer.position());
    }

    public void testSetPosition() {
        ByteBuffer data = BufferUtils.allocate(100);
        WritableBuffer buffer = ByteBufferWrapper.wrap(data);

        assertEquals(0, data.position());
        buffer.position(1);
        assertEquals(1, data.position());
    }

    public void testPutByteBuffer() {
        ByteBuffer input = BufferUtils.allocate(1024);
        input.put(cast(byte) 1);
        input.flip();

        ByteBuffer data = BufferUtils.allocate(1024);
        WritableBuffer buffer = ByteBufferWrapper.wrap(data);

        assertEquals(0, buffer.position());
        buffer.put(input);
        assertEquals(1, buffer.position());
    }

    public void testPutString() {
        String ascii = new String("ASCII");

        ByteBuffer data = BufferUtils.allocate(1024);
        WritableBuffer buffer = ByteBufferWrapper.wrap(data);

        assertEquals(0, buffer.position());
        buffer.put(cast(string)(ascii.getBytes()));
        if (cast(int)(ascii.getBytes().length) != buffer.position() )
        {
            logError("error");
        }
    }


}

//void main()
//{
//    WritableBufferTest test = new WritableBufferTest;
//
//    //test.testCreateByteArrayWrapper;
//    //test.testCreateAllocatedWrapper;
//    //test.testLimit;
//    //test.testRemaining;
//
//
//    test.testHasRemaining;
//    test.testEnsureRemainingThrowsWhenExpected;
//    test.testEnsureRemainingDefaultImplementation;
//    test.testGetPosition;
//    test.testSetPosition;
//    test.testPutByteBuffer;
//    test.testPutString;
//}