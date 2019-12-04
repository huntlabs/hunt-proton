module hunt.proton.message.ProtonJMessage;

import std.stdio;

import hunt.proton.codec.WritableBuffer;
import hunt.proton.message.Message;

interface ProtonJMessage : Message
{

    int encode2(byte[] data, int offset, int length);

    int encode(WritableBuffer buffer);

}
