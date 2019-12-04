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

module hunt.proton.engine.impl.StringUtils;

import hunt.proton.amqp.Binary;
import std.format;
class StringUtils
{
    /**
     * Converts the Binary to a quoted string.
     *
     * @param bin the Binary to convert
     * @param stringLength the maximum length of stringified content (excluding the quotes, and truncated indicator)
     * @param appendIfTruncated appends "...(truncated)" if not all of the payload is present in the string
     * @return the converted string
     */
    public static string toQuotedString(Binary bin,int stringLength,bool appendIfTruncated)
    {
        if(bin is null)
        {
             return "\"\"";
        }

        byte[] binData = bin.getArray();
        int binLength = bin.getLength();
        int offset = bin.getArrayOffset();

        string str ;
        str ~= ("\"");

        int size = 0;
        bool truncated = false;
        for (int i = 0; i < binLength; i++)
        {
            byte c = binData[offset + i];

            if (c > 31 && c < 127 && c != '\\')
            {
                if (size + 1 <= stringLength)
                {
                    size += 1;
                    str ~= (cast(char) c);
                }
                else
                {
                    truncated = true;
                    break;
                }
            }
            else
            {
                if (size + 4 <= stringLength)
                {
                    size += 4;
                    str ~= (format("\\x%02x", c));
                }
                else
                {
                    truncated = true;
                    break;
                }
            }
        }

        str ~= ("\"");

        if (truncated && appendIfTruncated)
        {
            str ~= ("...(truncated)");
        }

        return str;
    }
}
