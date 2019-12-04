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

module hunt.proton.codec.CompositeReadableBuffer;

import hunt.collection.ByteBuffer;
//import java.nio.CharBuffer;
//import java.nio.InvalidMarkException;
//import java.nio.charset.CharacterCodingException;
//import java.nio.charset.CharsetDecoder;
//import java.nio.charset.CoderResult;
//import java.nio.charset.StandardCharsets;
import hunt.collection.ArrayList;
import hunt.collection.Collections;
import hunt.collection.List;
import hunt.Exceptions;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.WritableBuffer;
import hunt.collection.BufferUtils;
import std.algorithm;
import std.math;

import hunt.Float;
import hunt.Double;
import hunt.Byte;
import hunt.String;
import std.concurrency : initOnce;
import std.conv;
/**
 * ReadableBuffer implementation whose content is made up of one or more
 * byte arrays.
 */
class CompositeReadableBuffer : ReadableBuffer {

   // private static List!(byte[]) EMPTY_LIST = new ArrayList!(byte[])();
   // private static ByteBuffer EMPTY_BUFFER = BufferUtils.toBuffer(new byte[0]);
  //  private static CompositeReadableBuffer EMPTY_SLICE = new CompositeReadableBuffer(false);
    private static int UNSET_MARK = -1;

    private static int SHORT_BYTES = 2;
    private static int INT_BYTES = 4;
    private static int LONG_BYTES = 8;

    private ArrayList!(byte[]) contents;

    // Track active array and our offset into it.
    private int currentArrayIndex = -1;
    private byte[] currentArray;
    private int currentOffset;

    // State global to the buffer.
    private int _position;
    private int _limit;
    private int _capacity;
    private int _mark = -1;
    private bool compactable = true;


    static List!(byte[]) EMPTY_LIST() {
        __gshared List!(byte[]) inst;
        return initOnce!inst(new ArrayList!(byte[])());
    }

    static ByteBuffer EMPTY_BUFFER() {
        __gshared ByteBuffer inst;
        return initOnce!inst(BufferUtils.toBuffer(new byte[0]));
    }


    static CompositeReadableBuffer EMPTY_SLICE() {
        __gshared CompositeReadableBuffer inst;
        return initOnce!inst(new CompositeReadableBuffer(false));
    }

    /**
     * Creates a default empty composite buffer
     */
    this() {
    }

    this(byte[] array, int offset) {
        this.currentArray = array;
        this.currentOffset = offset;
        if(array != null) {
            this._capacity = cast(int)array.length;
        }
        this._limit = _capacity;
    }

    this(bool compactable) {
        this.compactable = compactable;
    }

    public List!(byte[]) getArrays() {
        return contents is null ? EMPTY_LIST :contents;
    }

    public int getCurrentIndex() {
        return currentArrayIndex;
    }

    /**
     * Gets the current position index in the current backing array, which represents the current buffer position.
     *
     * This value includes any buffer position movement, and resets when moving across array segments, so it only
     * gives the starting offset for the first array if the buffer position is 0.
     *
     * Value may be out of array bounds if the the buffer currently has no content remaining.
     *
     * @return the position index in the current array representing the current buffer position.
     */
    public int getCurrentArrayPosition() {
        return currentOffset;
    }

    override
    public bool hasArray() {
        return currentArray != null && (contents is null || contents.size() == 1);
    }

    public int capacity() {
        return this._capacity;
    }

    override
    public byte[] array() {
        if (hasArray()) {
            return currentArray;
        }

        throw new UnsupportedOperationException("Buffer not backed by a single array");
    }

    override
    public int arrayOffset() {
        if (hasArray()) {
            return currentOffset - _position;
        }

        throw new UnsupportedOperationException("Buffer not backed by a single array");
    }

    override
    public byte get() {
        if (_position == _limit) {
            throw new BufferUnderflowException();
        }

        byte result = currentArray[currentOffset++];
        _position++;
        maybeMoveToNextArray();

        return result;
    }

    override
    public byte get(int index) {
        if (index < 0 || index >= _limit) {
            throw new IndexOutOfBoundsException("The given index is not valid: " ~ to!string(index));
        }

        byte result = 0;

        if (index == _position) {
            result = currentArray[currentOffset];
        } else if (index < _position) {
            result = getBackwards(index);
        } else {
            result = getForward(index);
        }

        return result;
    }

    private byte getForward(int index) {
        byte result = 0;

        int currentArrayIndex = this.currentArrayIndex;
        int currentOffset = this.currentOffset;
        byte[] currentArray = this.currentArray;

        for (int amount = index - _position; amount >= 0;) {
            if (amount < currentArray.length - currentOffset) {
                result = currentArray[currentOffset + amount];
                break;
            } else {
                amount -= currentArray.length - currentOffset;
                currentArray = contents.get(++currentArrayIndex);
                currentOffset = 0;
            }
        }

        return result;
    }

    private byte getBackwards(int index) {
        byte result = 0;

        int currentArrayIndex = this.currentArrayIndex;
        int currentOffset = this.currentOffset;
        byte[] currentArray = this.currentArray;

        for (int amount = _position - index; amount >= 0;) {
            if ((currentOffset - amount) >= 0) {
                result = currentArray[currentOffset - amount];
                break;
            } else {
                amount -= currentOffset;
                currentArray = contents.get(--currentArrayIndex);
                currentOffset = cast(int)currentArray.length;
            }
        }

        return result;
    }

    override
    public int getInt() {
        if (remaining() < INT_BYTES) {
            throw new BufferUnderflowException();
        }

        int result = 0;

        if (currentArray.length - currentOffset >= 4) {
            result = cast(int)(currentArray[currentOffset++] & 0xFF) << 24 |
                     cast(int)(currentArray[currentOffset++] & 0xFF) << 16 |
                     cast(int)(currentArray[currentOffset++] & 0xFF) << 8 |
                     cast(int)(currentArray[currentOffset++] & 0xFF) << 0;
            maybeMoveToNextArray();
        } else {
            for (int i = INT_BYTES - 1; i >= 0; --i) {
                result |= cast(int)(currentArray[currentOffset++] & 0xFF) << (i * Byte.SIZE);
                maybeMoveToNextArray();
            }
        }

        _position += 4;

        return result;
    }

    override
    public long getLong() {
        if (remaining() < LONG_BYTES) {
            throw new BufferUnderflowException();
        }

        long result = 0;

        if (currentArray.length - currentOffset >= 8) {
            result = cast(long)(currentArray[currentOffset++] & 0xFF) << 56 |
                     cast(long)(currentArray[currentOffset++] & 0xFF) << 48 |
                     cast(long)(currentArray[currentOffset++] & 0xFF) << 40 |
                     cast(long)(currentArray[currentOffset++] & 0xFF) << 32 |
                     cast(long)(currentArray[currentOffset++] & 0xFF) << 24 |
                     cast(long)(currentArray[currentOffset++] & 0xFF) << 16 |
                     cast(long)(currentArray[currentOffset++] & 0xFF) << 8 |
                     cast(long)(currentArray[currentOffset++] & 0xFF) << 0;
            maybeMoveToNextArray();
        } else {
            for (int i = LONG_BYTES - 1; i >= 0; --i) {
                result |= cast(long)(currentArray[currentOffset++] & 0xFF) << (i * Byte.SIZE);
                maybeMoveToNextArray();
            }
        }

        _position += 8;

        return result;
    }

    override
    public short getShort() {
        if (remaining() < SHORT_BYTES) {
            throw new BufferUnderflowException();
        }

        short result = 0;

        for (int i = SHORT_BYTES - 1; i >= 0; --i) {
            result |= (currentArray[currentOffset++] & 0xFF) << (i * Byte.SIZE);
            maybeMoveToNextArray();
        }

        _position += 2;

        return result;
    }

    override
    public float getFloat() {
        return Float.intBitsToFloat(getInt());
    }

    override
    public double getDouble() {
        return Double.longBitsToDouble(getLong());
    }

    override
    public CompositeReadableBuffer get(byte[] data) {
        return get(data, 0, cast(int)data.length);
    }

    override
    public CompositeReadableBuffer get(byte[] data, int offset, int length) {
        validateReadTarget(cast(int)data.length, offset, length);

        if (length > remaining()) {
            throw new BufferUnderflowException();
        }

        int copied = 0;
        while (length > 0) {
            int chunk = min((currentArray.length - currentOffset), length);
          //  System.arraycopy(currentArray, currentOffset, data, offset + copied, chunk);

            int end = offset + copied + chunk;
            int start =  offset + copied;

            data[start .. end] = currentArray[currentOffset .. currentOffset + chunk];

            currentOffset += chunk;
            length -= chunk;
            copied += chunk;

            maybeMoveToNextArray();
        }

        _position += copied;

        return this;
    }

    override
    public CompositeReadableBuffer get(WritableBuffer target) {
        int length = min(target.remaining(), remaining());

        do {
            int chunk = min((currentArray.length - currentOffset), length);

            if (chunk == 0) {
                break;  // This buffer is out of data
            }

            target.put(currentArray, currentOffset, chunk);

            currentOffset += chunk;
            _position += chunk;
            length -= chunk;

            maybeMoveToNextArray();
        } while (length > 0);

        return this;
    }


    public CompositeReadableBuffer position(int pos) {
        if (pos < 0 || pos > _limit) {
            throw new IllegalArgumentException("position must be non-negative and no greater than the limit");
        }

        int moveBy = pos - this._position;
        if (moveBy >= 0) {
            moveForward(moveBy);
        } else {
            moveBackwards(abs(moveBy));
        }

        this._position = pos;

        if (_mark > pos) {
            _mark = UNSET_MARK;
        }

        return this;
    }

    private void moveForward(int moveBy) {
        while (moveBy > 0) {
            if (moveBy < currentArray.length - currentOffset) {
                currentOffset += moveBy;
                break;
            } else {
                moveBy -= currentArray.length - currentOffset;
                if (currentArrayIndex != -1 && currentArrayIndex < contents.size() - 1) {
                    currentArray = contents.get(++currentArrayIndex);
                    currentOffset = 0;
                } else {
                    currentOffset = cast(int)currentArray.length;
                }
            }
        }
    }

    private void moveBackwards(int moveBy) {
        while (moveBy > 0) {
            if ((currentOffset - moveBy) >= 0) {
                currentOffset -= moveBy;
                break;
            } else {
                moveBy -= currentOffset;
                currentArray = contents.get(--currentArrayIndex);
                currentOffset = cast(int)currentArray.length;
            }
        }
    }

    override
    public int position() {
        return _position;
    }

    override
    public CompositeReadableBuffer slice() {
        int newCapacity = limit() - position();

        CompositeReadableBuffer result;

        if (newCapacity == 0) {
            result = EMPTY_SLICE;
        } else {
            result = new CompositeReadableBuffer(currentArray, currentOffset);
            result.contents = contents;
            result.currentArrayIndex = currentArrayIndex;
            result._capacity = newCapacity;
            result._limit = newCapacity;
            result._position = 0;
            result.compactable = false;
        }

        return result;
    }

    override
    public CompositeReadableBuffer flip() {
        _limit = _position;
        position(0); // Move by index to avoid corrupting a slice.
        _mark = UNSET_MARK;

        return this;
    }

    override
    public CompositeReadableBuffer limit(int limit) {
        if (limit < 0 || limit > _capacity) {
            throw new IllegalArgumentException("limit must be non-negative and no greater than the capacity");
        }

        if (_mark > limit) {
            _mark = UNSET_MARK;
        }

        if (_position > limit) {
            position(limit);
        }

        this._limit = limit;

        return this;
    }

    override
    public int limit() {
        return _limit;
    }

    override
    public CompositeReadableBuffer mark() {
        this._mark = _position;
        return this;
    }

    override
    public CompositeReadableBuffer reset() {
        if (_mark < 0) {
            throw new InvalidMarkException();
        }

        position(_mark);

        return this;
    }

    override
    public CompositeReadableBuffer rewind() {
        return position(0);
    }

    override
    public CompositeReadableBuffer clear() {
        _mark = UNSET_MARK;
        _limit = _capacity;

        return position(0);
    }

    override
    public int remaining() {
        return _limit - _position;
    }

    override
    public bool hasRemaining() {
        return remaining() > 0;
    }

    override
    public CompositeReadableBuffer duplicate() {
        CompositeReadableBuffer duplicated =
            new CompositeReadableBuffer(currentArray, currentOffset);

        if (contents !is null) {
            duplicated.contents = new ArrayList!(byte[])(contents);
        }

        duplicated._capacity = _capacity;
        duplicated.currentArrayIndex = currentArrayIndex;
        duplicated._limit = _limit;
        duplicated._position = _position;
        duplicated._mark = _mark;
        duplicated.compactable = compactable;   // A slice duplicated should not allow compaction.

        return duplicated;
    }

    override
    public ByteBuffer byteBuffer() {
        int viewSpan = limit() - position();

        ByteBuffer result;

        if (viewSpan == 0) {
            result = EMPTY_BUFFER;
        } else if (viewSpan <= currentArray.length - currentOffset) {
            result = BufferUtils.toBuffer(currentArray, currentOffset, viewSpan);
        } else {
            result = buildByteBuffer(viewSpan);
        }

        return result;
    }

    private ByteBuffer buildByteBuffer(int span) {
        //byte[] compactedView = new byte[span];

        //byte[] compactedView = new byte[span];
        //int arrayIndex = currentArrayIndex;
        //
        //// Take whatever is left from the current array;
        //System.arraycopy(currentArray, currentOffset, compactedView, 0, currentArray.length - currentOffset);
        //int copied = currentArray.length - currentOffset;
        //
        //while (copied < span) {
        //    byte[] next = contents.get(++arrayIndex);
        //    final int length = Math.min(span - copied, next.length);
        //    System.arraycopy(next, 0, compactedView, copied, length);
        //    copied += length;
        //}



        byte[] compactedView = new byte[span];
        int arrayIndex = currentArrayIndex;

        compactedView[0 .. (cast(int)currentArray.length - currentOffset)] = currentArray[currentOffset .. (currentOffset+cast(int)currentArray.length - currentOffset)];
        int copied = cast(int)currentArray.length - currentOffset;

        while (copied < span) {
            byte[] next = contents.get(++arrayIndex);
            int length = min(span - copied, cast(int)next.length);
           // System.arraycopy(next, 0, compactedView, copied, length);
            compactedView[copied .. copied+length] = next[0 ..length ];
            copied += length;
        }

       // compactedView ~= currentArray[currentOffset .. $];
        // Take whatever is left from the current array;
        //System.arraycopy(currentArray, currentOffset, compactedView, 0, currentArray.length - currentOffset);
        //int copied = currentArray.length - currentOffset;

        //for (;arrayIndex < contents.size();)
        //{
        //    byte[] next = contents.get(++arrayIndex);
        //    compactedView ~= next;
        //}

        //while (copied < span) {
        //    byte[] next = contents.get(++arrayIndex);
        //    int length = min(span - copied, next.length);
        //    System.arraycopy(next, 0, compactedView, copied, length);
        //    copied += length;
        //}

        return BufferUtils.toBuffer(compactedView);
    }

    override
    public string readUTF8(){
        return readString();
    }

    public string readString() {
        if (!hasRemaining()) {
            return  ( "");
        }

        if (hasArray()) {
            return cast(string)BufferUtils.toBuffer(currentArray, currentOffset, remaining()).getRemaining();
        } else {
            return readStringFromComponents();
        }
      //  CharBuffer decoded = null;

     //   if (hasArray()) {
          //return new String( cast(string)currentArray[currentOffset .. currentOffset+remaining()]);
           // BufferUtils.toBuffer(currentArray, currentOffset, remaining());
           // decoded = decoder.decode(ByteBuffer.wrap(currentArray, currentOffset, remaining()));
       // }
        //else {
        //    decoded = readStringFromComponents(decoder);
        //}

       // return decoded.toString();
    }

    private string readStringFromComponents(){
        int size = cast(int)(remaining() * 1);
       // CharBuffer decoded = CharBuffer.allocate(size);

        int arrayIndex = currentArrayIndex;
        int viewSpan = limit() - position(); //23
        int processed = min(currentArray.length - currentOffset, viewSpan); //11
        byte[] wrapper = BufferUtils.toBuffer(currentArray, currentOffset, processed).getRemaining();
        while (processed != viewSpan && arrayIndex <= contents.size())
        {
            byte[] next = contents.get(++arrayIndex);
            int wrapSize = min(next.length, viewSpan - processed);
            byte [] tmp = BufferUtils.toBuffer(next,0,wrapSize).getRemaining();
            wrapper ~= tmp;
            processed += wrapSize;
        }

        return (cast(string)wrapper);
        //CoderResult step = CoderResult.OVERFLOW;
        //
        //do {
        //    bool endOfInput = processed == viewSpan;
        //    step = decoder.decode(wrapper, decoded, endOfInput);
        //    if (step.isUnderflow() && endOfInput) {
        //        step = decoder.flush(decoded);
        //        break;
        //    }
        //
        //    if (step.isOverflow()) {
        //        size = 2 * size + 1;
        //        CharBuffer upsized = CharBuffer.allocate(size);
        //        decoded.flip();
        //        upsized.put(decoded);
        //        decoded = upsized;
        //        continue;
        //    }
        //
        //    byte[] next = contents.get(++arrayIndex);
        //    int wrapSize = Math.min(next.length, viewSpan - processed);
        //    wrapper = ByteBuffer.wrap(next, 0, wrapSize);
        //    processed += wrapSize;
        //} while (!step.isError());
        //
        //if (step.isError()) {
        //    step.throwException();
        //}
        //
        //return (CharBuffer) decoded.flip();
    }

    /**
     * Compact the buffer dropping arrays that have been consumed by previous
     * reads from this Composite buffer.  The limit is reset to the new _capacity
     */
    override
    public CompositeReadableBuffer reclaimRead() {
        if (!compactable || (currentArray is null && contents is null)) {
            return this;
        }

        int totalCompaction = 0;
        int totalRemovals = 0;

        for (; totalRemovals < currentArrayIndex; ++totalRemovals) {
            byte[] element = contents.removeAt(0);
            totalCompaction += element.length;
        }

        currentArrayIndex -= totalRemovals;

        if (currentArray.length == currentOffset) {
            totalCompaction += currentArray.length;

            // If we are sitting on the end of the data (length == offest) then
            // we are also at the last element in the ArrayList if one is currently
            // in use, so remove the data and release the list.
            if (currentArrayIndex == 0) {
                contents.clear();
                contents = null;
            }

            currentArray = null;
            currentArrayIndex = -1;
            currentOffset = 0;
        }

        _position -= totalCompaction;
        _limit = _capacity -= totalCompaction;

        if (_mark != UNSET_MARK) {
            _mark -= totalCompaction;
        }

        return this;
    }

    /**
     * Adds the given array into the composite buffer at the end.
     * <p>
     * The appended array is not copied so changes to the source array are visible in this
     * buffer and vice versa.  If this composite was empty than it would return true for the
     * {@link #hasArray()} method until another array is appended.
     * <p>
     * Calling this method resets the limit to the new _capacity.
     *
     * @param array
     *      The array to add to this composite buffer.
     *
     * @throws IllegalArgumentException if the array is null or zero size.
     * @throws IllegalStateException if the buffer does not allow appends.
     *
     * @return a reference to this {@link CompositeReadableBuffer}.
     */
    public CompositeReadableBuffer append(byte[] array) {
        validateAppendable();

        if (array is null || array.length == 0) {
            throw new IllegalArgumentException("Array must not be empty or null");
        }

        if (currentArray is null) {
            currentArray = array;
            currentOffset = 0;
        } else if (contents is null) {
            contents = new ArrayList!(byte[]);
            contents.add(currentArray);
            contents.add(array);
            currentArrayIndex = 0;
            // If we exhausted the array previously then it should move to the new one now.
            maybeMoveToNextArray();
        } else {
            contents.add(array);
            // If we exhausted the list previously then it didn't move onward at the time, so it should now.
            maybeMoveToNextArray();
        }

        _capacity += array.length;
        _limit = _capacity;

        return this;
    }

    private void validateAppendable() {
        if (!compactable) {
            throw new IllegalStateException();
        }
    }

    private void validateBuffer(ReadableBuffer buffer) {
        if (buffer is null) {
            throw new IllegalArgumentException("A non-null buffer must be provided");
        }

        if (!buffer.hasRemaining()) {
            throw new IllegalArgumentException("Buffer has no remaining content to append");
        }
    }

    /**
     * Adds the given composite buffer contents (from current position, up to the limit) into this
     * composite buffer at the end. The source buffer position will be set to its limit.
     * <p>
     * The appended buffer contents are not copied wherever possible, so changes to the source
     * arrays are typically visible in this buffer and vice versa. Exceptions include where the
     * source buffer position is not located at the start of its current backing array, or where the
     * given buffer has a limit that doesn't encompass all of the last array used, and
     * so the remainder of that arrays contents must be copied first to append here.
     * <p>
     * Calling this method resets the limit to the new _capacity.
     *
     * @param buffer
     *      the buffer with contents to append into this composite buffer.
     *
     * @throws IllegalArgumentException if the given buffer is null or has zero remainder.
     * @throws IllegalStateException if the buffer does not allow appends.
     *
     * @return a reference to this {@link CompositeReadableBuffer}.
     */
    public CompositeReadableBuffer append(CompositeReadableBuffer buffer) {
        validateAppendable();
        validateBuffer(buffer);

        byte[] chunk;
        do {
            int bufferRemaining = buffer.remaining();
            int arrayRemaining = cast(int)(buffer.currentArray.length) - buffer.currentOffset;
            if (buffer.currentOffset > 0 || bufferRemaining < arrayRemaining) {
                int length = min(arrayRemaining, bufferRemaining);
               // chunk = new byte[length];
              //  System.arraycopy(buffer.currentArray, buffer.currentOffset, chunk, 0, length);
                int endindex = buffer.currentOffset + length;
                chunk = buffer.currentArray[buffer.currentOffset .. endindex].dup;
            } else {
                chunk = buffer.currentArray;
            }

            append(chunk);

            buffer.position(buffer.position() + cast(int)chunk.length);
        } while (buffer.hasRemaining());

        return this;
    }

    /**
     * Adds the given readable buffer contents (from current position, up to the limit) into this
     * composite buffer at the end. The source buffer position will be set to its limit.
     * <p>
     * The appended buffer contents are not copied wherever possible, so changes to the source
     * arrays are typically visible in this buffer and vice versa. Exceptions are where the
     * source buffer is not backed by an array, or where the source buffer position is not
     * located at the start of its backing array, and so the remainder of the contents must
     * be copied first to append here.
     * <p>
     * Calling this method resets the limit to the new _capacity.
     *
     * @param buffer
     *      the buffer with contents to append into this composite buffer.
     *
     * @throws IllegalArgumentException if the given buffer is null or has zero remainder.
     * @throws IllegalStateException if the buffer does not allow appends.
     *
     * @return a reference to this {@link CompositeReadableBuffer}.
     */
    public CompositeReadableBuffer append(ReadableBuffer buffer) {
        CompositeReadableBuffer cBuffer = cast(CompositeReadableBuffer)buffer;
        if(cBuffer !is null) {
            append(cBuffer);
        } else {
            validateAppendable();
            validateBuffer(buffer);

            if (buffer.hasArray()) {

                byte[] chunk = buffer.array();

                int bufferRemaining = buffer.remaining();
                if (buffer.arrayOffset() > 0 || bufferRemaining < chunk.length) {
                    int endindex = buffer.arrayOffset() + bufferRemaining;
                    chunk = buffer.array[buffer.arrayOffset() .. endindex].dup;
                   // System.arraycopy(buffer.array(), buffer.arrayOffset(), chunk, 0, bufferRemaining);
                }

                append(chunk);

                buffer.position(buffer.position() + cast(int)chunk.length);
            } else {
                byte[] chunk = new byte[buffer.remaining()];
                buffer.get(chunk);

                append(chunk);
            }
        }

        return this;
    }

    //override
    public int hashCode() {
        int hash = 1;
        int remaining = remaining();

        if (currentArrayIndex < 0 || remaining <= currentArray.length - currentOffset) {
            while (remaining > 0) {
                hash = 31 * hash + currentArray[currentOffset + --remaining];
            }
        } else {
            hash = hashCodeFromComponents();
        }

        return hash;
    }

    private int hashCodeFromComponents() {
        int hash = 1;
        byte[] array = currentArray;
        int arrayOffset = currentOffset;
        int arraysIndex = currentArrayIndex;

        // Run to the the array and offset where we want to start the hash from
        int remaining = remaining();
        for (int moveBy = remaining; moveBy > 0; ) {
            if (moveBy <= array.length - arrayOffset) {
                arrayOffset += moveBy;
                break;
            } else {
                moveBy -= array.length - arrayOffset;
                array = contents.get(++arraysIndex);
                arrayOffset = 0;
            }
        }

        // Now run backwards through the arrays to match what ByteBuffer would produce
        for (int moveBy = remaining; moveBy > 0; moveBy--) {
            hash = 31 * hash + array[--arrayOffset];
            if (arrayOffset == 0 && arraysIndex > 0) {
                array = contents.get(--arraysIndex);
                arrayOffset = cast(int)array.length;
            }
        }

        return hash;
    }


    override int opCmp(ReadableBuffer o)
    {
        return this.capacity() - o.capacity();
    }



        override bool opEquals(Object other)
        {
        if (this is other) {
            return true;
        }

        ReadableBuffer buffer = cast(ReadableBuffer) other;
        if ( buffer is null ) {
            return false;
        }


        int remaining = remaining();
        if (remaining != buffer.remaining()) {
            return false;
        }

        if (remaining == 0) {
            // No content to compare, and we already checked 'remaining' is equal. Protects from NPE below.
            return true;
        }

        if (hasArray() || remaining <= currentArray.length - currentOffset) {
            // Either there is only one array, or the span to compare is within a single chunk of this buffer,
            // allowing the compare to directly access the underlying array instead of using slower get methods.
            return equals(currentArray, currentOffset, remaining, buffer);
        } else {
            return equals(this, buffer);
        }
    }

    private static bool equals(byte[] buffer, int start, int length, ReadableBuffer other) {
        int position = other.position();
        for (int i = 0; i < length; i++) {
            if (buffer[start + i] != other.get(position + i)) {
                return false;
            }
        }
        return true;
    }

    private static bool equals(ReadableBuffer buffer, ReadableBuffer other) {
        int origPos = buffer.position();
        try {
            for (int i = other.position(); buffer.hasRemaining(); i++) {
                if (!equals(buffer.get(), other.get(i))) {
                    return false;
                }
            }
            return true;
        } finally {
            buffer.position(origPos);
        }
    }

    //override
    //public String toString() {
    //    StringBuffer builder = new StringBuffer();
    //    builder.append("CompositeReadableBuffer");
    //    builder.append("{ pos=");
    //    builder.append(position());
    //    builder.append(" limit=");
    //    builder.append(limit());
    //    builder.append(" capacity=");
    //    builder.append(capacity());
    //    builder.append(" }");
    //
    //    return builder.toString();
    //}

    private static bool equals(byte x, byte y) {
        return x == y;
    }

    private void maybeMoveToNextArray() {
        if (currentArray.length == currentOffset) {
            if (currentArrayIndex >= 0 && currentArrayIndex < (contents.size() - 1)) {
                currentArray = contents.get(++currentArrayIndex);
                currentOffset = 0;
            }
        }
    }

    private static void validateReadTarget(int destSize, int offset, int length) {
        if ((offset | length) < 0) {
            throw new IndexOutOfBoundsException("offset and legnth must be non-negative");
        }

        if ((cast(long) offset + cast(long) length) > destSize) {
            throw new IndexOutOfBoundsException("target is to small for specified read size");
        }
    }
}
