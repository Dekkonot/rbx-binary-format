local makeRect = require("rbx_lua_types").Rect.new
local makeVector2 = require("rbx_lua_types").Vector2.new

local datatype = {}

datatype.name = "Rect"
datatype.id = 0x18

function datatype.default()
    return makeRect(0, 0, 0, 0)
end

function datatype.reader(stream, count)
    local minXs = stream.readInterleavedRbxFloat32(count)
    local minYs = stream.readInterleavedRbxFloat32(count)
    local maxXs = stream.readInterleavedRbxFloat32(count)
    local maxYs = stream.readInterleavedRbxFloat32(count)

    local udim2s = {}

    for i = 1, count do
        udim2s[i] = makeRect(makeVector2(minXs[i], minYs[i]), makeVector2(maxXs[i], maxYs[i]))
    end

    return udim2s
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
