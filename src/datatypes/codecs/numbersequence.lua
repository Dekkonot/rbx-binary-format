local makeNumberSequence = require("rbx_lua_types").NumberSequence.new
local makeNumberSequenceKeypoint = require("rbx_lua_types").NumberSequenceKeypoint.new

local datatype = {}

datatype.name = "NumberSequence"
datatype.id = 0x15

function datatype.default()
    return makeNumberSequence({
        {Time = 0, Value = 0, Envelope = 0},
        {Time = 1, Value = 0, Envelope = 0},
    })
end

function datatype.reader(stream, count)
    local sequences = {}

    for i = 1, count do
        local numKeypoints = stream.readLEUInt32()
        local keypoints = {}
        for l = 1, numKeypoints do
            local time = stream.readLEFloat32()
            local value = stream.readLEFloat32()
            local envelope = stream.readLEFloat32()

            keypoints[l] = makeNumberSequenceKeypoint(time, value, envelope)
        end
        sequences[i] = makeNumberSequence(keypoints)
    end

    return sequences
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
