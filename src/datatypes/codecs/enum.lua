local datatype = {}

datatype.name = "Enum"
datatype.id = 0x12

function datatype.default()
    return 0
end

function datatype.reader(stream, count)
    local tokens = stream.readInterleavedUInt(count, 4)

    return tokens
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
