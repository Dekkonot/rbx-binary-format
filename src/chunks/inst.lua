local Stream = require("stream")

local mt = {}

function mt:__tostring()
    return string.format([=[
    ID: %i
    CLASS NAME: %s
    COUNT: %i
    FORMAT: %s
    REFERENTS: [ %s ]]=],
    self.id, self.name, self.count, self.format == 0 and "NORMAL" or "SERVICE", table.concat(self.referents, ", "))
end

local chunk = {}

function chunk.decode(chunk)
    local stream = Stream(chunk.data)

    local classId = stream.readLEUInt32()
    local className = stream.readString()
    local format = stream.readByte()
    local instanceCount = stream.readLEUInt32()

    local referentArray = stream.readReferents(instanceCount)

    if format ~= 0 then
        assert(stream.readSetLengthString(instanceCount) == string.rep("\1", instanceCount), "malformed file: INST chunk has invalid service marker")
    end

    return setmetatable({
        id = classId,
        name = className,
        format = format,
        count = instanceCount,
        referents = referentArray,
        _chunk = chunk
    }, mt)
end

function chunk.encode(id, className, refTable)
    print(string.format("INST #%i Name: %s Refs: %i", id, className, #refTable))
    local stream = Stream()

    stream.writeLEUInt32(id) -- INST id
    stream.writeString(className) -- class
    stream.writeByte(0) -- Service marker
    stream.writeLEUInt32(#refTable) -- Ref array length

    stream.writeReferents(refTable) -- Ref array

    --todo service marker

    return stream
end

return chunk