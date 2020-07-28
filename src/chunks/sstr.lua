local Stream = require("stream")
local md5 = require("md5")

local VERSION_SUPPORT = {
    [0x00000000] = true
}

local mt = {}

function mt:__tostring()
    local hashes = {}
    for i = 0, #self do
        hashes[#hashes+1] = string.format("%02x%02x%02x%02x%02x%02x%02x%02x", string.byte(md5(self[i]), 1, 16))
    end
    return string.format([=[
    ENTRIES: %i
    HASHES: [ %s ]]=],
    #hashes, table.concat(hashes, ", "))
end

local chunk = {}

function chunk.decode(chunk)
    local stream = Stream(chunk.data)

    local version = stream.readLEUInt32()
    local hashCount = stream.readLEUInt32()

    if not VERSION_SUPPORT[version] then
        print("SSTR chunk version is unsupported; the file may be read wrong")
    end

    local hashArray = {}

    for i = 0, hashCount-1 do
        local hash = stream.readSetLengthString(16)

        local data = stream.readRbxString()

        if hash ~= md5(data) then
            error(string.format("malformed file: SSTR hash doesn't match data for entry `%i`", i), 2)
        end

        hashArray[i] = data
    end

    return setmetatable(hashArray, mt)
end

function chunk.encode()
    error("encoder for SSTR chunks is not yet implemented")
end

return chunk