local makeUDim2 = require("rbx_lua_types").UDim2.new

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

datatype.name = "UDim2"
datatype.id = 0x07

function datatype.default()
    return makeUDim2(0, 0, 0, 0)
end

function datatype.reader(stream, count)
    local xScales = stream.readInterleavedRbxFloat32(count)
    local yScales = stream.readInterleavedRbxFloat32(count)
    local xOffsets = stream.readInterleavedUInt(count, 4)
    local yOffsets = stream.readInterleavedUInt(count, 4)

    local udim2s = {}

    for i = 1, count do
        udim2s[i] = makeUDim2(xScales[i], untransformInteger(xOffsets[i]), yScales[i], untransformInteger(yOffsets[i]))
    end

    return udim2s
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
