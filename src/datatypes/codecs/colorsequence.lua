local makeColorSequence = require("rbx_lua_types").ColorSequence.new
local makeColor3 = require("rbx_lua_types").Color3.new

local datatype = {}

datatype.name = "ColorSequence"
datatype.id = 0x16

function datatype.default()
    return makeColorSequence({
        {Time = 0, Value = makeColor3(0, 0, 0)},
        {Time = 1, Value = makeColor3(0, 0, 0)},
    })
end

function datatype.reader(stream, count)
    local sequences = {}

    for i = 1, count do
        local numKeypoints = stream.readLEUInt32()
        local keypoints = {}
        for l = 1, numKeypoints do
            local time = stream.readLEFloat32()
            local r = stream.readLEFloat32()
            local g = stream.readLEFloat32()
            local b = stream.readLEFloat32()

            stream.readLEUInt32() -- Envelope is stored even though it's not used in ColorSequences.

            keypoints[l] = {
                Time = time,
                Value = makeColor3(r, g, b),
            }
        end
        sequences[i] = makeColorSequence(keypoints)
    end

    return sequences
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
