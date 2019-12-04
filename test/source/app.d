import std.stdio;

import hunt.proton.amqp.messaging.Header;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.UnsignedByte;
import hunt.proton.amqp.UnsignedShort;

import hunt.proton.amqp.messaging.Properties;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.Binary;
import hunt.Assert ;
//import hunt.time.LocalDateTime;
import hunt.String;
import hunt.proton.amqp.transport.Attach;
import hunt.proton.amqp.transport.Role;
import hunt.proton.amqp.transport.SenderSettleMode;
import hunt.proton.amqp.transport.ReceiverSettleMode;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Target;
import hunt.collection.Map;
import hunt.collection.HashMap;
import hunt.collection.LinkedHashMap;
import hunt.proton.amqp.transport.Begin;
import hunt.proton.amqp.transport.Flow;
import hunt.proton.amqp.transport.Close;
import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.amqp.transport.Detach;
import hunt.proton.amqp.transport.End;
import hunt.proton.amqp.transport.Open;
import hunt.proton.amqp.transport.Transfer;
import hunt.collection.Collections;
import  hunt.math.BigInteger;
import hunt.Long;
import hunt.Exceptions;
import hunt.proton.codec.Data;
import hunt.proton.codec.impl.DataImpl;
import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.collection.List;
import hunt.collection.ArrayList;


//alias Date = LocalDateTime;
//
//byte[] TWO_TO_64_PLUS_ONE_BYTES = [1,0,0,0,0,0,0,0,1]; //new byte[] { (byte) 1, (byte) 0, (byte) 0, (byte) 0, (byte) 0, (byte) 0, (byte) 0, (byte) 0, (byte) 1 };
//byte[] TWO_TO_64_MINUS_ONE_BYTES = [1,1,1,1,1,1,1,1] ;//new byte[] {(byte) 1, (byte) 1, (byte) 1, (byte) 1, (byte) 1, (byte) 1, (byte) 1, (byte) 1 };
//
//
//byte[] doEncodeDecodeBinaryTestImpl(byte[] payload)
//{
//    Data data = new DataImpl();
//    data.putBinary(payload);
//
//    Binary encoded = data.encode();
//
//    ByteBuffer byteBuffer = encoded.asByteBuffer();
//    Data data2 = new DataImpl();
//    long decodeResult = data2.decode(byteBuffer);
//  //  assertTrue(Long.toString(decodeResult), decodeResult > 0);
//    writefln("%d",decodeResult);
//
//    assertEquals("unexpected type", Data.DataType.BINARY, data2.type());
//    return data2.getBinary().getArray();
//}
//
//
//void doEncodeDecodeStringTestImpl(string str)
//{
//    Data data = new DataImpl();
//    data.putString(str);
//
//    Binary encoded = data.encode();
//
//    Data data2 = new DataImpl();
//    data2.decode(encoded.asByteBuffer());
//
//    assertEquals("unexpected type", Data.DataType.STRING, data2.type());
//    assertEquals("unexpected string", str, data2.getString());
//}
//
//
//byte[] createStringPayloadBytes(int length)
//    {
//        byte[] payload = new byte[length];
//        for (int i = 0; i < length; i++) {
//            payload[i] = cast(byte) ((i % 10) + 48);
//        }
//
//        return payload;
//    }
//
//void assertErrorConditionsNotEqual(ErrorCondition error1, ErrorCondition error2)
//    {
//            Assert.assertNotEquals(error1, error2);
//            Assert.assertNotEquals(error2, error1);
//    }
//
//void assertErrorConditionsEqual(ErrorCondition error1, ErrorCondition error2)
//{
//        assertEquals(error1, error2);
//        assertEquals(error2, error1);
//        assertEquals(error1.hashCode(), error2.hashCode());
//}
//
//
//Binary createSteppedValueBinary(int length) {
//    byte[] bytes = new byte[length];
//    for (int i = 0; i < length; i++) {
//        bytes[i] = cast(byte) (length - i);
//    }
//
//    return new Binary(bytes);
//}
//
//Binary createNewRepeatedValueBinary(int length, byte repeatedByte){
//    byte[] bytes = new byte[length];
//    for(int i = 0 ; i < length ; i++)
//    {
//        bytes[i] = repeatedByte;
//    }
//
//    return new Binary(bytes);
//}


//void main()
//{
	//Header original = new Header();
	//
	//original.setDeliveryCount(UnsignedInteger.valueOf(1));
	//original.setDurable(true);
	//original.setFirstAcquirer(true);
	//original.setPriority(UnsignedByte.valueOf(cast(byte) 7));
	//original.setTtl(UnsignedInteger.valueOf(100));
	//
	//Header copy = new Header(original);
	//
	//assertEquals(original.getDeliveryCount(), copy.getDeliveryCount());
	//assertEquals(original.getDurable(), copy.getDurable());
	//assertEquals(original.getFirstAcquirer(), copy.getFirstAcquirer());
	//assertEquals(original.getPriority(), copy.getPriority());
	//assertEquals(original.getTtl(), copy.getTtl());



	//Properties original = new Properties();
	//
	//original.setAbsoluteExpiryTime(Date.now());
	//original.setContentEncoding(Symbol.valueOf("utf-8"));
	//original.setContentType(Symbol.valueOf("test/plain"));
	//original.setCorrelationId(new String("1"));
	//original.setCreationTime(Date.now());
	//original.setGroupId(new String("group-1"));
	//original.setGroupSequence(UnsignedInteger.MAX_VALUE);
	//original.setMessageId( new String("ID:1"));
	//original.setReplyTo(new String("queue"));
	//original.setReplyToGroupId(new String("3"));
	//original.setSubject(new String("subject"));
	//original.setTo( new String("to-queue"));
	//original.setUserId(new Binary(new byte[1]));
	//
	//Properties copy = new Properties(original);
	//
	//assertEquals(original.getAbsoluteExpiryTime(), copy.getAbsoluteExpiryTime());
	//assertEquals(original.getContentEncoding(), copy.getContentEncoding());
	//assertEquals(original.getContentType(), copy.getContentType());
	//assertEquals(original.getCorrelationId(), copy.getCorrelationId());
	//assertEquals(original.getCreationTime(), copy.getCreationTime());
	//assertEquals(original.getGroupId(), copy.getGroupId());
	//assertEquals(original.getGroupSequence(), copy.getGroupSequence());
	//assertEquals(original.getMessageId(), copy.getMessageId());
	//assertEquals(original.getReplyTo(), copy.getReplyTo());
	//assertEquals(original.getReplyToGroupId(), copy.getReplyToGroupId());
	//assertEquals(original.getSubject(), copy.getSubject());
	//assertEquals(original.getTo(), copy.getTo());
	//assertEquals(original.getUserId(), copy.getUserId());


	//Attach attach = new Attach();
	//
	//attach.setName("test");
	//attach.setHandle(UnsignedInteger.ONE);
	//attach.setRole(Role.RECEIVER);
	//attach.setSndSettleMode(SenderSettleMode.MIXED);
	//attach.setRcvSettleMode(ReceiverSettleMode.SECOND);
	//attach.setSource(null);
	//attach.setTarget(new hunt.proton.amqp.messaging.Target.Target());
	//attach.setUnsettled(null);
	//attach.setIncompleteUnsettled(false);
	//attach.setInitialDeliveryCount(UnsignedInteger.valueOf(42));
	//attach.setMaxMessageSize(UnsignedLong.valueOf(1024));
	//attach.setOfferedCapabilities([ Symbol.valueOf("anonymous-relay") ]);
	//attach.setDesiredCapabilities(new Symbol[0]);
	//
	//Attach copyOf = attach.copy();
	//
	//assertEquals(attach.getName(), copyOf.getName());
	//assertArrayEquals(attach.getDesiredCapabilities(), copyOf.getDesiredCapabilities());
	//assertEquals(attach.getHandle(), copyOf.getHandle());
	//assertEquals(attach.getRole(), copyOf.getRole());
	//assertEquals(attach.getSndSettleMode(), copyOf.getSndSettleMode());
	//assertEquals(attach.getRcvSettleMode(), copyOf.getRcvSettleMode());
	//assertNull(copyOf.getSource());
	//assertNotNull(copyOf.getTarget());
	//assertEquals(attach.getUnsettled(), copyOf.getUnsettled());
	//assertEquals(attach.getIncompleteUnsettled(), copyOf.getIncompleteUnsettled());
	//assertEquals(attach.getMaxMessageSize(), copyOf.getMaxMessageSize());
	//assertEquals(attach.getInitialDeliveryCount(), copyOf.getInitialDeliveryCount());
	//assertArrayEquals(attach.getOfferedCapabilities(), copyOf.getOfferedCapabilities());


	    //Map!(Symbol, Object) properties = new HashMap!(Symbol,Object)();
        //properties.put(Symbol.valueOf("x-opt"), new String( "value"));
        //
        //Begin begin = new Begin();
        //begin.setRemoteChannel(UnsignedShort.valueOf(cast(short) 2));
        //begin.setNextOutgoingId(UnsignedInteger.valueOf(10));
        //begin.setIncomingWindow(UnsignedInteger.valueOf(11));
        //begin.setOutgoingWindow(UnsignedInteger.valueOf(12));
        //begin.setHandleMax(UnsignedInteger.valueOf(13));
        //begin.setDesiredCapabilities(new Symbol[0]);
        //begin.setOfferedCapabilities([Symbol.valueOf("anonymous-relay") ]);
        //begin.setProperties(properties);
        //
		//Begin copyOf = begin.copy();
        //
        //
        //String t = cast(String) (copyOf.getProperties().get(Symbol.valueOf("x-opt")));
        //if (t is null)
        //{
        //    writefln("2222");
        //}
        //
        //writefln(cast(string)t.getBytes());
        //
        //assertEquals(begin.getRemoteChannel(), copyOf.getRemoteChannel());
        //assertEquals(begin.getNextOutgoingId(), copyOf.getNextOutgoingId());
        //assertEquals(begin.getIncomingWindow(), copyOf.getIncomingWindow());
        //assertEquals(begin.getOutgoingWindow(), copyOf.getOutgoingWindow());
        //assertEquals(begin.getHandleMax(), copyOf.getHandleMax());
        //assertArrayEquals(begin.getDesiredCapabilities(), copyOf.getDesiredCapabilities());
        //assertArrayEquals(begin.getOfferedCapabilities(), copyOf.getOfferedCapabilities());
        //assertEquals(begin.getProperties(), copyOf.getProperties());


        //Close close = new Close();
        //Close copyOf = close.copy();
        //
        //assertNull(copyOf.getError());
        //close.setError(new ErrorCondition());
        //copyOf = close.copy();
        //assertNotNull(copyOf.getError());


        //Detach detach = new Detach();
        //Detach copyOf = detach.copy();
        //
        //assertNull(copyOf.getError());
        //
        //detach.setError(new ErrorCondition());
        //detach.setClosed(true);
        //detach.setHandle(UnsignedInteger.ONE);
        //
        //copyOf = detach.copy();
        //
        //assertNotNull(copyOf.getError());
        //
        //assertEquals(detach.getClosed(), copyOf.getClosed());
        //assertEquals(detach.getHandle(), copyOf.getHandle());

        //End end = new End();
        //End copyOf = end.copy();
        //
        //assertNull(copyOf.getError());
        //end.setError(new ErrorCondition());
        //copyOf = end.copy();
        //assertNotNull(copyOf.getError());

        //ErrorCondition new1 = new ErrorCondition();
        //ErrorCondition new2 = new ErrorCondition();
        //assertErrorConditionsEqual(new1, new2);

        //ErrorCondition error = new ErrorCondition();
        //assertErrorConditionsEqual(error, error);
        //
        //string symbolValue = "symbol";
        //
        //ErrorCondition same1 = new ErrorCondition();
        //same1.setCondition(Symbol.getSymbol(symbolValue));
        //
        //ErrorCondition same2 = new ErrorCondition();
        //same2.setCondition(Symbol.getSymbol(symbolValue));
        //
        //assertErrorConditionsEqual(same1, same2);
        //
        //ErrorCondition different = new ErrorCondition();
        //different.setCondition(Symbol.getSymbol("other"));
        //
        //assertErrorConditionsNotEqual(same1, different);


        //string symbolValue = "symbol";
        //string descriptionValue = "description";
        //
        //ErrorCondition same1 = new ErrorCondition();
        //same1.setCondition(Symbol.getSymbol(symbolValue));
        //same1.setDescription(new String(descriptionValue));
        //
        //ErrorCondition same2 = new ErrorCondition();
        //same2.setCondition(Symbol.getSymbol(symbolValue));
        //same2.setDescription(new String(descriptionValue));
        //
        //assertErrorConditionsEqual(same1, same2);
        //
        //ErrorCondition different = new ErrorCondition();
        //different.setCondition(Symbol.getSymbol(symbolValue));
        //different.setDescription(new String("other"));
        //
        //assertErrorConditionsNotEqual(same1, different);


       // string symbolValue = "symbol";
       // string descriptionValue = "description";
       //
       // ErrorCondition same1 = new ErrorCondition();
       // same1.setCondition(Symbol.getSymbol(symbolValue));
       // same1.setDescription(new String(descriptionValue));
       // Map!(Symbol,Object) ins1 = new LinkedHashMap!(Symbol,Object)();
       // ins1.put(Symbol.getSymbol("key"), new String("value"));
       // same1.setInfo(ins1);
       //
       // ErrorCondition same2 = new ErrorCondition();
       // same2.setCondition(Symbol.getSymbol(symbolValue));
       // same2.setDescription(new String(descriptionValue));
       //
       // same2.setInfo(ins1);
       //
       // assertErrorConditionsEqual(same1, same2);
       //
       // ErrorCondition different = new ErrorCondition();
       // different.setCondition(Symbol.getSymbol(symbolValue));
       // different.setDescription(new String(descriptionValue));
       //// different.setInfo(Collections.singletonMap(Symbol.getSymbol("other"), "value"));
       // Map!(Symbol,Object) ins2 = new LinkedHashMap!(Symbol,Object)();
       // ins2.put(Symbol.getSymbol("other"), new String("value"));
       // different.setInfo(ins2);
       //
       // assertErrorConditionsNotEqual(same1, different);


        //Flow flow = new Flow();
        //
        //flow.setNextIncomingId(UnsignedInteger.valueOf(1));
        //flow.setIncomingWindow(UnsignedInteger.valueOf(2));
        //flow.setNextOutgoingId(UnsignedInteger.valueOf(3));
        //flow.setOutgoingWindow(UnsignedInteger.valueOf(4));
        //flow.setHandle(UnsignedInteger.valueOf(5));
        //flow.setDeliveryCount(UnsignedInteger.valueOf(6));
        //flow.setLinkCredit(UnsignedInteger.valueOf(7));
        //flow.setAvailable(UnsignedInteger.valueOf(8));
        //flow.setDrain(true);
        //flow.setEcho(true);
        //flow.setProperties(new HashMap!(Symbol,String));
        //
        //Flow copyOf = flow.copy();
        //
        //assertEquals(flow.getNextIncomingId(), copyOf.getNextIncomingId());
        //assertEquals(flow.getIncomingWindow(), copyOf.getIncomingWindow());
        //assertEquals(flow.getNextOutgoingId(), copyOf.getNextOutgoingId());
        //assertEquals(flow.getOutgoingWindow(), copyOf.getOutgoingWindow());
        //assertEquals(flow.getHandle(), copyOf.getHandle());
        //assertEquals(flow.getDeliveryCount(), copyOf.getDeliveryCount());
        //assertEquals(flow.getLinkCredit(), copyOf.getLinkCredit());
        //assertEquals(flow.getAvailable(), copyOf.getAvailable());
        //assertEquals(flow.getDrain(), copyOf.getDrain());
        //assertEquals(flow.getEcho(), copyOf.getEcho());
        //assertEquals(flow.getProperties(), copyOf.getProperties());


        //Map!(Symbol, Object) properties = new HashMap!(Symbol, Object)();
        //properties.put(Symbol.valueOf("x-opt"), new String("value"));
        //
        //Open open = new Open();
        //
        //open.setContainerId("test");
        //open.setHostname("host");
        //open.setMaxFrameSize(UnsignedInteger.valueOf(42));
        //open.setChannelMax(UnsignedShort.MAX_VALUE);
        //open.setIdleTimeOut(UnsignedInteger.valueOf(111));
        //open.setOfferedCapabilities([Symbol.valueOf("anonymous-relay")]);
        //open.setDesiredCapabilities(new Symbol[0]);
        //open.setProperties(properties);
        //
        //Open copyOf = open.copy();
        //
        //assertEquals(open.getContainerId(), copyOf.getContainerId());
        //assertEquals(open.getHostname(), copyOf.getHostname());
        //assertEquals(open.getMaxFrameSize(), copyOf.getMaxFrameSize());
        //assertEquals(open.getChannelMax(), copyOf.getChannelMax());
        //assertEquals(UnsignedInteger.valueOf(111), copyOf.getIdleTimeOut());
        //assertArrayEquals(open.getDesiredCapabilities(), copyOf.getDesiredCapabilities());
        //assertArrayEquals(open.getOfferedCapabilities(), copyOf.getOfferedCapabilities());
        //assertEquals(open.getProperties(), copyOf.getProperties());


        //ReceiverSettleMode first = ReceiverSettleMode.FIRST;
        //ReceiverSettleMode second = ReceiverSettleMode.SECOND;
        //
        //assertEquals(first, ReceiverSettleMode.valueOf(UnsignedByte.valueOf(cast(byte)0)));
        //assertEquals(second, ReceiverSettleMode.valueOf(UnsignedByte.valueOf(cast(byte)1)));
        //
        //assertEquals(first.getValue(), UnsignedByte.valueOf(cast(byte)0));
        //assertEquals(second.getValue(), UnsignedByte.valueOf(cast(byte)1));


       //  ReceiverSettleMode first = ReceiverSettleMode.FIRST;
       // ReceiverSettleMode second = ReceiverSettleMode.SECOND;
       //
       // Assert.assertNotEquals(first, ReceiverSettleMode.valueOf(UnsignedByte.valueOf(cast(byte)1)));
       //Assert.assertNotEquals(second, ReceiverSettleMode.valueOf(UnsignedByte.valueOf(cast(byte)0)));
       //
       //  Assert.assertNotEquals(first.getValue(), UnsignedByte.valueOf(cast(byte)1));
       //  Assert.assertNotEquals(second.getValue(), UnsignedByte.valueOf(cast(byte)0));

     //SenderSettleMode unsettled = SenderSettleMode.UNSETTLED;
     //   SenderSettleMode settled = SenderSettleMode.SETTLED;
     //   SenderSettleMode mixed = SenderSettleMode.MIXED;
     //
     //   assertEquals(unsettled, SenderSettleMode.valueOf(UnsignedByte.valueOf(cast(byte)0)));
     //   assertEquals(settled, SenderSettleMode.valueOf(UnsignedByte.valueOf(cast(byte)1)));
     //   assertEquals(mixed, SenderSettleMode.valueOf(UnsignedByte.valueOf(cast(byte)2)));
     //
     //   assertEquals(unsettled.getValue(), UnsignedByte.valueOf(cast(byte)0));
     //   assertEquals(settled.getValue(), UnsignedByte.valueOf(cast(byte)1));
     //   assertEquals(mixed.getValue(), UnsignedByte.valueOf(cast(byte)2));


      //SenderSettleMode unsettled = SenderSettleMode.UNSETTLED;
      //  SenderSettleMode settled = SenderSettleMode.SETTLED;
      //  SenderSettleMode mixed = SenderSettleMode.MIXED;
      //
      //Assert.assertNotEquals(unsettled, SenderSettleMode.valueOf(UnsignedByte.valueOf(cast(byte)2)));
      //Assert.assertNotEquals(settled, SenderSettleMode.valueOf(UnsignedByte.valueOf(cast(byte)0)));
      //Assert.assertNotEquals(mixed, SenderSettleMode.valueOf(UnsignedByte.valueOf(cast(byte)1)));
      //
      //Assert.assertNotEquals(unsettled.getValue(), UnsignedByte.valueOf(cast(byte)2));
      //Assert.assertNotEquals(settled.getValue(), UnsignedByte.valueOf(cast(byte)0));
      //Assert.assertNotEquals(mixed.getValue(), UnsignedByte.valueOf(cast(byte)1));


     //Transfer transfer = new Transfer();
     //   transfer.setHandle(UnsignedInteger.ONE);
     //   transfer.setDeliveryTag(new Binary([0,1]));
     //   transfer.setMessageFormat(UnsignedInteger.ZERO);
     //   transfer.setDeliveryId(UnsignedInteger.valueOf(127));
     //   transfer.setAborted(false);
     //   transfer.setBatchable(true);
     //   transfer.setRcvSettleMode(ReceiverSettleMode.SECOND);
     //
     //  Transfer copyOf = transfer.copy();
     //
     //   assertEquals(transfer.getHandle(), copyOf.getHandle());
     //   assertEquals(transfer.getMessageFormat(), copyOf.getMessageFormat());
     //   assertEquals(transfer.getDeliveryTag(), copyOf.getDeliveryTag());
     //   assertEquals(transfer.getDeliveryId(), copyOf.getDeliveryId());
     //   assertEquals(transfer.getAborted(), copyOf.getAborted());
     //   assertEquals(transfer.getBatchable(), copyOf.getBatchable());
     //   assertEquals(transfer.getRcvSettleMode(), copyOf.getRcvSettleMode());

    //Binary bin = createSteppedValueBinary(10);
    //assertFalse("Objects should not be equal with different type", bin == new String("not-a-Binary"));

    //int length = 10;
    //Binary bin1 = createSteppedValueBinary(length);
    //Binary bin2 = createSteppedValueBinary(length);
    //
    //assertTrue("Objects should be equal", bin1 ==bin2);
    //assertTrue("Objects should be equal", bin2 == bin1);

    //int length1 = 10;
    //Binary bin1 = createSteppedValueBinary(length1);
    //Binary bin2 = createSteppedValueBinary(length1 + 1);
    //
    //assertFalse("Objects should not be equal", bin1 == bin2);
    //assertFalse("Objects should not be equal", bin2 == bin1);

     //Binary bin1 = createNewRepeatedValueBinary(10, cast(byte) 1);
     //   Binary bin2 = createNewRepeatedValueBinary(123, cast(byte) 1);
     //   assertFalse("Objects should not be equal", bin1 == bin2);
     //   assertFalse("Objects should not be equal", bin2 == bin1);

     //int length = 10;
     //   Binary bin1 = createNewRepeatedValueBinary(length, cast(byte) 1);
     //
     //   Binary bin2 = createNewRepeatedValueBinary(length, cast(byte) 1);
     //   bin2.getArray()[5] = cast(byte) 0;
     //
     //   assertFalse("Objects should not be equal", bin1 ==(bin2));
     //   assertFalse("Objects should not be equal", bin2 ==(bin1));

    //UnsignedLong.valueOf("-1");
    //fail("Expected exception was not thrown");

    //UnsignedLong.valueOf(BigInteger.valueOf(-1L));
    //fail("Expected exception was not thrown");

    //UnsignedLong min = UnsignedLong.valueOf("0");
    //assertEquals("unexpected value", 0, min.longValue());

    //check 2^64 -1 (max) to confirm success
    //BigInteger onLimit = new BigInteger(TWO_TO_64_MINUS_ONE_BYTES);
    //string onlimitString = onLimit.toString();
    //UnsignedLong max =  UnsignedLong.valueOf(onlimitString);
    //assertEquals("unexpected value", onLimit, max.bigIntegerValue());
    //UnsignedLong min = UnsignedLong.valueOf(BigInteger.ZERO);
    //assertEquals("unexpected value", 0, min.longValue());
    //
    ////check 2^64 -1 (max) to confirm success
    //BigInteger onLimit = new BigInteger(TWO_TO_64_MINUS_ONE_BYTES);
    //UnsignedLong max =  UnsignedLong.valueOf(onLimit);
    //assertEquals("unexpected value", onLimit, max.bigIntegerValue());
    //
    ////check Long.MAX_VALUE to confirm success
    //UnsignedLong longMax =  UnsignedLong.valueOf(BigInteger.valueOf(Long.MAX_VALUE));
    //assertEquals("unexpected value", Long.MAX_VALUE, longMax.longValue());


    //BigInteger aboveLimit = new BigInteger(TWO_TO_64_PLUS_ONE_BYTES);
    //try
    //{
    //    UnsignedLong.valueOf(aboveLimit.toString());
    //    fail("Expected exception was not thrown");
    //}
    //catch(NumberFormatException nfe)
    //{
    //    //expected
    //}

    //2^64 (value 1 over max)
    //aboveLimit = aboveLimit.subtract(BigInteger.ONE);
    //try
    //{
    //    UnsignedLong.valueOf(aboveLimit.toString());
    //    fail("Expected exception was not thrown");
    //}
    //catch(NumberFormatException nfe)
    //{
    //    //expected
    //}

    //BigInteger aboveLimit = new BigInteger(TWO_TO_64_PLUS_ONE_BYTES);
    //try
    //{
    //    UnsignedLong.valueOf(aboveLimit);
    //    fail("Expected exception was not thrown");
    //}
    //catch(NumberFormatException nfe)
    //{
    //    //expected
    //}
    //
    ////2^64 (value 1 over max)
    //aboveLimit = aboveLimit.subtract(BigInteger.ONE);
    //try
    //{
    //    UnsignedLong.valueOf(aboveLimit);
    //    fail("Expected exception was not thrown");
    //}
    //catch(NumberFormatException nfe)
    //{
    //    //expected
    //}

       //Symbol symbol1 = Symbol.valueOf("testRoundtripSymbolArray1");
       // Symbol symbol2 = Symbol.valueOf("testRoundtripSymbolArray2");
       //
       // Data data1 = new DataImpl();
       // data1.putArray(false, Data.DataType.SYMBOL);
       // data1.enter();
       // data1.putSymbol(symbol1);
       // data1.putSymbol(symbol2);
       // data1.exit();
       //
       // Binary encoded = data1.encode();
       // encoded.asByteBuffer();
       //
       // Data data2 = new DataImpl();
       // data2.decode(encoded.asByteBuffer());
       //
       // assertEquals("unexpected array length", 2, data2.getArray());
       // assertEquals("unexpected array length", Data.DataType.SYMBOL, data2.getArrayType());
       //
       // List!Object array = data2.getJavaArray();
       // //assertNotNull("Array should not be null", array);
       // //assertEquals("Expected a Symbol array", Symbol[].class, array.getClass());
       // assertEquals("unexpected array length", 2, array.size());
       // assertEquals("unexpected value", symbol1, array.get(0));
       // assertEquals("unexpected value", symbol2, array.get(1));

     //Data data = new DataImpl();
     //   data.putArray(false, Data.DataType.LIST);
     //   data.enter();
     //   data.putList();
     //   data.putList();
     //   data.exit();
     //
     //   int expectedEncodedSize = 4; // 1b type + 1b size + 1b length + 1b element constructor
     //
     //
     //   Binary encoded = data.encode();
     //   assertEquals("unexpected encoding size", expectedEncodedSize, encoded.getLength());
     //
     //   ByteBuffer expectedEncoding = BufferUtils.allocate(expectedEncodedSize);
     //   expectedEncoding.put(cast(byte)0xe0);   // constructor
     //   expectedEncoding.put(cast(byte)2);   // size
     //   expectedEncoding.put(cast(byte)2);   // count
     //   expectedEncoding.put(cast(byte)0x45);   // element constructor
     //
     //   assertEquals("unexpected encoding", new Binary(expectedEncoding.array()), encoded);
     //
     //   data = new DataImpl();
     //   data.putArray(false, Data.DataType.LIST);
     //   data.enter();
     //   data.putList();
     //   data.putList();
     //   data.putList();
     //   data.enter();
     //   data.putNull();
     //   data.exit();
     //   data.exit();
     //
     //   expectedEncodedSize = 11; // 1b type + 1b size + 1b length + 1b element constructor + 3 * (1b size + 1b count) + 1b null elt
     //
     //   encoded = data.encode();
     //   assertEquals("unexpected encoding size", expectedEncodedSize, encoded.getLength());
     //
     //   expectedEncoding = ByteBuffer.allocate(expectedEncodedSize);
     //   expectedEncoding.put(cast(byte)0xe0);   // constructor
     //   expectedEncoding.put(cast(byte)9);   // size
     //   expectedEncoding.put(cast(byte)3);   // count
     //   expectedEncoding.put(cast(byte)0xc0);   // element constructor
     //   expectedEncoding.put(cast(byte)1);   // size
     //   expectedEncoding.put(cast(byte)0);   // count
     //   expectedEncoding.put(cast(byte)1);   // size
     //   expectedEncoding.put(cast(byte)0);   // count
     //   expectedEncoding.put(cast(byte)2);   // size
     //   expectedEncoding.put(cast(byte)1);   // count
     //   expectedEncoding.put(cast(byte)0x40);   // null value
     //
     //   assertEquals("unexpected encoding", new Binary(expectedEncoding.array()), encoded);
     //
     //   data = new DataImpl();
     //   data.putArray(false, Data.DataType.LIST);
     //   data.enter();
     //   data.putList();
     //   data.putList();
     //   data.putList();
     //   data.enter();
     //   for(int i = 0; i < 256; i++)
     //   {
     //       data.putNull();
     //   }
     //   data.exit();
     //   data.exit();
     //
     //   expectedEncodedSize = 290; // 1b type + 4b size + 4b length + 1b element constructor + 3 * (4b size + 4b count) + (256 * 1b) null elt
     //   encoded = data.encode();
     //   assertEquals("unexpected encoding size", expectedEncodedSize, encoded.getLength());
     //
     //   expectedEncoding = ByteBuffer.allocate(expectedEncodedSize);
     //   expectedEncoding.put(cast(byte)0xf0);   // constructor
     //   expectedEncoding.putInt(285);   // size
     //   expectedEncoding.putInt(3);   // count
     //   expectedEncoding.put(cast(byte)0xd0);   // element constructor
     //   expectedEncoding.putInt(4);   // size
     //   expectedEncoding.putInt(0);   // count
     //   expectedEncoding.putInt(4);   // size
     //   expectedEncoding.putInt(0);   // count
     //   expectedEncoding.putInt(260);   // size
     //   expectedEncoding.putInt(256);   // count
     //   for(int i = 0; i < 256; i++)
     //   {
     //       expectedEncoding.put(cast(byte)0x40);   // null value
     //   }
     //
     //   assertEquals("unexpected encoding", new Binary(expectedEncoding.array()), encoded);



      //byte[] strPayload = createStringPayloadBytes(256);
      //  String content = new String(cast(string)strPayload);
      //  assertTrue("Length must be over 255 to ensure use of str32 encoding", cast(int)content.length > 255);
      //
      //  int encodedSize = 1 + 4 + cast(int)strPayload.length; // 1b type + 4b length + content
      //  ByteBuffer expectedEncoding = BufferUtils.allocate(encodedSize);
      //  expectedEncoding.put(cast(byte) 0xB1);
      //  expectedEncoding.putInt(cast(int)strPayload.length);
      //  expectedEncoding.put(strPayload);
      //
      //  Data data = new DataImpl();
      //
      //  data.putString(cast(string)strPayload);
      //
      //  Binary encoded = data.encode();
      //
      //  assertEquals("unexpected encoding", new Binary(expectedEncoding.array()), encoded);



    //byte[] payload = createStringPayloadBytes(1025);
    //String content = new String(cast(string)payload);
    ////assertTrue("Length must be over 255 to ensure use of str32 encoding", cast(int)content.length() > 255);
    //
    //doEncodeDecodeStringTestImpl("s岁的雕塑大赛的");


    //byte[] payload = createStringPayloadBytes(1372);
    //    //assertTrue("Length must be over 255 to ensure use of vbin32 encoding", payload.length > 255);
    //
    //    int encodedSize = 1 + 4 + cast(int)payload.length; // 1b type + 4b length + content
    //    ByteBuffer expectedEncoding = BufferUtils.allocate(encodedSize);
    //    expectedEncoding.put(cast(byte) 0xB0);
    //    expectedEncoding.putInt(cast(int)payload.length);
    //    expectedEncoding.put(payload);
    //
    //    Data data = new DataImpl();
    //    data.putBinary(new Binary(payload));
    //
    //    Binary encoded = data.encode();
    //
    //    assertEquals("unexpected encoding", new Binary(expectedEncoding.array()), encoded);


    //byte[] initialPayload = createStringPayloadBytes(1025);
    //String initialContent = new String(cast(string)initialPayload);
    ////assertTrue("Length must be over 255 to ensure use of str32 encoding", initialContent.length() > 255);
    //
    //byte[] bytesReadBack = doEncodeDecodeBinaryTestImpl(initialPayload);
    //String readBackContent = new String(cast(string)bytesReadBack);
    //assertEquals(initialContent, readBackContent);




//}
