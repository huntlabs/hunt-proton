module TransferTypeTest;

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
import hunt.proton.amqp.transport.Transfer;
import hunt.Boolean;
import  hunt.proton.amqp.transport.ReceiverSettleMode;

class TransferTypeTest  : CodecTestSupport{

    this() {
    }

     public void testEncodeDecodeTransfers() {
        Transfer transfer = new Transfer();
        transfer.setHandle(UnsignedInteger.ONE);
        transfer.setDeliveryTag(new Binary([0, 1]));
        transfer.setMessageFormat(UnsignedInteger.ZERO);
        transfer.setDeliveryId(UnsignedInteger.valueOf(127));
        transfer.setAborted(Boolean.FALSE());
        transfer.setBatchable(Boolean.TRUE());
        transfer.setRcvSettleMode(ReceiverSettleMode.SECOND);

        encoder.writeObject(transfer);
        buffer.clear();
        Transfer outputValue = cast(Transfer) decoder.readObject();

        assertEquals(transfer.getHandle(), outputValue.getHandle());
        assertEquals(transfer.getMessageFormat(), outputValue.getMessageFormat());
        assertEquals(transfer.getDeliveryTag(), outputValue.getDeliveryTag());
        assertEquals(transfer.getDeliveryId(), outputValue.getDeliveryId());
        assertEquals(transfer.getAborted(), outputValue.getAborted());
        assertEquals(transfer.getBatchable(), outputValue.getBatchable());
        assertEquals(transfer.getRcvSettleMode(), outputValue.getRcvSettleMode());
    }

      public void testSkipValue() {
        Transfer transfer = new Transfer();
        transfer.setHandle(UnsignedInteger.ONE);
        transfer.setDeliveryTag(new Binary([0, 1]));
        transfer.setMessageFormat(UnsignedInteger.ZERO);
        transfer.setDeliveryId(UnsignedInteger.valueOf(127));
        transfer.setAborted(Boolean.FALSE());
        transfer.setBatchable(Boolean.TRUE());
        transfer.setRcvSettleMode(ReceiverSettleMode.SECOND);

        encoder.writeObject(transfer);

        transfer.setHandle(UnsignedInteger.valueOf(2));

        encoder.writeObject(transfer);

        buffer.clear();

        ITypeConstructor type = decoder.readConstructor();
       // assertEquals(Transfer.class, type.getTypeClass());
        type.skipValue();

        Transfer result = cast(Transfer) decoder.readObject();
        assertEquals(UnsignedInteger.valueOf(2), result.getHandle());
    }

}


//void main()
//{
//    TransferTypeTest test = new TransferTypeTest;
//    test.setUp();
//   // test.testEncodeDecodeTransfers;
//    test.testSkipValue;
//}
