local datatype = {}

datatype.name = "ByteCode"
datatype.id = 0x1d

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
    -- I like the implication that I'll ever implement a writer for Luau bytecode
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
