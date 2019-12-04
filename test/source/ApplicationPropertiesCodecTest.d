module ApplicationPropertiesCodecTest;

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
//import hunt.time.LocalDateTime;

import hunt.proton.amqp.messaging.AmqpValue;

class ApplicationPropertiesCodecTest : CodecTestSupport {

    this() {
    }

      public void doTestDecodeHeaderSeries(int size) {

        Map!(String, Object) propertiesMap = new LinkedHashMap!(String,Object);
        ApplicationProperties properties = new ApplicationProperties(propertiesMap);

        propertiesMap.put(new String("key-1"), new String("1"));
        propertiesMap.put(new String("key-2"), new String("2"));


        for (int i = 0; i < size; ++i) {
            encoder.writeObject(properties);
        }

        buffer.clear();

        for (int i = 0; i < size; ++i) {
            Object result = decoder.readObject();

            assertNotNull(result);
          //  assertTrue(result instanceof ApplicationProperties);

           // TypeConstructor!ApplicationProperties  rt = cast(TypeConstructor!ApplicationProperties) result;

            //if (rt is null)
            //{
            //    logError("Error");
            //}

            ApplicationProperties decoded   =  cast(ApplicationProperties) result;

            assertEquals(5, decoded.getValue().size());

            logInfof("%s",decoded.getValue().get(new String("key-5")));
            assertTrue(decoded.getValue() == (propertiesMap));
        }
    }
}


//void main()
//{
//    ApplicationPropertiesCodecTest app = new ApplicationPropertiesCodecTest();
//    app.setUp();
//    app.doTestDecodeHeaderSeries(128);
//}