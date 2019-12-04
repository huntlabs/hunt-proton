module MessageAnnotationsTypeCodecTest;

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
import hunt.collection.Map;
import hunt.collection.LinkedHashMap;
import hunt.Boolean;
import hunt.Byte;
import hunt.Char;
import hunt.Double;
import hunt.Float;
import hunt.String;
import hunt.Integer;
import hunt.Long;
import hunt.Short;
import hunt.proton.amqp.messaging.MessageAnnotations;
import hunt.proton.amqp.UnsignedShort;

class MessageAnnotationsTypeCodecTest  : CodecTestSupport{

    this() {
    }

        public void doTestDecodeMessageAnnotationsSeries(int size)  {

         Symbol SYMBOL_1 = Symbol.valueOf("test1");
         Symbol SYMBOL_2 = Symbol.valueOf("test2");
         Symbol SYMBOL_3 = Symbol.valueOf("test3");

        MessageAnnotations annotations = new MessageAnnotations(new LinkedHashMap!(Symbol,Object)());
        annotations.getValue().put(SYMBOL_1, UnsignedByte.valueOf(cast(byte) 128));
        annotations.getValue().put(SYMBOL_2, UnsignedShort.valueOf(cast(short) 128));
        annotations.getValue().put(SYMBOL_3, UnsignedInteger.valueOf(128));

        for (int i = 0; i < size; ++i) {
            encoder.writeObject(annotations);
        }

        buffer.clear();

        for (int i = 0; i < size; ++i) {
             Object result = decoder.readObject();

            assertNotNull(result);
         //   assertTrue(result instanceof MessageAnnotations);

            MessageAnnotations readAnnotations = cast(MessageAnnotations) result;

            Map!(Symbol, Object) resultMap = readAnnotations.getValue();

            assertEquals(annotations.getValue().size(), resultMap.size());
            assertEquals(resultMap.get(SYMBOL_1), UnsignedByte.valueOf(cast(byte) 128));
            assertEquals(resultMap.get(SYMBOL_2), UnsignedShort.valueOf(cast(short) 128));
            assertEquals(resultMap.get(SYMBOL_3), UnsignedInteger.valueOf(128));
        }
    }


    public void testEncodeAndDecodeAnnoationsWithEmbeddedMaps() {
         Symbol SYMBOL_1 = Symbol.valueOf("x-opt-test1");
         Symbol SYMBOL_2 = Symbol.valueOf("x-opt-test2");

         String VALUE_1 = new String("string");
         UnsignedInteger VALUE_2 = UnsignedInteger.valueOf(42);

        Map!(String, Object) stringKeyedMap = new LinkedHashMap!(String, Object)();
        stringKeyedMap.put( new String( "key1"), VALUE_1);
        stringKeyedMap.put( new String ("key2"), VALUE_2);

        Map!(Symbol, Object) symbolKeyedMap = new LinkedHashMap!(Symbol, Object)();
        symbolKeyedMap.put(Symbol.valueOf("key1"), VALUE_1);
        symbolKeyedMap.put(Symbol.valueOf("key2"), VALUE_2);

        MessageAnnotations annotations = new MessageAnnotations(new LinkedHashMap!(Symbol,Object)());
        annotations.getValue().put(SYMBOL_1, cast(Object)stringKeyedMap);
        annotations.getValue().put(SYMBOL_2, cast(Object)symbolKeyedMap);

        encoder.writeObject(annotations);

        buffer.clear();

         Object result = decoder.readObject();

        assertNotNull(result);

        MessageAnnotations readAnnotations = cast(MessageAnnotations) result;

        Map!(Symbol, Object) resultMap = readAnnotations.getValue();

         logInfo("%d",annotations.getValue().size());
         logInfo("%d",resultMap.size());
        //assertEquals(annotations.getValue().size(), resultMap.size());

        Map!(String, Object) strmp = cast(Map!(String, Object)) (resultMap.get(SYMBOL_1));
        Object st1 = strmp.get(new String( "key1"));
         if (st1 is null)
         {
             writefln("????");
         }
        logInfof("%s",cast(String)st1);

      //  assertEquals(cast(Map!(String, Object))(resultMap.get(SYMBOL_1)), stringKeyedMap);
       // assertEquals(cast(Map!(Symbol, Object))(resultMap.get(SYMBOL_2)), symbolKeyedMap);
    }

}

//void main()
//{
//    MessageAnnotationsTypeCodecTest test = new MessageAnnotationsTypeCodecTest();
//    test.setUp();
//
//    test.doTestDecodeMessageAnnotationsSeries(128);
//    //test.testEncodeAndDecodeAnnoationsWithEmbeddedMaps();
//}