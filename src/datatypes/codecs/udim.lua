local makeUDim = require("rbx_lua_types").UDim.new

local function untransformInteger(n)
    -- If n%2 == 0, n/2
    -- Otherwise, -(n+1)/2
    if n%2 == 0 then
        return n/2
    else
        return -(n+1)/2
    end
end

local datatype = {}

datatype.name = "UDim"
datatype.id = 0x06

function datatype.default()
    return makeUDim(0, 0)
end

function datatype.reader(stream, count)
    local scales = stream.readInterleavedRbxFloat32(count)
    local offsets = stream.readInterleavedUInt(count, 4)

    local udims = {}

    for i = 1, count do
        udims[i] = makeUDim(scales[i], untransformInteger(offsets[i]))
    end

    return udims
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
