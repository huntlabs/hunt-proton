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

module hunt.proton.codec.EncodingCodes;

public interface EncodingCodes
{
    enum byte DESCRIBED_TYPE_INDICATOR = cast(byte) 0x00;

    enum byte NULL                     = cast(byte) 0x40;

    enum byte BOOLEAN                  = cast(byte) 0x56;
    enum byte BOOLEAN_TRUE             = cast(byte) 0x41;
    enum byte BOOLEAN_FALSE            = cast(byte) 0x42;

    enum byte UBYTE                    = cast(byte) 0x50;

    enum byte USHORT                   = cast(byte) 0x60;

    enum byte UINT                     = cast(byte) 0x70;
    enum byte SMALLUINT                = cast(byte) 0x52;
    enum byte UINT0                    = cast(byte) 0x43;

    enum byte ULONG                    = cast(byte) 0x80;
    enum byte SMALLULONG               = cast(byte) 0x53;
    enum byte ULONG0                   = cast(byte) 0x44;

    enum byte BYTE                     = cast(byte) 0x51;

    enum byte SHORT                    = cast(byte) 0x61;

    enum byte INT                      = cast(byte) 0x71;
    enum byte SMALLINT                 = cast(byte) 0x54;

    enum byte LONG                     = cast(byte) 0x81;
    enum byte SMALLLONG                = cast(byte) 0x55;

    enum byte FLOAT                    = cast(byte) 0x72;

    enum byte DOUBLE                   = cast(byte) 0x82;

    enum byte DECIMAL32                = cast(byte) 0x74;

    enum byte DECIMAL64                = cast(byte) 0x84;

    enum byte DECIMAL128               = cast(byte) 0x94;

    enum byte CHAR                     = cast(byte) 0x73;

    enum byte TIMESTAMP                = cast(byte) 0x83;

    enum byte UUID                     = cast(byte) 0x98;

    enum byte VBIN8                    = cast(byte) 0xa0;
    enum byte VBIN32                   = cast(byte) 0xb0;

    enum byte STR8                     = cast(byte) 0xa1;
    enum byte STR32                    = cast(byte) 0xb1;

    enum byte SYM8                     = cast(byte) 0xa3;
    enum byte SYM32                    = cast(byte) 0xb3;

    enum byte LIST0                    = cast(byte) 0x45;
    enum byte LIST8                    = cast(byte) 0xc0;
    enum byte LIST32                   = cast(byte) 0xd0;

    enum byte MAP8                     = cast(byte) 0xc1;
    enum byte MAP32                    = cast(byte) 0xd1;

    enum byte ARRAY8                   = cast(byte) 0xe0;
    enum byte ARRAY32                  = cast(byte) 0xf0;

}
