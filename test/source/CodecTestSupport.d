module CodecTestSupport;

import std.stdio;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.AMQPDefinedTypes;
import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;


class CodecTestSupport {

    static int DEFAULT_MAX_BUFFER = 256 * 1024;

    public DecoderImpl decoder ;// = new DecoderImpl();
    public EncoderImpl encoder ;// = new EncoderImpl(decoder);

    ByteBuffer buffer;

    this()
    {
        decoder = new DecoderImpl();
        encoder = new EncoderImpl(decoder);
    }

    public void setUp() {
        AMQPDefinedTypes.registerAllTypes(decoder, encoder);

        buffer = BufferUtils.allocate(getMaxBufferSize());

        encoder.setByteBuffer(buffer);
        decoder.setByteBuffer(buffer);
    }

    public int getMaxBufferSize() {
        return DEFAULT_MAX_BUFFER;
    }

}

