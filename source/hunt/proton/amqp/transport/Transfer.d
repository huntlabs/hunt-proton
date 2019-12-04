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


module hunt.proton.amqp.transport.Transfer;

import hunt.logging;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.UnsignedInteger;
import hunt.proton.amqp.transport.FrameBody;
import hunt.proton.amqp.transport.ReceiverSettleMode;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.Boolean;

class Transfer : FrameBody
{
    private UnsignedInteger _handle;
    private UnsignedInteger _deliveryId;
    private Binary _deliveryTag;
    private UnsignedInteger _messageFormat;
    private Boolean _settled; //
    private Boolean _more;
    private ReceiverSettleMode _rcvSettleMode;
    private DeliveryState _state;
    private Boolean _resume;
    private Boolean _aborted;
    private Boolean _batchable;

    this() {
       // _settled = new Boolean(false);
        _more = new Boolean(false);
        _resume = new Boolean(false);
        _aborted = new Boolean(false);
        _batchable = new Boolean(false);
    }

    this(Transfer other)
    {
        this._handle = other.getHandle();
        this._deliveryId = other.getDeliveryId();
        this._deliveryTag = Binary.copy(other.getDeliveryTag());
        this._messageFormat = other.getMessageFormat();
        this._settled = other.getSettled();
        this._more = other.getMore();
        this._rcvSettleMode = other.getRcvSettleMode();
        this._state = other.getState();
        this._resume = other.getResume();
        this._aborted = other.getAborted();
        this._batchable = other.getBatchable();
    }

    public UnsignedInteger getHandle()
    {
        return _handle;
    }

    public void setHandle(UnsignedInteger handle)
    {
        if( handle is null )
        {
            logError("the handle field is mandatory");
        }

        _handle = handle;
    }

    public UnsignedInteger getDeliveryId()
    {
        return _deliveryId;
    }

    public void setDeliveryId(UnsignedInteger deliveryId)
    {
        _deliveryId = deliveryId;
    }

    public Binary getDeliveryTag()
    {
        return _deliveryTag;
    }

    public void setDeliveryTag(Binary deliveryTag)
    {
        _deliveryTag = deliveryTag;
    }

    public UnsignedInteger getMessageFormat()
    {
        return _messageFormat;
    }

    public void setMessageFormat(UnsignedInteger messageFormat)
    {
        _messageFormat = messageFormat;
    }

    public Boolean getSettled()
    {
        return _settled;
    }

    public void setSettled(Boolean settled)
    {
        _settled = settled;
    }

    public Boolean getMore()
    {
        return _more;
    }

    public void setMore(Boolean more)
    {
        _more = more;
    }

    public ReceiverSettleMode getRcvSettleMode()
    {
        return _rcvSettleMode;
    }

    public void setRcvSettleMode(ReceiverSettleMode rcvSettleMode)
    {
        _rcvSettleMode = rcvSettleMode;
    }

    public DeliveryState getState()
    {
        return _state;
    }

    public void setState(DeliveryState state)
    {
        _state = state;
    }

    public Boolean getResume()
    {
        return _resume;
    }

    public void setResume(Boolean resume)
    {
        _resume = resume;
    }

    public Boolean getAborted()
    {
        return _aborted;
    }

    public void setAborted(Boolean aborted)
    {
        _aborted = aborted;
    }

    public Boolean getBatchable()
    {
        return _batchable;
    }

    public void setBatchable(Boolean batchable)
    {
        _batchable = batchable;
    }

    //override
    public void invoke(E)(FrameBodyHandler!E handler, Binary payload, E context)
    {
        handler.handleTransfer(this, payload, context);
    }


    public FrameBody copy()
    {
        return new Transfer(this);
    }
}
