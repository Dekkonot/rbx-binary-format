local makeBrickColor = require("rbx_lua_types").BrickColor.new

local datatype = {}

datatype.name = "BrickColor"
datatype.id = 0x0b

function datatype.default()
    return makeBrickColor(0)
end

function datatype.reader(stream, count)
    local values = stream.readInterleavedUInt(count, 4)

    local brickColors = {}
    for i, v in ipairs(values) do
        brickColors[i] = makeBrickColor(v)
    end

    return brickColors
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
