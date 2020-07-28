local makeVector2 = require("rbx_lua_types").Vector2.new

local datatype = {}

datatype.name = "Vector2"
datatype.id = 0x0d

function datatype.default()
    return makeVector2(0, 0)
end

function datatype.reader(stream, count)
    local xArray = stream.readInterleavedRbxFloat32(count)
    local yArray = stream.readInterleavedRbxFloat32(count)

    local vectorArray = {}
    for i = 1, count do
        vectorArray[i] = makeVector2(xArray[i], yArray[i])
    end

    return vectorArray
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype