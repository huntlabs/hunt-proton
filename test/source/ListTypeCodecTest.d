module ListTypeCodecTest;

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
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.proton.amqp.Symbol;
import std.conv : to;

class ListTypeCodecTest :  CodecTestSupport{

    this() {
    }

        public void doTestDecodeListSeries(int size) {
        List!Object list = new ArrayList!Object();

      //  Date timeNow = new Date(System.currentTimeMillis());

        list.add(new String("ID:Message-1:1:1:0"));
        list.add(new Binary(new byte[1]));
        list.add(new String( "queue:work"));
        list.add(Symbol.valueOf("text/UTF-8"));
        list.add(Symbol.valueOf("text"));
       // list.add(timeNow);
        list.add(UnsignedInteger.valueOf(1));
       // list.add(UUID.randomUUID());

        for (int i = 0; i < size; ++i) {
            encoder.writeObject(cast(Object)list);
        }

        buffer.clear();

        for (int i = 0; i < size; ++i) {
            Object result = decoder.readObject();

            assertNotNull(result);
          //  assertTrue(result instanceof List);

            List!Object resultList = cast(List!Object) result;

            logInfof("%s",(cast(Symbol)resultList.get(3)).getUnderlying);

          //  assertEquals(list.size(), resultList.size());
        }
    }


     public void doTestDecodeSymbolListSeries(int size)  {
        List!Object list = new ArrayList!Object();

        for (int i = 0; i < 50; ++i) {
            list.add(Symbol.valueOf((to!string(i))));
        }

        for (int i = 0; i < size; ++i) {
            encoder.writeObject(cast(Object)list);
        }

        buffer.clear();

        for (int i = 0; i < size; ++i) {
            Object result = decoder.readObject();

            assertNotNull(result);

            List!Object resultList = cast(List!Object) result;

            assertEquals(list.size(), resultList.size());
        }
    }


}

//void main()
//{
//    ListTypeCodecTest test = new ListTypeCodecTest;
//    test.setUp();
//   // test.doTestDecodeListSeries(1);
//    test.doTestDecodeSymbolListSeries(128);
//}