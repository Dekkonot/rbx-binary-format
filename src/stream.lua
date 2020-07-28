-- Binary stream module built explicitly for Roblox's binary format

local HEX_TO_BIN = {
    ["0"] = "0000", ["1"] = "0001", ["2"] = "0010", ["3"] = "0011",
    ["4"] = "0100", ["5"] = "0101", ["6"] = "0110", ["7"] = "0111",
    ["8"] = "1000", ["9"] = "1001", ["a"] = "1010", ["b"] = "1011",
    ["c"] = "1100", ["d"] = "1101", ["e"] = "1110", ["f"] = "1111",
}

local byte_to_hex = {}
for i = 0, 0xff do
    byte_to_hex[i] = string.format("%02x", i)
end

local function transformInteger(n)
    -- If the value is zero or positive, 2 x n
    -- Otherwise, 2 x |n| - 1
    -- See: https://blog.roblox.com/2013/05/condense-and-compress-our-custom-binary-file-format/

    -- Both 32-bit and 64-bit integers are subject to this transformation, so a branch is desirable over bitwise ops

    if n >= 0 then
        return 2*n
    else
        return -(2*n)-1
    end
end

local function untransformInteger(n)
    -- If n%2 == 0, n/2
    -- Otherwise, -(n+1)/2
    if n%2 == 0 then
        return n/2
    else
        return -(n+1)/2
    end
end

local function float32ToUInt32(float)
    local sign = float < 0
    if sign then
        float = -float
    end

    if float == math.huge then
        return sign and 0xff800000 or 0x7f800000 -- negative and positive infinities
    elseif float ~= float then
        return 0xffeeddcc -- Arbitrary NaN
    elseif float == 0 then
        return 0x00000000
    end

    local mantissa, exponent = math.frexp(float)

    if exponent+127 <= 1 then
        mantissa = math.floor(mantissa*0x800000+0.5)

        return (sign and 0x80000000 or 0x00000000)+mantissa
    else
        mantissa = math.floor((mantissa-0.5)*0x1000000+0.5)

        return (sign and 0x80000000 or 0x00000000)+bit32.lshift(exponent+126, 23)+mantissa
    end
end

local function uint32ToFloat32(int)
    local sign = bit32.btest(int, 0x80000000)
    local exponent = bit32.band(bit32.rshift(int, 23), 0xff)
    local mantissa = bit32.band(int, 0x7fffff)

    if exponent == 0xff then
        if mantissa == 0 then
            return sign and -math.huge or math.huge
        else
            return 0/0
        end
    elseif exponent == 0 then
        if mantissa == 0 then
            return 0
        else
            return sign and -math.ldexp(mantissa/0x800000, -126) or math.ldexp(mantissa/0x800000, -126)
        end
    else
        return sign and -math.ldexp((mantissa/0x800000)+1, exponent-127) or math.ldexp((mantissa/0x800000)+1, exponent-127)
    end
end

local function constructor(init)
    local bytes = {}
    local byteCount = 0
    local pointer = 1

    if init then
        byteCount = #init
        for i = 1, byteCount do
            bytes[i] = string.byte(init, i, i)
        end
    end

    --- Returns a string of binary data that represents the stream contents.
    --- This function should be used to 'export' the stream contents for use elsewhere.
    local function dumpString()
        local output = {}
        local c = 1
        for i = 1, byteCount, 4096 do
            output[c] = string.char(table.unpack(bytes, i, math.min(byteCount, i+4095)))
            c = c+1
        end

        return table.concat(output, "")
    end

    --- Returns a string of binary digits that represent the stream contents.
    local function dumpBinary()
        local output = {}
        for i, v in ipairs(bytes) do
            output[i] = string.gsub(byte_to_hex[v], "%x", HEX_TO_BIN)
        end
        return table.concat(output, " ")
    end

    --- Returns a string of hex digits that represent the stream contents.
    local function dumpHex()
        local output = {}
        for i, v in ipairs(bytes) do
            output[i] = byte_to_hex[v]
        end
        return table.concat(output, " ")
    end

    --- Returns where the pointer is in the stream.
    local function getPointer()
        return pointer
    end

    --- Sets the pointer from the beginning of the stream.
    local function setPointer(n)
        assert(type(n) == "number", "argument #1 to setPointer should be a number")
        assert(n%1 == 0 and n > 0, "argument #1 to setPointer should be a positive integer")
        assert(n <= byteCount, "argument #1 to setPointer should not go beyond the end of the stream")

        pointer = n
    end

    --- Sets the pointer from the end of the stream. Equivalent to `setPointer(getLength()-n)`.
    local function setPointerFromEnd(n)
        assert(type(n) == "number", "argument #1 to setPointer should be a number")
        assert(n%1 == 0 and n >= 0, "argument #1 to setPointer should be a non-negative integer")
        assert(n <= byteCount, "argument #1 to setPointer should not go beyond the end of the stream")

        pointer = byteCount-n+1
    end

    --- Returns the length of the stream.
    local function getLength()
        return byteCount
    end

    --- Returns whether the pointer is at the end of the stream.
    local function isFinished()
        return pointer == byteCount
    end

    --- Consumes another Stream and adds its bytes to the stream.
    local function consumeStream(stream)
        local str = stream.dumpString()

        for i = 1, #str do
            bytes[byteCount+i] = string.byte(str, i, i)
        end
        byteCount = byteCount+#str
    end

    --- Writes a byte.
    local function writeByte(n)
        assert(type(n) == "number", "argument #1 to writeByte should be a number")
        assert(n%1 == 0, "argument #1 to writeByte should be an integer")
        assert(n >= 0x00 and n <= 0xff, "argument #1 to writeByte should be in the range [0, 255]")

        byteCount = byteCount+1
        bytes[byteCount] = n
    end

    --- Writes a little-endian UInt16.
    local function writeLEUInt16(n)
        assert(type(n) == "number", "argument #1 to writeLEUInt16 should be a number")
        assert(n%1 == 0, "argument #1 to writeLEUInt16 should be an integer")
        assert(n >= 0x0000 and n <= 0xffff, "argument #1 to writeLEUInt16 should be in the range [0, 65535]")

        bytes[byteCount+1] = bit32.band(n, 0xff)
        bytes[byteCount+2] = bit32.rshift(n, 8)

        byteCount = byteCount+2
    end

    --- Writes a little-endian UInt32.
    local function writeLEUInt32(n)
        assert(type(n) == "number", "argument #1 to writeLEUInt16 should be a number")
        assert(n%1 == 0, "argument #1 to writeLEUInt16 should be an integer")
        assert(n >= 0x0000 and n <= 0xffffffff, "argument #1 to writeLEUInt16 should be in the range [0, 65535]")

        bytes[byteCount+1] = bit32.band(n, 0xff)
        bytes[byteCount+2] = bit32.band(bit32.rshift(n, 8), 0xff)
        bytes[byteCount+3] = bit32.band(bit32.rshift(n, 16), 0xff)
        bytes[byteCount+4] = bit32.rshift(n, 24)

        byteCount = byteCount+4
    end

    --- Writes a little-endian Int32.
    local function writeLEInt32(n)
        assert(type(n) == "number", "argument #1 to writeLEInt32 should be a number")
        assert(n%1 == 0, "argument #1 to writeLEInt32 should be an integer")
        assert(n >= -0x80000000 and n <= 0x7fffffff, "argument #1 to writeLEInt32 should be in the range [-2147483648, 2147483647]")

        if n < 0 then
            n = (0x80000000+n)+0x80000000
        end

        bytes[byteCount+1] = bit32.band(n, 0xff)
        bytes[byteCount+2] = bit32.band(bit32.rshift(n, 8), 0xff)
        bytes[byteCount+3] = bit32.band(bit32.rshift(n, 16), 0xff)
        bytes[byteCount+4] = bit32.rshift(n, 24)

        byteCount = byteCount+4
    end

    --- Writes a little-endian float32.
    local function writeLEFloat32(n)
        assert(type(n) == "number", "argument #1 to writeLEFloat32 should be a number")

        writeLEUInt32(float32ToUInt32(n))
    end

    --- Writes a little-endian float64.
    local function writeLEFloat64(n)
        assert(type(n) == "number", "argument #1 to writeLEFloat64 should be a number")

        local sign = n < 0
        if sign then
            n = -n
        end

        if n == math.huge then -- 0xfff0000000000000 or 0x7ff0000000000000
            bytes[byteCount+1] = 0x00
            bytes[byteCount+2] = 0x00
            bytes[byteCount+3] = 0x00
            bytes[byteCount+4] = 0x00
            bytes[byteCount+5] = 0x00
            bytes[byteCount+6] = 0x00
            bytes[byteCount+7] = 0xf0
            bytes[byteCount+8] = sign and 0xff or 0x7f

            byteCount = byteCount+8

            return
        elseif n ~= n then -- 0xfffeeedddcccbbba
            bytes[byteCount+1] = 0xba
            bytes[byteCount+2] = 0xbb
            bytes[byteCount+3] = 0xcc
            bytes[byteCount+4] = 0xdc
            bytes[byteCount+5] = 0xdd
            bytes[byteCount+6] = 0xee
            bytes[byteCount+7] = 0xfe
            bytes[byteCount+8] = 0xff

            byteCount = byteCount+8

            return
        elseif n == 0 then -- 0x0000000000000000
            bytes[byteCount+1] = 0x00
            bytes[byteCount+2] = 0x00
            bytes[byteCount+3] = 0x00
            bytes[byteCount+4] = 0x00
            bytes[byteCount+5] = 0x00
            bytes[byteCount+6] = 0x00
            bytes[byteCount+7] = 0x00
            bytes[byteCount+8] = 0x00

            byteCount = byteCount+8

            return
        end

        local mantissa, exponent = math.frexp(n)

        if exponent+1023 <= 1 then
            mantissa = math.floor(mantissa*0x10000000000000+0.5)

            -- Mantissa of doubles is too large for bit32
            local leastSignificantChunk = mantissa%0x100000000 -- 32 bits
            local mostSignificantChunk = math.floor(mantissa/0x100000000) -- 20 bits

            bytes[byteCount+1] = bit32.band(leastSignificantChunk, 0xff)
            bytes[byteCount+2] = bit32.band(bit32.rshift(leastSignificantChunk, 8), 0xff)
            bytes[byteCount+3] = bit32.band(bit32.rshift(leastSignificantChunk, 16), 0xff)
            bytes[byteCount+4] = bit32.rshift(leastSignificantChunk, 24)
            bytes[byteCount+5] = bit32.band(mostSignificantChunk, 0xff)
            bytes[byteCount+6] = bit32.band(bit32.rshift(mostSignificantChunk, 8), 0xff)
            bytes[byteCount+7] = bit32.rshift(mostSignificantChunk, 16)
            bytes[byteCount+8] = sign and 0x80 or 0x00

            byteCount = byteCount+8

            return
        else
            mantissa = math.floor((mantissa-0.5)*0x20000000000000+0.5)

            local leastSignificantChunk = mantissa%0x100000000 -- 32 bits
            local mostSignificantChunk = math.floor(mantissa/0x100000000) -- 20 bits

            bytes[byteCount+1] = bit32.band(mostSignificantChunk, 0xff)
            bytes[byteCount+2] = bit32.band(bit32.rshift(leastSignificantChunk, 8), 0xff)
            bytes[byteCount+3] = bit32.band(bit32.rshift(leastSignificantChunk, 16), 0xff)
            bytes[byteCount+4] = bit32.band(bit32.rshift(leastSignificantChunk, 24), 0xff)
            bytes[byteCount+5] = bit32.band(mostSignificantChunk, 0xff)
            bytes[byteCount+6] = bit32.band(bit32.rshift(mostSignificantChunk, 8), 0xff)
            bytes[byteCount+7] = bit32.band(bit32.lshift(exponent+1022, 4), 0xff)+bit32.rshift(mostSignificantChunk, 16)
            bytes[byteCount+8] = (sign and 0x80 or 0x00)+bit32.rshift(exponent+1022, 4)

            byteCount = byteCount+8

            return
        end
    end

    --- Writes a little-endian Roblox style float32.
    local function writeRbxFloat(n)
        assert(type(n) == "number", "argument #1 to writeLEFloat32 should be a number")

        writeLEUInt32(bit32.lrotate(float32ToUInt32(n), 1))
    end

    --- Writes a length-prefixed string. The prefixed length is a little-endian UInt32.
    local function writeString(str)
        assert(type(str) == "string", "argument #1 to writeString should be a string")

        local len = #str
        assert(len <= 0xffffff, "argument #1 to writeString should be less than 4294967295 characters long")
        writeLEUInt32(len)

        for i = 1, len do
            bytes[byteCount+i] = string.byte(str, i, i)
        end
        byteCount = byteCount+len
    end

    local function writeSetLengthString(str)
        assert(type(str) == "string", "argument #1 to writeString should be a string")

        for i = 1, #str do
            bytes[byteCount+i] = string.byte(str, i, i)
        end
        byteCount = byteCount+#str
    end

    --- Writes an interleaved array of big-endian integers that are all `size` bytes.
    --- No transformations are applied to `values`.
    local function writeInterleavedUInt(values, size)
        local valueLen = #values
        for shift = (size-1)*8, 0, -8 do
            for i, v in ipairs(values) do
                bytes[byteCount+i] = bit32.band(bit32.rshift(v, shift), 0xff)
            end
            byteCount = byteCount+valueLen
        end
    end

    --- Writes an interleaved array of little-endian integers that are all `size` bytes.
    --- No transformations are applied to `values`.
    local function writeInterleavedLEUInt(values, size)
        local valueLen = #values
        for shift = 0, (size-1)*8, 8 do
            for i, v in ipairs(values) do
                bytes[byteCount+i] = bit32.band(bit32.rshift(v, shift), 0xff)
            end
            byteCount = byteCount+valueLen
        end
    end

    --- Writes an interleaved array of little-endian Roblox style floats.
    local function writeInterleavedRbxFloat32(values)
        local actualValues = {}
        for i, v in ipairs(values) do
            actualValues[i] = bit32.lrotate(float32ToUInt32(v), 1)
        end

        writeInterleavedLEUInt(actualValues, 4)
    end

    --- Writes an array of Referents. Transforms the results before passing to `writeInterleavedLEUInt`.
    local function writeReferents(values)
        local last = 0

        local actualValues = {}
        for i, v in ipairs(values) do
            actualValues[i] = transformInteger(v-last)
            last = v
        end

        writeInterleavedUInt(actualValues, 4)
    end


    --- Reads a byte from the stream.
    local function readByte()
        assert(pointer <= byteCount, "readByte cannot read past the end of the stream")

        local byte = bytes[pointer]
        pointer = pointer+1

        return byte
    end

    --- Reads a little-endian UInt16 from the stream.
    local function readLEUInt16()
        assert(pointer+1 <= byteCount, "readLEUInt16 cannot read past the end of the stream")

        local int = bit32.lshift(bytes[pointer+1], 8)+bytes[pointer]
        pointer = pointer+2

        return int
    end

    --- Reads a little-endian UInt32 from the stream.
    local function readLEUInt32()
        assert(pointer+3 <= byteCount, "readLEUInt32 cannot read past the end of the stream")

        local int1 = bit32.lshift(bytes[pointer+3], 24)+bit32.lshift(bytes[pointer+2], 16)
        local int2 = bit32.lshift(bytes[pointer+1], 8)+bytes[pointer]
        pointer = pointer+4

        return int1+int2
    end

    --- Reads a little-endian Int32 from the stream.
    local function readLEInt32()
        assert(pointer+3 <= byteCount, "readLEInt32 cannot read past the end of the stream")

        local int = readLEUInt32()

        if bit32.btest(int, 0x80000000) then
            return bit32.band(int, 0x7fffffff)-0x80000000
        else
            return bit32.band(int, 0x7fffffff)
        end
    end

    --- Reads a little-endian Float32 from the stream.
    local function readLEFloat32()
        assert(pointer+3 <= byteCount, "readLEFloat32 cannot read past the end of the stream")

        return uint32ToFloat32(readLEUInt32())
    end

    --- Reads a little-endian Float64 from the stream.
    local function readLEFloat64()
        assert(pointer+7 <= byteCount, "readLEFloat32 cannot read past the end of the stream")

        local int2 = readLEUInt32() -- Little-endian means that `int2` is technically most significant
        local int1 = readLEUInt32()

        local sign = bit32.btest(int1, 0x80000000)
        local exponent = bit32.band(bit32.rshift(int1, 20), 0x7ff)
        local mantissa = bit32.band(int1, 0xfffff)*0x100000000+int2

        if exponent == 0x7ff then
            if mantissa == 0 then
                return sign and -math.huge or math.huge
            else
                return 0/0
            end
        elseif exponent == 0 then
            if mantissa == 0 then
                return 0
            else
                return sign and -math.ldexp(mantissa/0x10000000000000, -1022) or math.ldexp(mantissa/0x10000000000000, -1022)
            end
        else
            mantissa = (mantissa/0x10000000000000)+1
            return sign and -math.ldexp(mantissa, exponent-1023) or math.ldexp(mantissa, exponent-1023)
        end
    end

    --- Reads a little-endian Roblox style Float32 from the stream.
    local function readRbxFloat()
        assert(pointer+3 <= byteCount, "readRbxFloat cannot read past the end of the stream")

        return uint32ToFloat32(bit32.rrotate(readLEUInt32(), 1))
    end

    --- Reads a length-prefixed string from the stream. The length is expected to be a little-endian UInt32.
    local function readString()
        assert(pointer+3 <= byteCount, "readString cannot read past the end of the stream")

        local len = readLEUInt32()

        assert(pointer+len-1 <= byteCount, "readString cannot read past the end of the stream")
        local endPointer = pointer+len-1
        local output = {}

        local c = 1
        for i = pointer, endPointer, 4096 do
            output[c] = string.char(table.unpack(bytes, i, math.min(endPointer, i+4095)))
            c = c+1
        end

        pointer = endPointer+1

        return table.concat(output, "")
    end

    --- Reads a set-length string from the stream.
    local function readSetLengthString(length)
        assert(pointer+length-1 <= byteCount, "readString cannot read past the end of the stream")

        local endPointer = pointer+length-1
        local output = {}

        local c = 1
        for i = pointer, endPointer, 4096 do
            output[c] = string.char(table.unpack(bytes, i, math.min(endPointer, i+4095)))
            c = c+1
        end

        pointer = endPointer+1

        return table.concat(output, "")
    end

    --- Reads an interleaved array of big-endian integers that are all `size` bytes.
    --- The array is `count` entries long. No transformations are applied to the returned values.
    local function readInterleavedUInt(count, size)
        assert(pointer+(count*size)-1 <= byteCount, "readInterleavedUInt cannot read past the end of the stream")

        local output = {}

        pointer = pointer-1 -- This feels like something of a sin but the alternatives are a bit gross

        size = size-1 -- This is just so that there's not an extra `count` ops per function call.
        for i = 1, count do
            local int = 0
            for k = 0, size do
                int = (int*256)+bytes[pointer+i+count*k] -- Manually shifting since `size` is arbitrary
            end
            output[i] = int
        end

        pointer = pointer+(count*size)+count+1

        return output
    end

    --- Reads an interleaved array of little-endian integers that are all `size` bytes.
    --- The array is `count` entries long. No transformations are applied to the returned values.
    local function readInterleavedLEUInt(count, size)
        assert(pointer+(count*size)-1 <= byteCount, "readInterleavedLEUInt cannot read past the end of the stream")

        local output = {}

        pointer = pointer-1

        size = size-1
        for i = 1, count do
            local int = 0
            for k = size, 0, -1 do
                int = (int*256)+bytes[pointer+i+count*k]
            end
            output[i] = int
        end

        pointer = pointer+(count*size)+count+1

        return output
    end

    --- Reads an interleaved array of little-endian Roblox style floats.
    local function readInterleavedRbxFloat32(count)
        local values = readInterleavedUInt(count, 4)

        local actualValues = {}
        for i, v in ipairs(values) do
            actualValues[i] = uint32ToFloat32(bit32.rrotate(v, 1))
        end

        return actualValues
    end

    local function readReferents(count)
        local referentArray = readInterleavedUInt(count, 4)

        local last = 0
        for i, v in ipairs(referentArray) do
            last = last+untransformInteger(v)
            referentArray[i] = last
        end

        return referentArray
    end

    return {
        dumpString = dumpString,
        dumpBinary = dumpBinary,
        dumpHex = dumpHex,

        getPointer = getPointer,
        setPointer = setPointer,
        setPointerFromEnd = setPointerFromEnd,
        getLength = getLength,
        isFinished = isFinished,

        consumeStream = consumeStream,

        writeByte = writeByte,

        writeLEUInt16 = writeLEUInt16,
        writeLEUInt32 = writeLEUInt32,

        writeLEInt32 = writeLEInt32,

        writeLEFloat32 = writeLEFloat32,
        writeLEFloat64 = writeLEFloat64,
        writeRbxFloat = writeRbxFloat,

        writeString = writeString,
        writeSetLengthString = writeSetLengthString,

        writeInterleavedUInt = writeInterleavedUInt,
        writeInterleavedLEUInt = writeInterleavedLEUInt,
        writeInterleavedRbxFloat32 = writeInterleavedRbxFloat32,

        writeReferents = writeReferents,


        readByte = readByte,

        readLEUInt16 = readLEUInt16,
        readLEUInt32 = readLEUInt32,

        readLEInt32 = readLEInt32,

        readLEFloat32 = readLEFloat32,
        readLEFloat64 = readLEFloat64,
        readRbxFloat = readRbxFloat,

        readString = readString,
        readSetLengthString = readSetLengthString,

        readInterleavedUInt = readInterleavedUInt,
        readInterleavedLEUInt = readInterleavedLEUInt,
        readInterleavedRbxFloat32 = readInterleavedRbxFloat32,

        readReferents = readReferents,
    }
end

-- local stream = constructor("\x7f\x80\x00\x00\x00\x00\x00\x00\x7e\x81\x00\x40\x00\x00\x00\x01\x7c\x89\x40\x4e\x00\x40\x00\x00")
-- print(stream.dumpHex())

-- local refs = stream.readInterleavedRbxFloat32(3)
-- print(table.unpack(refs))

return constructor