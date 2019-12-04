module UnknownDescribedTypeCodecTest;

import std.stdio;
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
import hunt.proton.amqp.UnsignedInteger;
import NoLocalType;
import hunt.proton.amqp.DescribedType;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.proton.amqp.UnsignedLong;


class UnknownDescribedTypeCodecTest  : CodecTestSupport {

    NoLocalType NO_LOCAL;
    this() {
        NO_LOCAL = new NoLocalType;
    }

      public void testDecodeUnknownDescribedType()  {
        encoder.writeObject(NO_LOCAL);

        buffer.clear();

        Object result = decoder.readObject();
        DescribedType resultTye = cast(DescribedType) result;
        assertEquals(NO_LOCAL.getDescriptor(), resultTye.getDescriptor());
    }


       public void doTestDecodeUnknownDescribedTypeSeries(int size)  {
        for (int i = 0; i < size; ++i) {
            encoder.writeObject(NO_LOCAL);
        }

        buffer.clear();

        for (int i = 0; i < size; ++i) {
             Object result = decoder.readObject();

            assertNotNull(result);

            DescribedType resultTye = cast(DescribedType) result;
            assertEquals(NO_LOCAL.getDescriptor(), resultTye.getDescriptor());
        }
    }

    void testUnknownDescribedTypeInList()  {
        List!Object listOfUnkowns = new ArrayList!Object();

        listOfUnkowns.add(NO_LOCAL);

        encoder.writeList(cast(Object)listOfUnkowns);

        buffer.clear();

         Object result = decoder.readObject();

        assertNotNull(result);

        List!Object decodedList = cast(List!Object) result;
        assertEquals(1, decodedList.size());

        Object listEntry = decodedList.get(0);

        DescribedType resultTye =cast (DescribedType) listEntry;
        assertEquals(NO_LOCAL.getDescriptor(), resultTye.getDescriptor());
    }


      public void testUnknownDescribedTypeInMap()  {
        Map!(Object, Object) mapOfUnknowns = new LinkedHashMap!(Object,Object)();

        mapOfUnknowns.put((NO_LOCAL.getDescriptor()), NO_LOCAL);

        encoder.writeMap(cast(Object)mapOfUnknowns);

        buffer.clear();

         Object result = decoder.readObject();

        assertNotNull(result);

         Map!(Object, Object) decodedMap = cast(Map!(Object, Object)) result;
        assertEquals(1, decodedMap.size());

        Object mapEntry = decodedMap.get((NO_LOCAL.getDescriptor()));
        if (mapEntry is null)
        {
            writefln("NO");
        }
        //foreach(MapEntry!(Object, Object) entry ; decodedMap)
        //{
        //    Object key = entry.getKey();
        //    UnsignedLong k = cast(UnsignedLong)key;
        //    writefln("111111111111 %d",k.longValue);
        //    if (k.longValue == (cast(UnsignedLong)(NO_LOCAL.getDescriptor())).longValue())
        //    {
        //        writefln("Yes");
        //    }
        //}

        //  writefln("2222222222  %d",(cast(UnsignedLong)(NO_LOCAL.getDescriptor())).longValue());
        DescribedType resultTye = cast(DescribedType) mapEntry;
        if (resultTye is null)
        {
            writefln("NO");
        }
        assertEquals(NO_LOCAL.getDescriptor(), resultTye.getDescriptor);
    }

}

//void main()
//{
//    UnknownDescribedTypeCodecTest test = new UnknownDescribedTypeCodecTest;
//    test.setUp();
//    //test.testUnknownDescribedTypeInMap;
//    test.doTestDecodeUnknownDescribedTypeSeries(1);
//
//   //test.testUnknownDescribedTypeInList;
//   // test.testDecodeUnknownDescribedType;
//   // test.doTestDecodeUnknownDescribedTypeSeries(128);
//
//}
