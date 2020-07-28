local Stream = require("stream")

local VERSION_SUPPORT = {
    [0x00] = true
}

local mt = {}

function mt:__tostring()
    local links = {}
    for k, v in pairs(self) do
        links[#links+1] = string.format("%6i -> % i", v, k)
    end
    return string.format([=[
    %s]=], table.concat(links, "\n    "))
end

local chunk = {}

function chunk.decode(chunk, file)
    local stream = Stream(chunk.data)

    local headerInstanceCount = file.header.instanceCount
    local referents = file.referents

    local version = stream.readByte()
    local length = stream.readLEUInt32()

    if length ~= headerInstanceCount then
        error(string.format("malformed file: PRNT chunk and header have conflicting instance counts (%i and %i)", length, headerInstanceCount), 2)
    end

    if not VERSION_SUPPORT[version] then
        print("PRNT chunk version is unsupported; the file may be read wrong")
    end

    local hiearchy = {}

    local children = stream.readReferents(length)
    local parents = stream.readReferents(length)

    for i = 1, length do
        local child, parent = children[i], parents[i]

        if parent ~= -1 and not referents[parent] then
            error("malformed file: PRNT chunk references non-existent parent", 2)
        elseif not referents[child] then
            error("malformed file: PRNT chunk references non-existent child", 2)
        end

        if hiearchy[child] then
            error("malformed file: PRNT chunk has duplicate child", 2)
        end
        hiearchy[child] = parent
    end

    return setmetatable(hiearchy, mt)
end

function chunk.encode(relations)
    print("PRNT chunk")

    local stream = Stream()

    stream.writeByte(0x00)

    local children = {}
    local parents = {}

    local index = 1

    for child, parent in pairs(relations) do
        children[index] = child
        parents[index] = parent
        index = index+1
    end

    stream.writeLEUInt32(index-1)

    stream.writeReferents(children)
    stream.writeReferents(parents)

    return stream
end

return chunk