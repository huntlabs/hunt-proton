module transport.AttachTest;

import std.stdio;
import hunt.proton.amqp.transport.Attach;
import hunt.Assert ;
import hunt.io.BufferUtils;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.codec.UnsignedIntegerType;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.amqp.transport.Role;
import hunt.proton.amqp.transport.SenderSettleMode;
import hunt.proton.amqp.transport.ReceiverSettleMode;
import hunt.proton.amqp.transport.Target;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.Symbol;
import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.String;
import hunt.Boolean;
class AttachTest {

    this() {
    }

     public void testCopy() {
        Attach attach = new Attach();

        attach.setName(new String("test"));
        attach.setHandle(UnsignedInteger.ONE);
        attach.setRole(Role.RECEIVER);
        attach.setSndSettleMode(SenderSettleMode.MIXED);
        attach.setRcvSettleMode(ReceiverSettleMode.SECOND);
        attach.setSource(null);
        attach.setTarget(new hunt.proton.amqp.messaging.Target.Target());
        attach.setUnsettled(null);
        attach.setIncompleteUnsettled(Boolean.FALSE());
        attach.setInitialDeliveryCount(UnsignedInteger.valueOf(42));
        attach.setMaxMessageSize(UnsignedLong.valueOf(1024));

        List!Symbol lst =  new ArrayList!Symbol();
        lst.add(Symbol.valueOf("anonymous-relay") );
        attach.setOfferedCapabilities(lst);

        attach.setDesiredCapabilities(null);

        Attach copyOf = cast(Attach)attach.copy();

        assertEquals(attach.getName(), copyOf.getName());
        assertEquals(attach.getDesiredCapabilities(), copyOf.getDesiredCapabilities());
        assertEquals(attach.getHandle(), copyOf.getHandle());
        assertEquals(attach.getRole(), copyOf.getRole());
        assertEquals(attach.getSndSettleMode(), copyOf.getSndSettleMode());
        assertEquals(attach.getRcvSettleMode(), copyOf.getRcvSettleMode());
        assertNull(copyOf.getSource());
        assertNotNull(copyOf.getTarget());
        assertEquals(attach.getUnsettled(), copyOf.getUnsettled());
        assertEquals(attach.getIncompleteUnsettled(), copyOf.getIncompleteUnsettled());
        assertEquals(attach.getMaxMessageSize(), copyOf.getMaxMessageSize());
        assertEquals(attach.getInitialDeliveryCount(), copyOf.getInitialDeliveryCount());
        assertEquals(attach.getOfferedCapabilities(), copyOf.getOfferedCapabilities());
    }
}

//void main()
//{
//    AttachTest test = new AttachTest;
//    test.testCopy;
//}