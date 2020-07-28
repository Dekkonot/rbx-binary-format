local datatype = {}

datatype.name = "float64"
datatype.id = 0x05

function datatype.default()
    return 0
end

function datatype.reader(stream, count)
    local floats = {}

    for i = 1, count do
        floats[i] = stream.readLEFloat64()
    end

    return floats
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
