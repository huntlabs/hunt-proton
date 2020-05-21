module hunt.proton.message.impl.MessageImpl;

import std.stdio;

import hunt.io.ByteBuffer;
import hunt.time.LocalDateTime;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedByte;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.messaging.Header;
import hunt.proton.amqp.messaging.DeliveryAnnotations;
import hunt.proton.amqp.messaging.MessageAnnotations;
import hunt.proton.amqp.messaging.Properties;
import hunt.proton.amqp.messaging.ApplicationProperties;
import hunt.proton.amqp.messaging.Section;
import hunt.proton.amqp.messaging.Footer;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.message.Message;
import hunt.proton.message.ProtonJMessage;
import hunt.proton.message.MessageError;
import hunt.proton.codec.AMQPDefinedTypes;
import hunt.io.BufferUtils;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.DroppingWritableBuffer;
import hunt.proton.codec.WritableBuffer;
import hunt.proton.codec.CompositeWritableBuffer;

import hunt.String;
import hunt.logging;



class EncoderDecoderPair {
  DecoderImpl decoder;
  EncoderImpl encoder;
  this()
  {
      decoder = new DecoderImpl();
      encoder = new EncoderImpl(decoder);
      AMQPDefinedTypes.registerAllTypes(decoder, encoder);
  }
}

EncoderDecoderPair tlsCodec;


static this()
{
    tlsCodec = new EncoderDecoderPair();
}


class MessageImpl : ProtonJMessage
{
    private Header _header;
    private DeliveryAnnotations _deliveryAnnotations;
    private MessageAnnotations _messageAnnotations;
    private Properties _properties;
    private ApplicationProperties _applicationProperties;
    private Section _body;
    private Footer _footer;



    //private static  ThreadLocal<EncoderDecoderPair> tlsCodec = new ThreadLocal<EncoderDecoderPair>() {
    //       protected EncoderDecoderPair initialValue() {
    //        return new EncoderDecoderPair();
    //      }
    //  };

    /**
     * Application code should use {@link hunt.proton.message.Message.Factory#create()} instead.
     */
    this()
    {
    }

    /**
     * Application code should instead use
     * {@link hunt.proton.message.Message.Factory#create(Header, DeliveryAnnotations, MessageAnnotations, Properties, ApplicationProperties, Section, Footer)}
     */
    this(Header header, DeliveryAnnotations deliveryAnnotations, MessageAnnotations messageAnnotations,
                       Properties properties, ApplicationProperties applicationProperties, Section bd, Footer footer)
    {
        _header = header;
        _deliveryAnnotations = deliveryAnnotations;
        _messageAnnotations = messageAnnotations;
        _properties = properties;
        _applicationProperties = applicationProperties;
        _body = bd;
        _footer = footer;
    }

    public bool isDurable()
    {
        return (_header is null || _header.getDurable() is null) ? false : _header.getDurable().booleanValue;
    }


    public long getDeliveryCount()
    {
        return (_header is null || _header.getDeliveryCount() is null) ? 0 : _header.getDeliveryCount().longValue();
    }


    public short getPriority()
    {
        return (_header is null || _header.getPriority() is null)
        ? DEFAULT_PRIORITY
        : _header.getPriority().shortValue();
    }

    public bool isFirstAcquirer()
    {
        return (_header is null || _header.getFirstAcquirer() is null) ? false : _header.getFirstAcquirer().booleanValue;
    }

    public long getTtl()
    {
        return (_header is null || _header.getTtl() is null) ? 0 : _header.getTtl().longValue();
    }

    public void setDurable(bool durable)
    {
        if (_header is null)
        {
            if (durable)
            {
                _header = new Header();
            }
            else
            {
                return;
            }
        }
        _header.setDurable(durable);
    }

    public void setTtl(long ttl)
    {

        if (_header is null)
        {
            if (ttl != 0)
            {
                _header = new Header();
            }
            else
            {
                return;
            }
        }
        _header.setTtl(UnsignedInteger.valueOf(ttl));
    }

    public void setDeliveryCount(long deliveryCount)
    {
        if (_header is null)
        {
            if (deliveryCount == 0)
            {
                return;
            }
            _header = new Header();
        }
        _header.setDeliveryCount(UnsignedInteger.valueOf(deliveryCount));
    }


    public void setFirstAcquirer(bool firstAcquirer)
    {

        if (_header is null)
        {
            if (!firstAcquirer)
            {
                return;
            }
            _header = new Header();
        }
        _header.setFirstAcquirer(firstAcquirer);
    }

    public void setPriority(short priority)
    {

        if (_header is null)
        {
            if (priority == DEFAULT_PRIORITY)
            {
                return;
            }
            _header = new Header();
        }
        _header.setPriority(UnsignedByte.valueOf(cast(byte) priority));
    }

    public Object getMessageId()
    {
        return _properties is null ? null : _properties.getMessageId();
    }

    public long getGroupSequence()
    {
        return (_properties is null || _properties.getGroupSequence() is null) ? 0 : _properties.getGroupSequence().intValue();
    }

    public String getReplyToGroupId()
    {
        return _properties is null ? null : _properties.getReplyToGroupId();
    }

    public long getCreationTime()
    {
        return (_properties is null || _properties.getCreationTime() is null) ? 0 : _properties.getCreationTime().toEpochMilli();
    }

    public String getAddress()
    {
        return _properties is null ? null : _properties.getTo();
    }

    public byte[] getUserId()
    {
        if(_properties is null || _properties.getUserId() is null)
        {
            return null;
        }
        else
        {
             Binary userId = _properties.getUserId();
            byte[] id = new byte[userId.getLength()];
           // System.arraycopy(userId.getArray(),userId.getArrayOffset(),id,0,userId.getLength());
            id[0 .. userId.getLength()] = userId.getArray()[userId.getArrayOffset() .. userId.getArrayOffset() + userId.getLength()];
            return id;
        }

    }

    public String getReplyTo()
    {
        return _properties is null ? null : _properties.getReplyTo();
    }

    public String getGroupId()
    {
        return _properties is null ? null : _properties.getGroupId();
    }

    public String getContentType()
    {
        return (_properties is null || _properties.getContentType() is null) ? null : new String(_properties.getContentType().toString());
    }

    public long getExpiryTime()
    {
        return (_properties is null || _properties.getAbsoluteExpiryTime() is null) ? 0 : _properties.getAbsoluteExpiryTime().toEpochMilli();
    }

    public Object getCorrelationId()
    {
        return (_properties is null) ? null : _properties.getCorrelationId();
    }

    public String getContentEncoding()
    {
        return (_properties is null || _properties.getContentEncoding() is null) ? null : new String (_properties.getContentEncoding().toString());
    }

    public String getSubject()
    {
        return _properties is null ? null : _properties.getSubject();
    }

    public void setGroupSequence(long groupSequence)
    {
        if(_properties is null)
        {
            if(groupSequence == 0)
            {
                return;
            }
            else
            {
                _properties = new Properties();
            }
        }
        _properties.setGroupSequence(UnsignedInteger.valueOf(cast(int) groupSequence));
    }

    public void setUserId(byte[] userId)
    {
        if(userId is null)
        {
            if(_properties !is null)
            {
                _properties.setUserId(null);
            }

        }
        else
        {
            if(_properties is null)
            {
                _properties = new Properties();
            }
            byte[] id = new byte[userId.length];
          //  System.arraycopy(userId, 0, id,0, userId.length);
            id[0 .. userId.length] = userId[0 .. userId.length];
            _properties.setUserId(new Binary(id));
        }
    }

    
    public void setCreationTime(long creationTime)
    {
        if(_properties is null)
        {
            if(creationTime == 0)
            {
                return;
            }
            _properties = new Properties();

        }
        _properties.setCreationTime(Date.ofEpochMilli(creationTime));
    }

    
    public void setSubject(String subject)
    {
        if(_properties is null)
        {
            if(subject is null)
            {
                return;
            }
            _properties = new Properties();
        }
        _properties.setSubject(subject);
    }

    
    public void setGroupId(String groupId)
    {
        if(_properties is null)
        {
            if(groupId is null)
            {
                return;
            }
            _properties = new Properties();
        }
        _properties.setGroupId(groupId);
    }

    
    public void setAddress(String to)
    {
        if(_properties is null)
        {
            if(to is null)
            {
                return;
            }
            _properties = new Properties();
        }
        _properties.setTo(to);
    }

    
    public void setExpiryTime(long absoluteExpiryTime)
    {
        if(_properties is null)
        {
            if(absoluteExpiryTime == 0)
            {
                return;
            }
            _properties = new Properties();

        }
        _properties.setAbsoluteExpiryTime(Date.ofEpochMilli(absoluteExpiryTime));
    }

    
    public void setReplyToGroupId(String replyToGroupId)
    {
        if(_properties is null)
        {
            if(replyToGroupId is null)
            {
                return;
            }
            _properties = new Properties();
        }
        _properties.setReplyToGroupId(replyToGroupId);
    }

    
    public void setContentEncoding(String contentEncoding)
    {
        if(_properties is null)
        {
            if(contentEncoding is null)
            {
                return;
            }
            _properties = new Properties();
        }
        _properties.setContentEncoding(Symbol.valueOf(cast(string)(contentEncoding.getBytes())));
    }

    
    public void setContentType(String contentType)
    {
        if(_properties is null)
        {
            if(contentType is null)
            {
                return;
            }
            _properties = new Properties();
        }
        _properties.setContentType(Symbol.valueOf(cast(string)(contentType.getBytes())));
    }

    
    public void setReplyTo(String replyTo)
    {

        if(_properties is null)
        {
            if(replyTo is null)
            {
                return;
            }
            _properties = new Properties();
        }
        _properties.setReplyTo(replyTo);
    }

    
    public void setCorrelationId(String correlationId)
    {

        if(_properties is null)
        {
            if(correlationId is null)
            {
                return;
            }
            _properties = new Properties();
        }
        _properties.setCorrelationId(correlationId);
    }

    
    public void setMessageId(String messageId)
    {

        if(_properties is null)
        {
            if(messageId is null)
            {
                return;
            }
            _properties = new Properties();
        }
        _properties.setMessageId(messageId);
    }


    
    public Header getHeader()
    {
        return _header;
    }

    
    public DeliveryAnnotations getDeliveryAnnotations()
    {
        return _deliveryAnnotations;
    }

    
    public MessageAnnotations getMessageAnnotations()
    {
        return _messageAnnotations;
    }

    
    public Properties getProperties()
    {
        return _properties;
    }

    
    public ApplicationProperties getApplicationProperties()
    {
        return _applicationProperties;
    }

    
    public Section getBody()
    {
        return _body;
    }

    
    public Footer getFooter()
    {
        return _footer;
    }

    
    public void setHeader(Header header)
    {
        _header = header;
    }

    
    public void setDeliveryAnnotations(DeliveryAnnotations deliveryAnnotations)
    {
        _deliveryAnnotations = deliveryAnnotations;
    }

    
    public void setMessageAnnotations(MessageAnnotations messageAnnotations)
    {
        _messageAnnotations = messageAnnotations;
    }

    
    public void setProperties(Properties properties)
    {
        _properties = properties;
    }

    
    public void setApplicationProperties(ApplicationProperties applicationProperties)
    {
        _applicationProperties = applicationProperties;
    }

    
    public void setBody(Section body)
    {
        _body = body;
    }

    
    public void setFooter(Footer footer)
    {
        _footer = footer;
    }

    
    public int decode(byte[] data, int offset, int length)
    {
         ByteBuffer buffer = BufferUtils.toBuffer(data, offset, length);
        decode(buffer);

        return length-buffer.remaining();
    }

    public void decode(ByteBuffer buffer)
    {
        decode(ByteBufferReader.wrap(buffer));
    }

    public void decode(ReadableBuffer buffer)
    {
        DecoderImpl decoder = tlsCodec.decoder;
        decoder.setBuffer(buffer);

        _header = null;
        _deliveryAnnotations = null;
        _messageAnnotations = null;
        _properties = null;
        _applicationProperties = null;
        _body = null;
        _footer = null;
        Section section = null;

        if(buffer.hasRemaining())
        {
            section = cast(Section) decoder.readObject();
        }


        _header  = cast(Header)section;
        if(_header !is null)
        {
            //_header = (Header) section;
            if(buffer.hasRemaining())
            {
                section = cast(Section) decoder.readObject();
            }
            else
            {
                section = null;
            }

        }

        _deliveryAnnotations = cast(DeliveryAnnotations)section;
        if(_deliveryAnnotations !is null)
        {
            _deliveryAnnotations = cast(DeliveryAnnotations) section;

            if(buffer.hasRemaining())
            {
                section = cast(Section) decoder.readObject();
            }
            else
            {
                section = null;
            }

        }

        _messageAnnotations = cast(MessageAnnotations)section;
        if(_messageAnnotations !is null)
        {
            _messageAnnotations = cast(MessageAnnotations) section;

            if(buffer.hasRemaining())
            {
                section = cast(Section) decoder.readObject();
            }
            else
            {
                section = null;
            }

        }

        _properties = cast(Properties)section;
        if(_properties !is null)
        {
            _properties = cast(Properties) section;

            if(buffer.hasRemaining())
            {
                section = cast(Section) decoder.readObject();
            }
            else
            {
                section = null;
            }

        }

        _applicationProperties = cast(ApplicationProperties)section;
        if(_applicationProperties !is null)
        {
            _applicationProperties = cast(ApplicationProperties) section;

            if(buffer.hasRemaining())
            {
                section = cast(Section) decoder.readObject();
            }
            else
            {
                section = null;
            }

        }



        if(section !is null && (cast(Footer)section is null))
        {
            _body = section;

            if(buffer.hasRemaining())
            {
                section = cast(Section) decoder.readObject();
            }
            else
            {
                section = null;
            }

        }

        _footer = cast(Footer)section;
        if(_footer is null)
        {
            _footer = null;

        }

        decoder.setBuffer(null);
    }

    
    public int encode(byte[] data, int offset, int length)
    {
        ByteBuffer buffer = BufferUtils.toBuffer(data, offset, length);
        return encode(new ByteBufferWrapper(buffer));
    }

    
    public int encode2(byte[] data, int offset, int length)
    {
        ByteBuffer buffer = BufferUtils.toBuffer(data, offset, length);
        ByteBufferWrapper first = new ByteBufferWrapper(buffer);
        DroppingWritableBuffer second = new DroppingWritableBuffer();
        CompositeWritableBuffer composite = new CompositeWritableBuffer(first, second);
        int start = composite.position();
        encode(composite);
        return composite.position() - start;
    }

    
    public int encode(WritableBuffer buffer)
    {
        int length = buffer.remaining();
        EncoderImpl encoder = tlsCodec.encoder;
        encoder.setByteBuffer(buffer);

        if(getHeader() !is null)
        {
            encoder.writeObject(getHeader());
        }
        if(getDeliveryAnnotations() !is null)
        {
            encoder.writeObject(getDeliveryAnnotations());
        }
        if(getMessageAnnotations() !is null)
        {
            encoder.writeObject(getMessageAnnotations());
        }
        if(getProperties() !is null)
        {
            encoder.writeObject(getProperties());
        }
        if(getApplicationProperties() !is null)
        {
            encoder.writeObject(getApplicationProperties());
        }
        if(getBody() !is null)
        {
            encoder.writeObject(cast(Object)getBody());
        }
        if(getFooter() !is null)
        {
            encoder.writeObject(getFooter());
        }
        encoder.setByteBuffer(cast(WritableBuffer)null);

        return length - buffer.remaining();
    }

    
    public void clear()
    {
        _body = null;
    }

    
    public MessageError getError()
    {
        return MessageError.OK;
    }

    //public String toString()
    //{
    //    StringBuilder sb = new StringBuilder();
    //    sb.append("Message{");
    //    if (_header !is null) {
    //        sb.append("header=");
    //        sb.append(_header);
    //    }
    //    if (_properties !is null) {
    //        sb.append("properties=");
    //        sb.append(_properties);
    //    }
    //    if (_messageAnnotations !is null) {
    //        sb.append("message_annotations=");
    //        sb.append(_messageAnnotations);
    //    }
    //    if (_body !is null) {
    //        sb.append("body=");
    //        sb.append(_body);
    //    }
    //    sb.append("}");
    //    return sb.toString();
    //}

}

