local makeColor3 = require("rbx_lua_types").Color3.new

local datatype = {}

datatype.name = "Color3"
datatype.id = 0x0c

function datatype.default()
    return makeColor3(0, 0, 0)
end

function datatype.reader(stream, count)
    local rComponents = stream.readInterleavedRbxFloat32(count)
    local gComponents = stream.readInterleavedRbxFloat32(count)
    local bComponents = stream.readInterleavedRbxFloat32(count)

    local colors = {}
    for i = 1, count do
        colors[i] = makeColor3(rComponents[i], gComponents[i], bComponents[i])
    end

    return colors
end

function datatype.writer(stream, values)
    local rComponents = {}
    local gComponents = {}
    local bComponents = {}

    for i, v in ipairs(values) do
        rComponents[i] = v.R
        gComponents[i] = v.G
        bComponents[i] = v.B
    end

    stream.writeInterleavedRbxFloat32(rComponents)
    stream.writeInterleavedRbxFloat32(gComponents)
    stream.writeInterleavedRbxFloat32(bComponents)
end

return datatype
