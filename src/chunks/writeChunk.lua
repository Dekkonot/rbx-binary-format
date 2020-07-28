local lz4 = require("lz4")
local compress = lz4.compress

local function writeChunk(stream, name, chunk)
    if #name ~= 4 then
        name = name..string.rep("\0", 4-#name)
    end

    stream.writeSetLengthString(name)

    local compressedData = compress(chunk)

    if compressedData.getLength() >= chunk.getLength() then
        stream.writeLEUInt32(0)
        stream.writeLEUInt32(chunk.getLength())
        stream.writeSetLengthString("\x00\x00\x00\x00")
        stream.writeSetLengthString(chunk.dumpString())
    else
        stream.writeLEUInt32(compressedData.getLength())
        stream.writeLEUInt32(chunk.getLength())
        stream.writeSetLengthString("\x00\x00\x00\x00")
        stream.writeSetLengthString(compressedData.dumpString())
    end
end

return writeChunk