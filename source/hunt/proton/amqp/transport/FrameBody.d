module hunt.proton.amqp.transport.FrameBody;
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


import hunt.proton.amqp.Binary;
import hunt.proton.amqp.transport.Begin;
import hunt.proton.amqp.transport.Open;
import hunt.proton.amqp.transport.Attach;
import hunt.proton.amqp.transport.Flow;
import hunt.proton.amqp.transport.Transfer;
import hunt.proton.amqp.transport.Disposition;
import hunt.proton.amqp.transport.Detach;
import hunt.proton.amqp.transport.End;
import hunt.proton.amqp.transport.Close;

interface FrameBodyHandler(E) : FrameBody
{
    void handleOpen(Open open, Binary payload, E context);
    void handleBegin(Begin begin, Binary payload, E context);
    void handleAttach(Attach attach, Binary payload, E context);
    void handleFlow(Flow flow, Binary payload, E context);
    void handleTransfer(Transfer transfer, Binary payload, E context);
    void handleDisposition(Disposition disposition, Binary payload, E context);
    void handleDetach(Detach detach, Binary payload, E context);
    void handleEnd(End end, Binary payload, E context);
    void handleClose(Close close, Binary payload, E context);
    FrameBody copy();
    void invoke(FrameBodyHandler!E handler, Binary payload, E context);

}

interface FrameBody
{
    /**
     * @return a deep copy of this FrameBody.
     */


}
