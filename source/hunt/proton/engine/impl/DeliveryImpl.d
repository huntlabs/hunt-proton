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

module hunt.proton.engine.impl.DeliveryImpl;


import hunt.proton.amqp.Binary;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.codec.CompositeReadableBuffer;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.WritableBuffer;
import hunt.proton.engine.Delivery;
import hunt.proton.engine.Record;
import hunt.proton.engine.Transport;
import hunt.proton.engine.impl.LinkImpl;
import hunt.proton.engine.impl.TransportDelivery;
import hunt.proton.engine.impl.SenderImpl;
import hunt.proton.engine.impl.ReceiverImpl;
import std.algorithm;
import hunt.proton.engine.impl.RecordImpl;
import std.concurrency : initOnce;



class DeliveryImpl : Delivery
{
    public static int DEFAULT_MESSAGE_FORMAT = 0;

   // private static ReadableBuffer EMPTY_BUFFER = ByteBufferReader.allocate(0);

    static ReadableBuffer EMPTY_BUFFER()
    {
        __gshared ReadableBuffer inst;
        return initOnce!inst(ByteBufferReader.allocate(0));
    }

    private DeliveryImpl _linkPrevious;
    private DeliveryImpl _linkNext;

    private DeliveryImpl _workNext;
    private DeliveryImpl _workPrev;
    bool _work;

    private DeliveryImpl _transportWorkNext;
    private DeliveryImpl _transportWorkPrev;
    bool _transportWork;

    private Record _attachments;
    private Object _context;

    private byte[] _tag;
    private LinkImpl _link;
    private DeliveryState _deliveryState;
    private bool _settled;
    private bool _remoteSettled;
    private DeliveryState _remoteDeliveryState;
    private DeliveryState _defaultDeliveryState = null;
    private int _messageFormat ; //= DEFAULT_MESSAGE_FORMAT;

    /**
     * A bit-mask representing the outstanding work on this delivery received from the transport layer
     * that has not yet been processed by the application.
     */
    private int _flags = cast(byte) 0;

    private TransportDelivery _transportDelivery;
    private bool _complete;
    private bool _updated;
    private bool _done;
    private bool _aborted;

    private CompositeReadableBuffer _dataBuffer;
    private ReadableBuffer _dataView;

    this(byte[] tag, LinkImpl link, DeliveryImpl previous)
    {
        _tag = tag;
        _link = link;
        _link.incrementUnsettled();
        _linkPrevious = previous;
        _messageFormat = DEFAULT_MESSAGE_FORMAT;
        if (previous !is null)
        {
            previous._linkNext = this;
        }
    }

    
    public byte[] getTag()
    {
        return _tag;
    }

    
    public LinkImpl getLink()
    {
        return _link;
    }

    
    public DeliveryState getLocalState()
    {
        return _deliveryState;
    }

    
    public DeliveryState getRemoteState()
    {
        return _remoteDeliveryState;
    }

    
    public bool remotelySettled()
    {
        return _remoteSettled;
    }

    
    public void setMessageFormat(int messageFormat)
    {
        _messageFormat = messageFormat;
    }

    
    public int getMessageFormat()
    {
        return _messageFormat;
    }

    
    public void disposition(DeliveryState state)
    {
        _deliveryState = state;
        if(!_remoteSettled && !_settled)
        {
            addToTransportWorkList();
        }
    }

    
    public void settle()
    {
        if (_settled) {
            return;
        }

        _settled = true;
        _link.decrementUnsettled();
        if(!_remoteSettled)
        {
            addToTransportWorkList();
        }
        else
        {
            _transportDelivery.settled();
        }

        if(_link.current() is this)
        {
            _link.advance();
        }

        _link.remove(this);
        if(_linkPrevious !is null)
        {
            _linkPrevious._linkNext = _linkNext;
        }

        if(_linkNext !is null)
        {
            _linkNext._linkPrevious = _linkPrevious;
        }

        updateWork();

        _linkNext= null;
        _linkPrevious = null;
    }

    DeliveryImpl getLinkNext()
    {
        return _linkNext;
    }

    
    public DeliveryImpl next()
    {
        return getLinkNext();
    }

    
    public void free()
    {
        settle();
    }

    DeliveryImpl getLinkPrevious()
    {
        return _linkPrevious;
    }

    
    public DeliveryImpl getWorkNext()
    {
        if (_workNext !is null)
            return _workNext;
        // the following hack is brought to you by the C implementation!
        if (!_work)  // not on the work list
            return (_link.getConnectionImpl()).getWorkHead();
        return null;
    }

    DeliveryImpl getWorkPrev()
    {
        return _workPrev;
    }

    void setWorkNext(DeliveryImpl workNext)
    {
        _workNext = workNext;
    }

    void setWorkPrev(DeliveryImpl workPrev)
    {
        _workPrev = workPrev;
    }

    int recv(byte[] bytes, int offset, int size)
    {
        int consumed;
        if (_dataBuffer !is null && _dataBuffer.hasRemaining())
        {
            consumed = min(size, _dataBuffer.remaining());

            _dataBuffer.get(bytes, offset, consumed);
            _dataBuffer.reclaimRead();
        }
        else
        {
            consumed = 0;
        }

        return (_complete && consumed == 0) ? Transport.END_OF_STREAM : consumed;  //TODO - Implement
    }

    int recv(WritableBuffer buffer)
    {
        int consumed;
        if (_dataBuffer !is null && _dataBuffer.hasRemaining())
        {
            consumed = min(buffer.remaining(), _dataBuffer.remaining());
            buffer.put(_dataBuffer);
            _dataBuffer.reclaimRead();
        }
        else
        {
            consumed = 0;
        }

        return (_complete && consumed == 0) ? Transport.END_OF_STREAM : consumed;
    }

    ReadableBuffer recv()
    {
        ReadableBuffer result = _dataView;
        if (_dataView !is null)
        {
            _dataView = _dataBuffer = null;
        }
        else
        {
            result = EMPTY_BUFFER;
        }

        return result;
    }

    void updateWork()
    {
        getLink().getConnectionImpl().workUpdate(this);
    }

    DeliveryImpl clearTransportWork()
    {
        DeliveryImpl next = _transportWorkNext;
        getLink().getConnectionImpl().removeTransportWork(this);
        return next;
    }

    void addToTransportWorkList()
    {
        getLink().getConnectionImpl().addTransportWork(this);
    }

    DeliveryImpl getTransportWorkNext()
    {
        return _transportWorkNext;
    }

    DeliveryImpl getTransportWorkPrev()
    {
        return _transportWorkPrev;
    }

    void setTransportWorkNext(DeliveryImpl transportWorkNext)
    {
        _transportWorkNext = transportWorkNext;
    }

    void setTransportWorkPrev(DeliveryImpl transportWorkPrev)
    {
        _transportWorkPrev = transportWorkPrev;
    }

    TransportDelivery getTransportDelivery()
    {
        return _transportDelivery;
    }

    void setTransportDelivery(TransportDelivery transportDelivery)
    {
        _transportDelivery = transportDelivery;
    }

    
    public bool isSettled()
    {
        return _settled;
    }

    int send(byte[] bytes, int offset, int length)
    {
        byte[] copy = new byte[length];
        //System.arraycopy(bytes, offset, copy, 0, length);
        copy[0 .. length] = bytes[offset .. offset+length];
        getOrCreateDataBuffer().append(copy);
        addToTransportWorkList();
        return length;
    }

    int send(ReadableBuffer buffer)
    {
        int length = buffer.remaining();
        getOrCreateDataBuffer().append(copyContents(buffer));
        addToTransportWorkList();
        return length;
    }

    int sendNoCopy(ReadableBuffer buffer)
    {
        int length = buffer.remaining();

        if (_dataView is null || !_dataView.hasRemaining())
        {
            _dataView = buffer;
        }
        else
        {
            consolidateSendBuffers(buffer);
        }

        addToTransportWorkList();
        return length;
    }

    private byte[] copyContents(ReadableBuffer buffer)
    {
        byte[] copy = new byte[buffer.remaining()];

        if (buffer.hasArray())
        {
           // System.arraycopy(buffer.array(), buffer.arrayOffset() + buffer.position(), copy, 0, buffer.remaining());
            copy[0 .. buffer.remaining()] = buffer.array()[buffer.arrayOffset() + buffer.position() ..  buffer.arrayOffset() + buffer.position()+buffer.remaining()];
            buffer.position(buffer.limit());
        }
        else
        {
            buffer.get(copy, 0, buffer.remaining());
        }

        return copy;
    }

    private void consolidateSendBuffers(ReadableBuffer buffer)
    {
        if (_dataView == _dataBuffer)
        {
            getOrCreateDataBuffer().append(copyContents(buffer));
        }
        else
        {
            ReadableBuffer oldView = _dataView;

            CompositeReadableBuffer dataBuffer = getOrCreateDataBuffer();
            dataBuffer.append(copyContents(oldView));
            dataBuffer.append(copyContents(buffer));

            oldView.reclaimRead();
        }

        buffer.reclaimRead();  // A pooled buffer could release now.
    }

    void append(Binary payload)
    {
        byte[] data = payload.getArray();

        // The Composite buffer cannot handle composites where the array
        // is a view of a larger array so we must copy the payload into
        // an array of the exact size
        if (payload.getArrayOffset() > 0 || payload.getLength() < data.length)
        {
            data = new byte[payload.getLength()];
           // System.arraycopy(payload.getArray(), payload.getArrayOffset(), data, 0, payload.getLength());
            data[0 .. payload.getLength()] = payload.getArray()[payload.getArrayOffset() .. payload.getArrayOffset()+payload.getLength()];
        }

        getOrCreateDataBuffer().append(data);
    }

    private CompositeReadableBuffer getOrCreateDataBuffer()
    {
        if (_dataBuffer is null)
        {
            _dataView = _dataBuffer = new CompositeReadableBuffer();
        }

        return _dataBuffer;
    }

    void append(byte[] data)
    {
        getOrCreateDataBuffer().append(data);
    }

    void afterSend()
    {
        if (_dataView !is null)
        {
            _dataView.reclaimRead();
            if (!_dataView.hasRemaining())
            {
                _dataView = _dataBuffer;
            }
        }
    }

    ReadableBuffer getData()
    {
        return _dataView is null ? EMPTY_BUFFER : _dataView;
    }

    int getDataLength()
    {
        return _dataView is null ? 0 : _dataView.remaining();
    }

    
    public int available()
    {
        return _dataView is null ? 0 : _dataView.remaining();
    }

    
    public bool isWritable()
    {
        return  cast(SenderImpl)getLink() !is null
                && getLink().current() is this
                && (cast(SenderImpl) getLink()).hasCredit();
    }

    
    public bool isReadable()
    {
        return   cast(ReceiverImpl)getLink() !is null
            && getLink().current() is this;
    }

    void setComplete()
    {
        _complete = true;
    }

    void setAborted()
    {
        _aborted = true;
    }

    
    public bool isAborted()
    {
        return _aborted;
    }

    
    public bool isPartial()
    {
        return !_complete;
    }

    void setRemoteDeliveryState(DeliveryState remoteDeliveryState)
    {
        _remoteDeliveryState = remoteDeliveryState;
        _updated = true;
    }

    
    public bool isUpdated()
    {
        return _updated;
    }

    
    public void clear()
    {
        _updated = false;
        getLink().getConnectionImpl().workUpdate(this);
    }

    void setDone()
    {
        _done = true;
    }

    bool isDone()
    {
        return _done;
    }

    void setRemoteSettled(bool remoteSettled)
    {
        _remoteSettled = remoteSettled;
        _updated = true;
    }

    
    public bool isBuffered()
    {
        if (_remoteSettled) return false;
        if ( cast(SenderImpl)getLink() !is null) {
            if (isDone()) {
                return false;
            } else {
                bool hasRemaining = false;
                if (_dataView !is null) {
                    hasRemaining = _dataView.hasRemaining();
                }

                return _complete || hasRemaining;
            }
        } else {
            return false;
        }
    }

    
    public Object getContext()
    {
        return _context;
    }

    
    public void setContext(Object context)
    {
        _context = context;
    }

    
    public Record attachments()
    {
        if(_attachments is null)
        {
            _attachments = new RecordImpl();
        }

        return _attachments;
    }

    //
    //public String toString()
    //{
    //    StringBuilder builder = new StringBuilder();
    //    builder.append("DeliveryImpl [_tag=").append(Arrays.toString(_tag))
    //        .append(", _link=").append(_link)
    //        .append(", _deliveryState=").append(_deliveryState)
    //        .append(", _settled=").append(_settled)
    //        .append(", _remoteSettled=").append(_remoteSettled)
    //        .append(", _remoteDeliveryState=").append(_remoteDeliveryState)
    //        .append(", _flags=").append(_flags)
    //        .append(", _defaultDeliveryState=").append(_defaultDeliveryState)
    //        .append(", _transportDelivery=").append(_transportDelivery)
    //        .append(", _data Size=").append(getDataLength())
    //        .append(", _complete=").append(_complete)
    //        .append(", _updated=").append(_updated)
    //        .append(", _done=").append(_done)
    //        .append("]");
    //    return builder.toString();
    //}

    
    public int pending()
    {
        return _dataView is null ? 0 : _dataView.remaining();
    }

    
    public void setDefaultDeliveryState(DeliveryState state)
    {
        _defaultDeliveryState = state;
    }

    
    public DeliveryState getDefaultDeliveryState()
    {
        return _defaultDeliveryState;
    }
}
