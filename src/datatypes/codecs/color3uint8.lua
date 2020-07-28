local makeColor3 = require("rbx_lua_types").Color3.fromRGB

local datatype = {}

datatype.name = "Color3UInt8"
datatype.id = 0x1a

function datatype.default()
    return makeColor3(0, 0, 0)
end

function datatype.reader(stream, count)
    local color3uint24 = stream.readInterleavedUInt(count, 3)

    local colors = {}
    for i, v in ipairs(color3uint24) do
        colors[i] = makeColor3(bit32.rshift(v, 16)/255, bit32.band(bit32.rshift(v, 8), 255)/255, bit32.band(v, 255)/255)
    end

    return colors
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
