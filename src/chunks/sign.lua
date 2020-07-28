local Stream = require("stream")

local byte_to_hex = {}
for i = 0, 0xff do
    byte_to_hex[i] = string.format("%02x", i)
end

local function stringToHex(str)
    local bytes = {}
    for i = 1, #str do
        bytes[i] = byte_to_hex[string.byte(str, i, i)]
    end

    return table.concat(bytes)
end

local mt = {}

function mt:__tostring()
    local str = {}
    for i, v in ipairs(self) do
        str[i] = string.format("    %s", stringToHex(v))
    end
    return table.concat(str, "    \n")
end

local chunk = {}

function chunk.decode(chunk)
    local stream = Stream(chunk.data)

    local arrayLen = stream.readLEUInt32()
    local signatures = {}

    for i = 1, arrayLen do
        stream.readSetLengthString(4) -- Reserved space (?)

        local index = stream.readLEUInt32()

        stream.readSetLengthString(4) -- Reserved space again!

        local contents = stream.readRbxString()

        signatures[index] = contents
    end

    for i = 1, arrayLen do
        if not signatures[i] then
            error(string.format("no signature present for index %i", i), 2)
        end
    end

    return setmetatable(signatures, mt)
end

function chunk.encode()
    error("encoder for SIGN chunks is not yet implemented")
end

return chunk