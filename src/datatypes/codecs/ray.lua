local makeRay = require("rbx_lua_types").Ray.new
local makeVector3 = require("rbx_lua_types").Vector3.new

local datatype = {}

datatype.name = "Ray"
datatype.id = 0x08

function datatype.default()
    return makeRay(0, 0, 0, 0, 0, 0)
end

function datatype.reader(stream, count)
    local rays = {}

    for i = 1, count do
        rays[i] = makeRay(
            makeVector3(stream.readLEFloat32(), stream.readLEFloat32(), stream.readLEFloat32()),
            makeVector3(stream.readLEFloat32(), stream.readLEFloat32(), stream.readLEFloat32())
        )
    end

    return rays
end

function datatype.writer(stream, values)
    -- error("writer is not yet implemented for type `"..datatype.name.."`", 2)

    for _, v in ipairs(values) do
        stream.writeLEFloat32(v.Origin.X)
        stream.writeLEFloat32(v.Origin.Y)
        stream.writeLEFloat32(v.Origin.Z)
        stream.writeLEFloat32(v.Direction.X)
        stream.writeLEFloat32(v.Direction.Y)
        stream.writeLEFloat32(v.Direction.Z)
    end
end

return datatype
