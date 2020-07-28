local makeCFrame = require("rbx_lua_types").CFrame.new
local makeVector3 = require("rbx_lua_types").Vector3.new

local orientIdToMatrix = {
    [0x02] = { 1, 0, 0, 0, 1, 0, 0, 0, 1},
    [0x03] = { 1, 0, 0, 0, 0, -1, 0, 1, 0 },
    [0x05] = { 1, 0, 0, 0, -1, 0, 0, 0, -1 },
    [0x06] = { 1, 0, -0, 0, 0, 1, 0, -1, 0 },
    [0x07] = { 0, 1, 0, 1, 0, 0, 0, 0, -1 },
    [0x09] = { 0, 0, 1, 1, 0, 0, 0, 1, 0 },
    [0x0a] = { 0, -1, 0, 1, 0, -0, 0, 0, 1 },
    [0x0c] = { 0, 0, -1, 1, 0, 0, 0, -1, 0 },
    [0x0d] = { 0, 1, 0, 0, 0, 1, 1, 0, 0 },
    [0x0e] = { 0, 0, -1, 0, 1, 0, 1, 0, 0 },
    [0x10] = { 0, -1, 0, 0, 0, -1, 1, 0, 0 },
    [0x11] = { 0, 0, 1, 0, -1, 0, 1, 0, -0 },
    [0x14] = { -1, 0, 0, 0, 1, 0, 0, 0, -1 },
    [0x15] = { -1, 0, 0, 0, 0, 1, 0, 1, -0 },
    [0x17] = { -1, 0, 0, 0, -1, 0, 0, 0, 1 },
    [0x18] = { -1, 0, -0, 0, 0, -1, 0, -1, -0 },
    [0x19] = { 0, 1, -0, -1, 0, 0, 0, 0, 1 },
    [0x1b] = { 0, 0, -1, -1, 0, 0, 0, 1, 0 },
    [0x1c] = { 0, -1, -0, -1, 0, -0, 0, 0, -1 },
    [0x1e] = { 0, 0, 1, -1, 0, 0, 0, -1, 0 },
    [0x1f] = { 0, 1, 0, 0, 0, -1, -1, 0, 0 },
    [0x20] = { 0, 0, 1, 0, 1, -0, -1, 0, 0 },
    [0x22] = { 0, -1, 0, 0, 0, 1, -1, 0, 0 },
    [0x23] = { 0, 0, -1, 0, -1, -0, -1, 0, -0 },
}

local datatype = {}

datatype.name = "CFrame"
datatype.id = 0x10

function datatype.default()
    return makeCFrame(
        0, 0, 0,
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    )
end

function datatype.reader(stream, count)
    local cframeArray = {}
    local rotationArrays = {}

    for i = 1, count do
        local id = stream.readByte() -- todo check what Studio does when byte is out of bound

        local rX, rY, rZ
        local uX, uY, uZ
        local lX, lY, lZ

        if id == 0 then
            rX, rY, rZ = stream.readLEFloat32(), stream.readLEFloat32(), stream.readLEFloat32()
            uX, uY, uZ = stream.readLEFloat32(), stream.readLEFloat32(), stream.readLEFloat32()
            lX, lY, lZ = stream.readLEFloat32(), stream.readLEFloat32(), stream.readLEFloat32()
        else
            local matrix = orientIdToMatrix[id]
            if not matrix then
                error("invalid orientation id '"..tostring(id).."'", 2)
            end
            rX, rY, rZ = matrix[1], matrix[2], matrix[3]
            uX, uY, uZ = matrix[4], matrix[5], matrix[6]
            lX, lY, lZ = matrix[7], matrix[8], matrix[9]
        end
        rotationArrays[i] = {rX, rY, rZ, uX, uY, uZ, lX, lY, lZ}
    end
    local xPositions =  stream.readInterleavedRbxFloat32(count)
    local yPositions =  stream.readInterleavedRbxFloat32(count)
    local zPositions =  stream.readInterleavedRbxFloat32(count)
    for i, rotations in ipairs(rotationArrays) do
        cframeArray[i] = makeCFrame(
            xPositions[i], yPositions[i], zPositions[i],
            rotations[1], rotations[2], rotations[3],
            rotations[4], rotations[5], rotations[6],
            rotations[7], rotations[8], rotations[9]
        )
    end

    return cframeArray
end

function datatype.writer(stream, values)
    error("writer is not yet implemented for type `"..datatype.name.."`", 2)
end

return datatype
