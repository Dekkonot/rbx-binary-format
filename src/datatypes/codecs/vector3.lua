local makeVector3 = require("rbx_lua_types").Vector3.new

local datatype = {}

datatype.name = "Vector3"
datatype.id = 0x0e

function datatype.default()
    return makeVector3(0, 0, 0)
end

function datatype.reader(stream, count)
    local xArray = stream.readInterleavedRbxFloat32(count)
    local yArray = stream.readInterleavedRbxFloat32(count)
    local zArray = stream.readInterleavedRbxFloat32(count)

    local vectorArray = {}
    for i = 1, count do
        vectorArray[i] = makeVector3(xArray[i], yArray[i], zArray[i])
    end

    return vectorArray
end

function datatype.writer(stream, values)
    local xArray = {}
    local yArray = {}
    local zArray = {}

    for i, v in ipairs(values) do
        xArray[i] = v.X
        yArray[i] = v.Y
        zArray[i] = v.Z
    end

    stream.writeInterleavedRbxFloat32(xArray)
    stream.writeInterleavedRbxFloat32(yArray)
    stream.writeInterleavedRbxFloat32(zArray)
end

return datatype