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

module hunt.proton.framing.TransportFrame;

import hunt.proton.amqp.Binary;
import hunt.proton.amqp.transport.FrameBody;

public class TransportFrame
{
    private  int _channel;
    private  FrameBody _body;
    private  Binary _payload;

    this( int channel,FrameBody bd,Binary payload)
    {
        _payload = payload;
        _body = bd;
        _channel = channel;
    }

    public int getChannel()
    {
        return _channel;
    }

    public FrameBody getBody()
    {
        return _body;
    }

    public Binary getPayload()
    {
        return _payload;
    }

    //public String toString()
    //{
    //    StringBuilder builder = new StringBuilder();
    //    builder.append("TransportFrame{ _channel=").append(_channel).append(", _body=").append(_body).append("}");
    //    return builder.toString();
    //}

}
