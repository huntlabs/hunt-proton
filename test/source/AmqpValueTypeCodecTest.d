module AmqpValueTypeCodecTest;

import std.stdio;
import CodecTestSupport;
import hunt.Assert ;
import hunt.String;
import  hunt.proton.codec.TypeConstructor;
import hunt.Assert ;
import hunt.logging;
//import hunt.time.LocalDateTime;

import hunt.proton.amqp.messaging.AmqpValue;



class AmqpValueTypeCodecTest  : CodecTestSupport{

    int LARGE_SIZE = 1024;
    int SMALL_SIZE = 32;

    this() {
    }


    public void doTestDecodeAmqpValueSeries(int size, AmqpValue value) {

        for (int i = 0; i < size; ++i) {
            encoder.writeObject(value);
        }

        buffer.clear();


        for (int i = 0; i < size; ++i) {
            Object rs = decoder.readObject();
          //  TypeConstructor!AmqpValue result = cast(TypeConstructor!AmqpValue) rs;

             assertNotNull(rs);



            AmqpValue decoded = cast(AmqpValue)rs;

            if (decoded.getValue !is null)
            {
                logInfof("%s",decoded.getValue());
                writefln("sssss %s",cast(string)(decoded.getValue().getBytes()));
                writefln(("%d"),decoded.getValue().getBytes().length);
            }
            assertEquals(value.getValue(), decoded.getValue());
        }
    }
}


//void main()
//{
//    //String a = new String("123");
//    //String b = a;
//    //logInfof("%s",b);
//    AmqpValueTypeCodecTest test = new AmqpValueTypeCodecTest();
//    test.setUp();
//    test.doTestDecodeAmqpValueSeries(1, new AmqpValue(new String("test")));
//}