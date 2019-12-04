module message.SaslImplTest;

import std.stdio;
import hunt.proton.engine.impl.TransportImpl;
import hunt.proton.engine.impl.SaslImpl;
import hunt.String;
import hunt.proton.amqp.Binary;
import hunt.Assert;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.proton.amqp.security.SaslFrameBody;
import hunt.proton.engine.impl.ProtocolTracer;
import hunt.proton.framing.TransportFrame;
import hunt.proton.amqp.security.SaslMechanisms;
import hunt.proton.amqp.Symbol;

class SaslImplTest {

    public void testPlainHelperEncodesExpectedResponse() {
        TransportImpl transport = new TransportImpl();
        SaslImpl sasl = new SaslImpl(transport, 512);

        // Use a username + password with a unicode char that encodes
        // differently under changing charsets
        string username = "username-with-unicode";
        string password = "password-with-unicode";

        byte[] usernameBytes = cast(byte[])username;
        byte[] passwordBytes = cast(byte[])password;

        byte[] expectedResponseBytes = new byte[usernameBytes.length + passwordBytes.length + 2];
        //System.arraycopy(usernameBytes, 0, expectedResponseBytes, 1, usernameBytes.length);
        expectedResponseBytes[1 .. 1+usernameBytes.length] = usernameBytes[0 ..usernameBytes.length ];
       // System.arraycopy(passwordBytes, 0, expectedResponseBytes, 2 + usernameBytes.length, passwordBytes.length);
        expectedResponseBytes[2 + usernameBytes.length .. 2 + usernameBytes.length + passwordBytes.length] = passwordBytes[0 ..passwordBytes.length ];
        sasl.plain(new String(username), new String(password));

        assertEquals("Unexpected response data", new Binary(expectedResponseBytes), sasl.getChallengeResponse());
    }


     public void testProtocolTracingLogsToTracer() {
        TransportImpl transport = new TransportImpl();
        List!SaslFrameBody bodies = new ArrayList!SaslFrameBody();
        transport.setProtocolTracer(new  class ProtocolTracer
        {
            public void receivedSaslBody( SaslFrameBody saslFrameBody)
            {
                bodies.add(saslFrameBody);
            }

            public void receivedFrame(TransportFrame transportFrame) { }

            public void sentFrame(TransportFrame transportFrame) { }
            void sentSaslBody(SaslFrameBody saslFrameBody) {}

            void receivedHeader(string header) {}
            void sentHeader(string header) {}
        });

        SaslImpl sasl = new SaslImpl(transport, 512);

        SaslMechanisms mechs = new SaslMechanisms();
        mechs.setSaslServerMechanisms(new ArrayList!Symbol([Symbol.valueOf("TESTMECH")]));

        assertEquals(0, bodies.size());
        sasl.handle(mechs, null);
        assertEquals(1, bodies.size());
        if (cast(SaslMechanisms)(bodies.get(0))  !is null)
        {
            writefln("yes");
        }
    }



}

//void main()
//{
//    SaslImplTest test = new SaslImplTest;
//   // test.testPlainHelperEncodesExpectedResponse;
//    test.testProtocolTracingLogsToTracer;
//}