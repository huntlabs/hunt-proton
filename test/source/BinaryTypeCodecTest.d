module BinaryTypeCodecTest;

import std.stdio;
import std.stdio;
import CodecTestSupport;
import hunt.Assert ;
import hunt.String;
import  hunt.proton.codec.TypeConstructor;
import hunt.Assert ;
import hunt.logging;
import hunt.proton.amqp.Binary;


class BinaryTypeCodecTest: CodecTestSupport {

    this() {
    }

    public void doTestEncodeBinaryTypeReservation(int size){
        byte[] data = new byte[size];
        for (int i = 0; i < size; ++i) {
            data[i] = cast(byte) (i % 255);
        }

        Binary binary = new Binary(data);

       // WritableBuffer writable = new WritableBuffer.ByteBufferWrapper(this.buffer);
       // WritableBuffer spy = Mockito.spy(writable);

       // encoder.setByteBuffer(spy);
        encoder.writeBinary(binary);

        buffer.clear();



        Binary result = decoder.readBinary();
       // TypeConstructor!AmqpValue result = cast(TypeConstructor!AmqpValue) rs;

        assertNotNull(result);

        //assertEquals(value.getValue(), decoded.getValue());
        if (result == binary)
        {
            logInfo("yes");
        }

//        AmqpValue decoded = result.readValue();

        // Check that the BinaryType tries to reserve space, actual encoding size not computed here.
       // Mockito.verify(spy).ensureRemaining(Mockito.anyInt());
    }
}


//void main()
//{
//    BinaryTypeCodecTest  t = new BinaryTypeCodecTest();
//    t.setUp();
//    t.doTestEncodeBinaryTypeReservation(32);
//}
