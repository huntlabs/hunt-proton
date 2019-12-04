module MapTypeCodecTest;

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

class MapTypeCodecTest : CodecTestSupport {

    this() {
    }

     public void doTestDecodeMapSeries(int size)  {

        String myBoolKey = new String ("myBool");
        Boolean myBool =  new Boolean( true);
        String myByteKey = new String ("myByte");
        Byte myByte = new Byte( 4);

        String myCharKey = new String ("myChar");
        Char myChar = new Char('d');
        String myDoubleKey = new String ("myDouble");
        Double myDouble = new Double (1234567890123456789.1234);
        String myFloatKey = new String ("myFloat");
        Float myFloat = new Float (1.1F);
        String myIntKey = new String ("myInt");
        Integer myInt = new Integer( 2147483647);
        String myLongKey =new String ( "myLong");
        Long myLong = new Long( 0x7FFFFFFFFFFFFFFF);
        String myShortKey = new String ("myShort");
        Short myShort =  new Short(25);
        String myStringKey = new String( "myString");
        String myString = myStringKey;

        Map!(String, Object) map = new LinkedHashMap!(String, Object)();
        map.put(myBoolKey, myBool);
        map.put(myByteKey, myByte);
        map.put(myCharKey, myChar);
        map.put(myDoubleKey, myDouble);
        map.put(myFloatKey, myFloat);
        map.put(myIntKey, myInt);
        map.put(myLongKey, myLong);
        map.put(myShortKey, myShort);
        map.put(myStringKey, myString);

        for (int i = 0; i < size; ++i) {
            encoder.writeObject(cast(Object)map);
        }

        buffer.clear();

        for (int i = 0; i < size; ++i) {
             Object result = decoder.readObject();

            assertNotNull(result);
         //   assertTrue(result instanceof Map);

            Map!(String, Object) resultMap = cast(Map!(String, Object)) result;

            assertEquals(map.size(), resultMap.size());


            logInfof("----------------%d",(cast(Integer)resultMap.get(new String("myInt"))).intValue);
        }
    }

}

//void main()
//{
//    MapTypeCodecTest test = new MapTypeCodecTest;
//    test.setUp();
//    test.doTestDecodeMapSeries(1);
//}
