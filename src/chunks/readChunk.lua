local lz4 = require("lz4")
local decompress = lz4.decompress

local mt = {}

function mt:__tostring()
    return string.format([=[
CHUNK: %s
  COMPRESSED LEN: %i
  DECOMPRESSED LEN: %i
  IS COMPRESSED: %s
  DATA (%i):]=],
    self.name, self.compressedLength, self.decompressedLength, tostring(self.isCompressed), #self.data
)
end

local function readChunk(stream)
    local chunkName = stream.readSetLengthString(4)

    local compressedLength = stream.readLEUInt32()
    local decompressedLength = stream.readLEUInt32()
    stream.readLEUInt32() -- These bytes are reserved.
    -- Maybe it should be validated, but it doesn't really hurt anything to let chunks with data there through.

    local isCompressed = compressedLength ~= 0 -- If a chunk's compression size is 0, it's either empty or not compressed

    local chunkData
    if isCompressed then
        chunkData = decompress(stream, decompressedLength)
    else
        chunkData = stream.readSetLengthString(decompressedLength)
    end

    return setmetatable({
        name = chunkName,
        compressedLength = compressedLength,
        decompressedLength = decompressedLength,
        isCompressed = isCompressed,
        data = chunkData
    }, mt)
end

return readChunk