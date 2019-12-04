module SymbolTypeTest;

import std.stdio;
import CodecTestSupport;
import hunt.Assert ;
import hunt.String;
import  hunt.proton.codec.TypeConstructor;
import hunt.Assert ;
import hunt.logging;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.security.SaslInit;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.security.SaslMechanisms;
import hunt.collection.ArrayList;
import hunt.proton.codec.security.SaslOutcomeType;
import hunt.proton.amqp.security.SaslOutcome;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.security.SaslFrameBody;
import hunt.proton.amqp.security.SaslCode;
import hunt.proton.amqp.transport.Open;
import hunt.proton.codec.transport.OpenType;
import hunt.collection.Map;
import hunt.collection.LinkedHashMap;
import hunt.proton.codec.transport.DetachType;
import hunt.proton.amqp.transport.Detach;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.transport.Attach;
import hunt.proton.amqp.transport.ReceiverSettleMode;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.Role;
import hunt.proton.amqp.transport.SenderSettleMode;
import hunt.proton.amqp.messaging.Section;
import hunt.proton.amqp.messaging.AmqpValue;
//import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.messaging.Source;
//import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.messaging.Properties;
import hunt.proton.amqp.messaging.Released;

class SymbolTypeTest : CodecTestSupport{

    this() {
    }

    public void doTestDecodeAmqpValueSeries(int size, Symbol value) {

        for (int i = 0; i < size; ++i) {
            encoder.writeObject(value);
        }

        buffer.clear();


        for (int i = 0; i < size; ++i) {
            Object rs = decoder.readObject();
            //  TypeConstructor!AmqpValue result = cast(TypeConstructor!AmqpValue) rs;

            assertNotNull(rs);



            Symbol decoded = cast(Symbol)rs;

            assertEquals(value.getUnderlying(), decoded.getUnderlying());
        }
    }

    public void doTestDecodeSasl(int size, SaslInit value) {

        for (int i = 0; i < size; ++i) {
            encoder.writeObject(value);
        }

        buffer.clear();


        for (int i = 0; i < size; ++i) {
            Object rs = decoder.readObject();
            //  TypeConstructor!AmqpValue result = cast(TypeConstructor!AmqpValue) rs;

            assertNotNull(rs);



            SaslInit decoded = cast(SaslInit)rs;
            writefln(cast(string)(decoded.getHostname().getBytes()));
            writefln((decoded.getMechanism().toString));
           // assertEquals(value.getUnderlying(), decoded.getUnderlying());
        }
    }


    public void doTestDecodeSaslMech(int size, SaslMechanisms value) {

        for (int i = 0; i < size; ++i) {
            encoder.writeObject(value);
        }

        buffer.clear();


        for (int i = 0; i < size; ++i) {
            Object rs = decoder.readObject();
            //  TypeConstructor!AmqpValue result = cast(TypeConstructor!AmqpValue) rs;

            assertNotNull(rs);



            SaslMechanisms decoded = cast(SaslMechanisms)rs;
            foreach(Symbol s  ; decoded.getSaslServerMechanisms)
            {
                writefln("%s",s.toString);
            }
            // assertEquals(value.getUnderlying(), decoded.getUnderlying());
        }
    }



    public void doTestDecodeOutcome(int size, SaslOutcome value) {

        value.setCode(SaslCode.OK());
        value.setAdditionalData(new Binary([1,3]));

        for (int i = 0; i < size; ++i) {
            encoder.writeObject(value);
        }

        buffer.clear();


        for (int i = 0; i < size; ++i) {
            Object rs = decoder.readObject();
            //  TypeConstructor!AmqpValue result = cast(TypeConstructor!AmqpValue) rs;

            assertNotNull(rs);



            SaslOutcome decoded = cast(SaslOutcome)rs;
            //writefln(cast(string)(decoded.getHostname().getBytes()));
            //writefln((decoded.getMechanism().toString));
            assertEquals(SaslCode.OK(), decoded.getCode());
            assertEquals(new Binary([1,3]), decoded.getAdditionalData);
        }
    }

    public void doTestDecodeOpen(int size, Open value) {

        Map!(Symbol,Object) mp = new LinkedHashMap!(Symbol,Object);
        mp.put(Symbol.valueOf("test"), new String("haha"));

        value.setContainerId(new String("cid"));
        value.setHostname(null);
        value.setDesiredCapabilities(null);
        value.setOfferedCapabilities(null);
        value.setProperties(mp);

        for (int i = 0; i < size; ++i) {
            encoder.writeObject(value);
        }

        buffer.clear();


        for (int i = 0; i < size; ++i) {
            Object rs = decoder.readObject();
            //  TypeConstructor!AmqpValue result = cast(TypeConstructor!AmqpValue) rs;

            assertNotNull(rs);



            Open decoded = cast(Open)rs;

            //writefln(cast(string)(decoded.getHostname().getBytes()));
            writefln("%s",cast(string)(decoded.getContainerId().getBytes()));
            Map!(Symbol,Object) tmp = decoded.getProperties();
            if (tmp is null)
            {
                writefln("tmp null");
            }else
            {
                Object str = tmp.get(Symbol.valueOf("test"));
                if (str is null)
                {
                    writefln("str null");
                }else
                {
                    String s = cast(String)str;
                    if (s is null)
                    {
                        writefln("s null");
                    }
                }

            }


           // writefln("%s", (cast(String)(decoded.getProperties().get(Symbol.valueOf("test")))).value);
          //  assertEquals(SaslCode.OK(), decoded.getCode());
           // assertEquals(new Binary([1,3]), decoded.getAdditionalData);
        }
    }

    public void doTestDecodeDetach(int size, Detach value) {

        //value.setCode(SaslCode.OK());
        //value.setAdditionalData(new Binary([1,3]));
        value.setHandle(UnsignedInteger.ZERO);
        value.setError(null);
        value.setClosed(null);

        for (int i = 0; i < size; ++i) {
            encoder.writeObject(value);
        }

        buffer.clear();


        for (int i = 0; i < size; ++i) {
            Object rs = decoder.readObject();
            //  TypeConstructor!AmqpValue result = cast(TypeConstructor!AmqpValue) rs;

           // assertNotNull(rs);
           // if (rs is null)
           // {
           //     writefln("yes");
           // }


            Detach decoded = cast(Detach)rs;
            ////writefln(cast(string)(decoded.getHostname().getBytes()));
            ////writefln((decoded.getMechanism().toString));
            //assertEquals(SaslCode.OK(), decoded.getCode());
            assertEquals(UnsignedInteger.ZERO(), decoded.getHandle());
            if (decoded.getError() is null)
            {
                writefln("yes");
            }
        }
    }


    public void doTestDecodeAttach(int size, Attach value) {

        //value.setCode(SaslCode.OK());
        //value.setAdditionalData(new Binary([1,3]));
        Source sour = new hunt.proton.amqp.messaging.Source.Source();
        sour.setAddress(new String("no1")) ;
        sour.setDefaultOutcome(Released.getInstance());

        value.setHandle(UnsignedInteger.ZERO);
        value.setName(new String("test"));
        value.setMaxMessageSize(UnsignedLong.valueOf("324455"));
        value.setRole( Role.RECEIVER );
        value.setSndSettleMode(SenderSettleMode.MIXED);
        value.setSource(sour);
        for (int i = 0; i < size; ++i) {
            encoder.writeObject(value);
        }

        buffer.clear();


        for (int i = 0; i < size; ++i) {
            Object rs = decoder.readObject();
            //  TypeConstructor!AmqpValue result = cast(TypeConstructor!AmqpValue) rs;

            // assertNotNull(rs);
            // if (rs is null)
            // {
            //     writefln("yes");
            // }


            Attach decoded = cast(Attach)rs;
            ////writefln(cast(string)(decoded.getHostname().getBytes()));
            ////writefln((decoded.getMechanism().toString));
            //assertEquals(SaslCode.OK(), decoded.getCode());
            assertEquals(UnsignedInteger.ZERO(), decoded.getHandle());
            assertEquals(UnsignedLong.valueOf("324455"), decoded.getMaxMessageSize());
            assertEquals(ReceiverSettleMode.FIRST,decoded.getRcvSettleMode());
            assertEquals(Role.RECEIVER,decoded.getRole());
            assertEquals(SenderSettleMode.MIXED,decoded.getSndSettleMode());
            assertEquals(sour.getDefaultOutcome(),(cast(Source)(decoded.getSource())).getDefaultOutcome());
            //if (decoded.getError() is null)
            //{
            //    writefln("yes");
            //}
        }
    }


    public void doTestDecodeSection(int size, Section value) {

        //value.setCode(SaslCode.OK());
        //value.setAdditionalData(new Binary([1,3]));
        //value.setHandle(UnsignedInteger.ZERO);
        //value.setName(new String("test"));
        //value.setMaxMessageSize(UnsignedLong.valueOf("324455"));
        //value.setRole( Role.RECEIVER );
        //value.setSndSettleMode(SenderSettleMode.MIXED);
        for (int i = 0; i < size; ++i) {
            encoder.writeObject(cast(Object)value);
        }

        buffer.clear();


        for (int i = 0; i < size; ++i) {
            Object rs = decoder.readObject();
            //  TypeConstructor!AmqpValue result = cast(TypeConstructor!AmqpValue) rs;

            // assertNotNull(rs);
            // if (rs is null)
            // {
            //     writefln("yes");
            // }


            Section decoded = cast(Section)rs;
            AmqpValue v = cast(AmqpValue)decoded;


            ////writefln(cast(string)(decoded.getHostname().getBytes()));
            writefln("%s",v.getValue.value);
            //assertEquals(SaslCode.OK(), decoded.getCode());
            //assertEquals(UnsignedInteger.ZERO(), decoded.getHandle());
            //assertEquals(UnsignedLong.valueOf("324455"), decoded.getMaxMessageSize());
            //assertEquals(ReceiverSettleMode.FIRST,decoded.getRcvSettleMode());
            //assertEquals(Role.RECEIVER,decoded.getRole());
            //assertEquals(SenderSettleMode.MIXED,decoded.getSndSettleMode());
            //if (decoded.getError() is null)
            //{
            //    writefln("yes");
            //}
        }
    }
}
//
//void main()
//{
//    SymbolTypeTest test = new SymbolTypeTest;
//    test.setUp();
//    //
//    //test.doTestDecodeAmqpValueSeries(1, Symbol.valueOf("test"));
//    //SaslInit init= new SaslInit;
//    //init.setHostname(new String("test"));
//    //init.setMechanism(Symbol.valueOf("NOO"));
//    //init.setInitialResponse(new Binary([1,23]));
//    //test.doTestDecodeSasl(1,init);
//    //SaslMechanisms mech = new SaslMechanisms;
//    //mech.setSaslServerMechanisms(new ArrayList!Symbol([Symbol.valueOf("123"),Symbol.valueOf("dff")]));
//    //test.doTestDecodeSaslMech(1,mech);
//    //SaslOutcome come = new SaslOutcome;
//    //test.doTestDecodeOutcome(1,come);
//    //Open op = new Open;
//    //test.doTestDecodeOpen(1,op);
//    //Detach d = new Detach;
//    //test.doTestDecodeDetach(1,d);
//
//    Attach attch = new Attach;
//    test.doTestDecodeAttach(1,attch);
//}