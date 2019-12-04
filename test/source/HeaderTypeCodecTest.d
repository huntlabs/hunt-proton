module HeaderTypeCodecTest;

import std.stdio;
import CodecTestSupport;
import hunt.Assert ;
import hunt.String;
import  hunt.proton.codec.TypeConstructor;
import hunt.Assert ;
import hunt.logging;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.messaging.Header;
import hunt.Boolean;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedByte;

class HeaderTypeCodecTest : CodecTestSupport {

    this() {
    }

     private void doTestDecodeHeaderSeries(int size) {
        Header header = new Header();

        header.setDurable(true);
        header.setPriority(UnsignedByte.valueOf(cast(byte) 3));
        header.setDeliveryCount(UnsignedInteger.valueOf(10));
        header.setFirstAcquirer(false);
        header.setTtl(UnsignedInteger.valueOf(500));

        for (int i = 0; i < size; ++i) {
            encoder.writeObject(header);
        }

        buffer.clear();

        for (int i = 0; i < size; ++i) {
            Object rs = decoder.readObject();
           // TypeConstructor!Header result = cast(TypeConstructor!Header) rs;


           // assertNotNull(result);

            Header decoded  = cast(Header) rs;

            assertEquals(3, decoded.getPriority().intValue());
            assertTrue(decoded.getDurable().booleanValue());
            assertEquals(UnsignedInteger.valueOf(500), decoded.getTtl());
        }
    }

     public void testSkipHeader()  {
        Header header1 = new Header();
        Header header2 = new Header();

        header1.setDurable(false);
        header2.setDurable(true);

        encoder.writeObject(header1 );
        encoder.writeObject(header2);

        buffer.clear();

        ITypeConstructor headerType = decoder.readConstructor();
       // assertEquals(Header.class, headerType.getTypeClass());
        headerType.skipValue();
      //
        Object rs = decoder.readObject();
      //
      //   TypeConstructor!Header result = cast( TypeConstructor!Header ) rs;
      //
      //  assertNotNull(result);
      ////  assertTrue(result instanceof Header);
      //
        Header decoded =  cast(Header)rs;
        assertTrue(decoded.getDurable().booleanValue());
    }
}

//void main()
//{
//    HeaderTypeCodecTest test = new HeaderTypeCodecTest;
//    test.setUp();
//   // test.doTestDecodeHeaderSeries(128);
//    test.testSkipHeader;
//}
