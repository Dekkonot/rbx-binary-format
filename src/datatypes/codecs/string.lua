local datatype = {}

datatype.name = "string"
datatype.id = 0x01

function datatype.default()
    return ""
end

function datatype.reader(stream, count)
    local stringArray = {}
    for i = 1, count do
        stringArray[i] = stream.readString()
    end

    return stringArray
end

function datatype.writer(stream, values)
    -- error("writer is not yet implemented for type `"..datatype.name.."`", 2)

    for _, v in ipairs(values) do
        stream.writeString(v)
    end
end

return datatype