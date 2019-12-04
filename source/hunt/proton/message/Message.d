module hunt.proton.message.Message;

import std.stdio;

import hunt.proton.amqp.messaging.ApplicationProperties;
import hunt.proton.amqp.messaging.DeliveryAnnotations;
import hunt.proton.amqp.messaging.Footer;
import hunt.proton.amqp.messaging.Header;
import hunt.proton.amqp.messaging.MessageAnnotations;
import hunt.proton.amqp.messaging.Properties;
import hunt.proton.amqp.messaging.Section;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.WritableBuffer;
import hunt.proton.message.impl.MessageImpl;
import hunt.proton.message.MessageError;
import hunt.String;

/**
 * Represents a Message within Proton.
 *
 * Create instances of Message using {@link Message.Factory}.
 *
 */
interface Message
{

    class Factory
    {
        public static Message create() {
            return new MessageImpl();
        }

        public static Message create(Header header,
                                     DeliveryAnnotations deliveryAnnotations,
                                     MessageAnnotations messageAnnotations,
                                     Properties properties,
                                     ApplicationProperties applicationProperties,
                                     Section body,
                                     Footer footer)
        {
            return new MessageImpl(header, deliveryAnnotations,
                                   messageAnnotations, properties,
                                   applicationProperties, body, footer);
        }
    }


    enum short DEFAULT_PRIORITY = 4;

    bool isDurable();

    long getDeliveryCount();

    short getPriority();

    bool isFirstAcquirer();

    long getTtl();

    void setDurable(bool durable);

    void setTtl(long ttl);

    void setDeliveryCount(long deliveryCount);

    void setFirstAcquirer(bool firstAcquirer);

    void setPriority(short priority);

    Object getMessageId();

    long getGroupSequence();

    String getReplyToGroupId();


    long getCreationTime();

    String getAddress();

    byte[] getUserId();

    String getReplyTo();

    String getGroupId();

    String getContentType();

    long getExpiryTime();

    Object getCorrelationId();

    String getContentEncoding();

    String getSubject();

    void setGroupSequence(long groupSequence);

    void setUserId(byte[] userId);

    void setCreationTime(long creationTime);

    void setSubject(String subject);

    void setGroupId(String groupId);

    void setAddress(String to);

    void setExpiryTime(long absoluteExpiryTime);

    void setReplyToGroupId(String replyToGroupId);

    void setContentEncoding(String contentEncoding);

    void setContentType(String contentType);

    void setReplyTo(String replyTo);

    void setCorrelationId(String correlationId);

    void setMessageId(String messageId);

    Header getHeader();

    DeliveryAnnotations getDeliveryAnnotations();

    MessageAnnotations getMessageAnnotations();

    Properties getProperties();

    ApplicationProperties getApplicationProperties();

    Section getBody();

    Footer getFooter();

    void setHeader(Header header);

    void setDeliveryAnnotations(DeliveryAnnotations deliveryAnnotations);

    void setMessageAnnotations(MessageAnnotations messageAnnotations);

    void setProperties(Properties properties);

    void setApplicationProperties(ApplicationProperties applicationProperties);

    void setBody(Section body);

    void setFooter(Footer footer);

    /**
     * TODO describe what happens if the data does not represent a complete message.
     * Currently this appears to leave the message in an unknown state.
     */
    int decode(byte[] data, int offset, int length);

    /**
     * Decodes the Message from the given {@link ReadableBuffer}.
     * <p>
     * If the buffer given does not contain the fully encoded Message bytes for decode
     * this method will throw an exception to indicate the buffer underflow condition and
     * the message object will be left in an undefined state.
     *
     * @param buffer
     *      A {@link ReadableBuffer} that contains the complete message bytes.
     */
    void decode(ReadableBuffer buffer);

    /**
     * Encodes up to {@code length} bytes of the message into the provided byte array,
     * starting at position {@code offset}.
     *
     * TODO describe what happens if length is smaller than the encoded form, Currently
     * Proton-J throws an exception. What does Proton-C do?
     *
     * @return the number of bytes written to the byte array
     */
    int encode(byte[] data, int offset, int length);

    /**
     * Encodes the current Message contents into the given {@link WritableBuffer} instance.
     * <p>
     * This method attempts to encode all message data into the {@link WritableBuffer} and
     * if the buffer has insufficient space it will throw an exception to indicate the buffer
     * overflow condition.  If successful the method returns the number of bytes written to
     * the provided buffer to fully encode the message.
     *
     * @param buffer
     *      The {@link WritableBuffer} instance to encode the message contents into.
     *
     * @return the number of bytes written to fully encode the message.
     */
    int encode(WritableBuffer buffer);

    void clear();

    MessageError getError();
}
