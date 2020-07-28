local datatype = {}

datatype.name = "boolean"
datatype.id = 0x02

function datatype.default()
    return false
end

function datatype.reader(stream, count)
    local boolArray = {}

    for i = 1, count do
        boolArray[i] = stream.readByte() == 1
    end

    return boolArray
end

function datatype.writer(stream, values)
    for _, v in ipairs(values) do
        stream.writeByte(v and 0x01 or 0x00)
    end
end

return datatype
