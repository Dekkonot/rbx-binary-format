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

datatype.name = "int32"
datatype.id = 0x03

function datatype.default()
    return 0
end

function datatype.reader(stream, count)
    local intArray = stream.readInterleavedUInt(count, 4)

    for i, v in ipairs(intArray) do
        intArray[i] = untransformInteger(v)
    end

    return intArray
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype