/*
 * hunt-proton: AMQP Protocol library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net/
 *
 * Licensed under the Apache-2.0 License.
 *
 */


module hunt.proton.amqp.messaging.Properties;

import std.datetime.date;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.messaging.Section;
import hunt.String;
import hunt.time.LocalDateTime;


alias Date = LocalDateTime;

class Properties : Section
{
    private String _messageId;
    private Binary _userId;
    private String _to;
    private String _subject;
    private String _replyTo;
    private String _correlationId;
    private Symbol _contentType;
    private Symbol _contentEncoding;
    private Date _absoluteExpiryTime;
    private Date _creationTime;
    private String _groupId;
    private UnsignedInteger _groupSequence;
    private String _replyToGroupId;

    this()
    {
    }

    this(Properties other)
    {
        this._messageId = other._messageId;
        this._userId = other._userId;
        this._to = other._to;
        this._subject = other._subject;
        this._replyTo = other._replyTo;
        this._correlationId = other._correlationId;
        this._contentType = other._contentType;
        this._contentEncoding = other._contentEncoding;
        this._absoluteExpiryTime = other._absoluteExpiryTime;
        this._creationTime = other._creationTime;
        this._groupId = other._groupId;
        this._groupSequence = other._groupSequence;
        this._replyToGroupId = other._replyToGroupId;
    }

    public String getMessageId()
    {
        return _messageId;
    }

    public void setMessageId(String messageId)
    {
        _messageId = messageId;
    }

    public Binary getUserId()
    {
        return _userId;
    }

    public void setUserId(Binary userId)
    {
        _userId = userId;
    }

    public String getTo()
    {
        return _to;
    }

    public void setTo(String to)
    {
        _to = to;
    }

    public String getSubject()
    {
        return _subject;
    }

    public void setSubject(String subject)
    {
        _subject = subject;
    }

    public String getReplyTo()
    {
        return _replyTo;
    }

    public void setReplyTo(String replyTo)
    {
        _replyTo = replyTo;
    }

    public String getCorrelationId()
    {
        return _correlationId;
    }

    public void setCorrelationId(String correlationId)
    {
        _correlationId = correlationId;
    }

    public Symbol getContentType()
    {
        return _contentType;
    }

    public void setContentType(Symbol contentType)
    {
        _contentType = contentType;
    }

    public Symbol getContentEncoding()
    {
        return _contentEncoding;
    }

    public void setContentEncoding(Symbol contentEncoding)
    {
        _contentEncoding = contentEncoding;
    }

    public Date getAbsoluteExpiryTime()
    {
        return _absoluteExpiryTime;
    }

    public void setAbsoluteExpiryTime(Date absoluteExpiryTime)
    {
        _absoluteExpiryTime = absoluteExpiryTime;
    }

    public Date getCreationTime()
    {
        return _creationTime;
    }

    public void setCreationTime(Date creationTime)
    {
        _creationTime = creationTime;
    }

    public String getGroupId()
    {
        return _groupId;
    }

    public void setGroupId(String groupId)
    {
        _groupId = groupId;
    }

    public UnsignedInteger getGroupSequence()
    {
        return _groupSequence;
    }

    public void setGroupSequence(UnsignedInteger groupSequence)
    {
        _groupSequence = groupSequence;
    }

    public String getReplyToGroupId()
    {
        return _replyToGroupId;
    }

    public void setReplyToGroupId(String replyToGroupId)
    {
        _replyToGroupId = replyToGroupId;
    }


    override
    public SectionType getType() {
        return SectionType.Properties;
    }
}
