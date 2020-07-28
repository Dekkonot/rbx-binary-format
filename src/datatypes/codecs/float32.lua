local datatype = {}

datatype.name = "float32"
datatype.id = 0x04

function datatype.default()
    return 0
end

function datatype.reader(stream, count)
    local floatArray = stream.readInterleavedRbxFloat32(count)

    return floatArray
end

function datatype.writer(stream, values)
    -- error("writer is not yet implemented for type `"..datatype.name.."`", 2)

    stream.writeInterleavedRbxFloat32(values)
end

return datatype