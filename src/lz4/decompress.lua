local Stream = require("stream")
local DEBUG = false

local MIN_MATCH = 4

local function debug(...)
    if DEBUG then
        print(...)
    end
end

local function decompress(inputStream, decompressedSize)
    local outputStream = Stream()

    -- sequences
    local lastWrittenByte = 0
    while outputStream.getLength() < decompressedSize do
        -- Read the token and get the literal length
        local token = inputStream.readByte()
        local literalLen = bit32.rshift(token, 4)

        if literalLen == 0xf then -- Get the actual literal length
            repeat
                local lastByte = inputStream.readByte()
                literalLen = literalLen+lastByte
            until lastByte ~= 0xff
        end
        debug("Literal Len:", literalLen)

        -- Copy literals from input to output
        local literals = {}
        for i = 1, literalLen do
            lastWrittenByte = inputStream.readByte()
            outputStream.writeByte(lastWrittenByte)
            literals[i] = string.format("%02x", lastWrittenByte)
        end
        debug("Literal Bytes:")
        debug("[", table.concat(literals, " "), "]")

        -- If this was the final block, exit
        if outputStream.getLength() == decompressedSize then --todo come up with more elegant way of account for last segment
            break
        end

        -- Get the offset
        local offset = inputStream.readLEUInt16()

        debug("Offset:", offset)

        -- Get the match length
        local matchLen = bit32.band(token, 0xf)

        -- Get the actual match length
        if matchLen == 0xf then
            repeat
                local lastByte = inputStream.readByte()
                matchLen = matchLen+lastByte
            until lastByte ~= 0xff
        end
        matchLen = matchLen+MIN_MATCH -- Add 4 to it

        debug("Match Len:", matchLen)

        debug("pre-offset pointer:", outputStream.getPointer())
        outputStream.setPointerFromEnd(offset) -- Move the buffer back by offset bytes

        debug("post-offset pointer:", outputStream.getPointer())

        -- copy over match bytes from the output buffer
        local match = {}
        for i = 1, matchLen do
            local byte = outputStream.readByte()
            outputStream.writeByte(byte)
            match[i] = string.format("%02x", byte)
        end

        debug("Copied Bytes:")
        debug("[", table.concat(match, " "), "]")
    end

    return outputStream.dumpString()
end

if DEBUG then
    local file = "\xFF\x0E\x02\x00\x00\x00\x04\x00\x00\x00\x4E\x61\x6D\x65\x01\x0C\x00\x00\x00\x42\x6F\x64\x79\x50\x6F\x73\x69\x74\x69\x6F\x6E\x10\x00\x18\x50\x69\x74\x69\x6F\x6E"

    local decompressed = decompress(Stream(file), 77)

    assert(decompressed == "\x02\x00\x00\x00\x04\x00\x00\x00\x4E\x61\x6D\x65\x01\x0C\x00\x00\x00\x42\x6F\x64\x79\x50\x6F\x73\x69\x74\x69\x6F\x6E\x0C\x00\x00\x00\x42\x6F\x64\x79\x50\x6F\x73\x69\x74\x69\x6F\x6E\x0C\x00\x00\x00\x42\x6F\x64\x79\x50\x6F\x73\x69\x74\x69\x6F\x6E\x0C\x00\x00\x00\x42\x6F\x64\x79\x50\x6F\x73\x69\x74\x69\x6F\x6E")
end

return decompress