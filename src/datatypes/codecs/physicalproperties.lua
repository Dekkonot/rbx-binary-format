local makePhysicalProperties = require("rbx_lua_types").PhysicalProperties.new

local datatype = {}

datatype.name = "PhysicalProperties"
datatype.id = 0x19

function datatype.default()
    return makePhysicalProperties()
end

function datatype.reader(stream, count)
    local physicalProperties = {}

    for i = 1, count do
        local customByte = stream.readByte()
        if customByte ~= 0 then
            physicalProperties[i] = makePhysicalProperties(
                stream.readLEFloat32(),
                stream.readLEFloat32(),
                stream.readLEFloat32(),
                stream.readLEFloat32(),
                stream.readLEFloat32()
            )
        else
            physicalProperties[i] = false
        end
    end

    return physicalProperties
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
