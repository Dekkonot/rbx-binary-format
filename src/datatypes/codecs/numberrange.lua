local makeNumberRange = require("rbx_lua_types").NumberRange.new

local datatype = {}

datatype.name = "NumberRange"
datatype.id = 0x17

function datatype.default()
    return makeNumberRange(0, 0)
end

function datatype.reader(stream, count)
    local ranges = {}

    for i = 1, count do
        ranges[i] = makeNumberRange(stream.readLEFloat32(), stream.readLEFloat32())
    end

    return ranges
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
