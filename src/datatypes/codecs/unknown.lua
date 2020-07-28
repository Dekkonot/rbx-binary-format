local datatype = {}

datatype.name = "Unknown"

function datatype.default()
    return "Default Datatype"
end

function datatype.reader(stream, count)
    error("reader is not yet implemented for type `"..datatype.name.."`", 2)
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
