module PropertiesCodecTest;

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

alias Date = LocalDateTime;

class PropertiesCodecTest : CodecTestSupport {

    this() {
    }

    public void doTestDecodePropertiesSeries(int size) {
        Properties properties = new Properties();

        Date timeNow = Date.now;

        properties.setMessageId(new String("ID:Message-1:1:1:0"));
        properties.setUserId(new Binary(new byte[1]));
        properties.setTo(new String ("queue:work"));
        properties.setSubject(new String("help"));
        properties.setReplyTo( new String("queue:temp:me"));
        properties.setContentEncoding(Symbol.valueOf("text/UTF-8"));
        properties.setContentType(Symbol.valueOf("text"));
        properties.setCorrelationId(new String("correlation-id"));
        properties.setAbsoluteExpiryTime(timeNow);
        properties.setCreationTime(timeNow);
        properties.setGroupId(new String("group-1"));
        properties.setGroupSequence(UnsignedInteger.valueOf(1));
        properties.setReplyToGroupId(new String("group-1"));

        for (int i = 0; i < size; ++i) {
            encoder.writeObject(properties);
        }

        buffer.clear();

        for (int i = 0; i < size; ++i) {
             Object result = decoder.readObject();

            assertNotNull(result);

            Properties decoded = cast(Properties) result;

           //  assertEquals(Date.ofEpochMilli(100),Date.ofEpochMilli(100));

             //writefln("%d",timeNow.toEpochMilli);
             //writefln("%d",decoded.getAbsoluteExpiryTime().toEpochMilli);

            assertNotNull(decoded.getAbsoluteExpiryTime());
            assertEquals(timeNow.toEpochMilli(), decoded.getAbsoluteExpiryTime().toEpochMilli());
            assertEquals(Symbol.valueOf("text/UTF-8"), decoded.getContentEncoding());
            assertEquals(Symbol.valueOf("text"), decoded.getContentType());
            assertEquals(new String("correlation-id"), decoded.getCorrelationId());
            assertEquals(timeNow.toEpochMilli(), decoded.getCreationTime().toEpochMilli());
            assertEquals(new String("group-1"), decoded.getGroupId());
            assertEquals(UnsignedInteger.valueOf(1), decoded.getGroupSequence());
            assertEquals(new String("ID:Message-1:1:1:0"), decoded.getMessageId());
            assertEquals(new String("queue:temp:me"), decoded.getReplyTo());
            assertEquals(new String("group-1"), decoded.getReplyToGroupId());
            assertEquals(new String("help"), decoded.getSubject());
            assertEquals(new String("queue:work"), decoded.getTo());
           // assertTrue(decoded.getUserId() instanceof Binary);
        }
    }
}


//void main()
//{
//    PropertiesCodecTest test = new PropertiesCodecTest;
//    test.setUp();
//
//    test.doTestDecodePropertiesSeries(1);
//}