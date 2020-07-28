local Stream = require("stream")

local DataTypes = require("datatypes")

local mt = {}

function mt:__tostring()
    local entryStrings = {}
    for i, v in ipairs(self.entries) do
        entryStrings[i] = tostring(v)
    end
    return string.format([=[
    INST CHUNK: %i
    PROP NAME: %s
    TYPE: %s (0x%02x)
    DATA (%i):
      [ %s ]]=],
    self.instanceId, self.name, DataTypes.fromId[self.type].name, self.type, #self.entries, table.concat(entryStrings, ", "))
end

local chunk = {}

function chunk.decode(chunk, file)
    local stream = Stream(chunk.data)

    local instanceId = stream.readLEUInt32()
    local propertyName = stream.readString()
    local typeId = stream.readByte()

    local instanceTable = file.instances[instanceId]
    if not instanceTable then
        error(string.format("malformed file: PROP chunk %i.%s reads from invalid INST chunk", instanceId, propertyName), 2)
    end
    local count = instanceTable.count

    local dataType = DataTypes.fromId[typeId] --todo come up with better name for `dataType`

    local entries = dataType.reader(stream, count, file)
    if not entries or #entries ~= count then
        error(string.format("malformed file: had difficulties reading PROP chunk %s.%s", instanceTable.name, propertyName), 2)
    end

    return setmetatable({
        instanceId = instanceId,
        name = propertyName,
        type = typeId,
        entries = entries,
        _chunk = chunk,
        _inst = instanceTable,
    }, mt)
end

function chunk.encode(instId, propName, propType, propData)
    print(string.format("PROP #%i Name: %s Refs: %i Type: %s", instId, propName, #propData, propType))
    local stream = Stream()

    local dataType = DataTypes.fromString[string.lower(propType)]

    stream.writeLEUInt32(instId)
    stream.writeString(propName)

    stream.writeByte(dataType.id)

    dataType.writer(stream, propData)

    return stream
end

return chunk