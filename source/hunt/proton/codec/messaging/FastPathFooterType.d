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
module hunt.proton.codec.messaging.FastPathFooterType;

import hunt.collection.Collection;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.messaging.Footer;
import hunt.proton.codec.AMQPType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.DecoderImpl;
import hunt.proton.codec.EncoderImpl;
import hunt.proton.codec.EncodingCodes;
import hunt.proton.codec.FastPathDescribedTypeConstructor;
import hunt.proton.codec.MapType;
import hunt.proton.codec.TypeEncoding;
import hunt.proton.codec.WritableBuffer;
import hunt.proton.codec.messaging.FooterType;
import std.concurrency : initOnce;
import hunt.Exceptions;
import hunt.collection.Map;
import hunt.String;

class FastPathFooterType : AMQPType!(Footer), FastPathDescribedTypeConstructor!(Footer) {

    private static byte DESCRIPTOR_CODE = 0x78;

    //private static Object[] DESCRIPTORS =
    //{
    //    UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:footer:map"),
    //};

    static Object[]  DESCRIPTORS() {
        __gshared Object[]  inst;
        return initOnce!inst([UnsignedLong.valueOf(DESCRIPTOR_CODE), Symbol.valueOf("amqp:footer:map")]);
    }

    private FooterType footerType;

    this(EncoderImpl encoder) {
        this.footerType = new FooterType(encoder);
    }

    public EncoderImpl getEncoder() {
        return footerType.getEncoder();
    }

    public DecoderImpl getDecoder() {
        return footerType.getDecoder();
    }

    public bool encodesJavaPrimitive() {
        return false;
    }

    public TypeInfo getTypeClass() {
        return typeid(Footer);
    }

    public ITypeEncoding getEncoding(Object val) {
        return footerType.getEncoding(cast(Footer)val);
    }

    override
    public TypeEncoding!(Footer) getCanonicalEncoding() {
        return footerType.getCanonicalEncoding();
    }

    override
    public  Collection!(TypeEncoding!(Footer)) getAllEncodings() {
        return footerType.getAllEncodings();
    }

    override
    public Footer readValue() {
        return new Footer(cast(Map!(String,Object))(getDecoder().readMap()));
       // implementationMissing(false);
    }

    public void skipValue() {
        //implementationMissing( false);
        getDecoder().readConstructor().skipValue();
    }

    override
    public void write(Object v) {
        Footer val = cast(Footer)v;
        WritableBuffer buffer = getEncoder().getBuffer();

        buffer.put(EncodingCodes.DESCRIBED_TYPE_INDICATOR);
        buffer.put(EncodingCodes.SMALLULONG);
        buffer.put(DESCRIPTOR_CODE);

        //implementationMissing(false);
        MapType mapType = cast(MapType) getEncoder().getType(cast(Object)(val.getValue()));

        mapType.write(cast(Object)(val.getValue()));
    }

    public static void register(Decoder decoder, EncoderImpl encoder) {
        FastPathFooterType type = new FastPathFooterType(encoder);
        //implementationMissing( false);
        foreach(Object descriptor ; DESCRIPTORS)
        {
            decoder.registerFastPath(descriptor, type);
        }
        encoder.register(type);
    }
}
