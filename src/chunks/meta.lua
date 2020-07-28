local Stream = require("stream")

local mt = {}

function mt:__tostring()
    local str = {}
    for k, v in pairs(self) do
        str[#str+1] = string.format("    %s = %s", k, v)
    end
    return table.concat(str, "    \n")
end

local chunk = {}

function chunk.decode(chunk)
    local stream = Stream(chunk.data)

    local arrayLen = stream.readLEUInt32()
    local metadata = {}

    for i = 1, arrayLen do
        local key = stream.readString()
        local value = stream.readString()

        metadata[key] = value
    end

    return setmetatable(metadata, mt)
end

function chunk.encode(metadata)
    print("META chunk")
    local stream = Stream()

    local metadataLength = 0
    for _ in pairs(metadata) do
        metadataLength = metadataLength+1
    end

    stream.writeLEUInt32(metadataLength)
    for k, v in pairs(metadata) do
        stream.writeString(k)
        stream.writeString(v)
    end

    return stream
end

return chunk