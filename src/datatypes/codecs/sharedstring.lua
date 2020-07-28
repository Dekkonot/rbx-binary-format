local datatype = {}

datatype.name = "SharedString"
datatype.id = 0x1c

function datatype.default()
    return ""
end

function datatype.reader(stream, count, file)
    local sharedStrings = file.sharedStrings

    if not sharedStrings then
        error("malformed file: SSTR chunk is either missing or after PROP chunk that reads from it", 2)
    end

    local indices = stream.readInterleavedUInt(count, 4)

    local strings = {}
    for i, v in ipairs(indices) do
        if not sharedStrings[v] then
            error(string.format("malformed file: PROP chunk references invalid SSTR entry `%i`", i), 2)
        end
        strings[i] = sharedStrings[v]
    end

    return strings
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
