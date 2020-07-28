local datatype = {}

datatype.name = "Referent"
datatype.id = 0x13

function datatype.default()
    return -1
end

function datatype.reader(stream, count)
    local referents = stream.readReferents(count)

    return referents
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
