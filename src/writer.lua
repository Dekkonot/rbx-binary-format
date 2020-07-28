local Stream = require("stream")
local chunks = require("chunks")
local datatypes = require("datatypes")

local typeof = require("rbx_lua_types").typeof

local serpent = require("serpent")

local lz4 = require("lz4")
local compress = lz4.compress

local MAGIC_NUMBER = "<roblox!\x89\xff\x0d\x0a\x1a\x0a"
local END_CHUNK_CONTENT = "</roblox>"
local VERSION_SUPPORT = {
    [0x0000] = true
}

local METADATA = {
    ExplicitAutoJoints = "true",
    -- MadeBy = "rbx-binary-format", --todo check if this is a good idea (ask LPG, maybe zeux)
}

local function isInArray(tab, value)
    for _, v in ipairs(tab) do
        if v == value then
            return true
        end
    end
    return false
end

local function populateRefArrays(branch, classRefArrays, parents, refToPropertyMap)
    local refArray = classRefArrays[branch.ClassName]
    if not refArray then
        refArray = {}
        classRefArrays[branch.ClassName] = refArray
    end

    refArray[#refArray+1] = branch.Ref
    parents[branch.Ref] = branch.Parent.Ref
    refToPropertyMap[branch.Ref] = branch.Properties

    for _, child in pairs(branch.Children) do
        populateRefArrays(child, classRefArrays, parents, refToPropertyMap)
    end
end

local function writer(tree) --todo refactor
    local stream = Stream()

    local instCount = 0
    local instChunks = {}
    local propChunks = {}

    local classRefArrays = {} -- Map of arrays in the form className = [refList]
    local parents = {} -- Map of refs to their parents
    local refToPropertyMap = {} -- Map of refs to their property list
    for _, v in ipairs(tree) do
        populateRefArrays(v, classRefArrays, parents, refToPropertyMap)
    end

    local instId = 0

    for class, refs in pairs(classRefArrays) do
        instCount = instCount+#refs
        table.sort(refs)

        local propertyValueList = {} -- Map of property values in the form propName = [propValues]
        local propertyTypeList = {} -- Array of property types in the same order as classPropertyList

        local classPropertyList = {} -- Array of property names

        for _, ref in ipairs(refs) do
            for propName, propValue in pairs(refToPropertyMap[ref]) do
                if not isInArray(classPropertyList, propName) then
                    classPropertyList[#classPropertyList+1] = propName
                    propertyTypeList[#classPropertyList] = string.lower(typeof(propValue))
                end
            end
        end

        for i, name in ipairs(classPropertyList) do
            local propArray = {}
            for j, ref in ipairs(refs) do
                local properties = refToPropertyMap[ref]

                propArray[j] = properties[name] or datatypes.fromString[propertyTypeList[i]].default()
            end
            propertyValueList[name] = propArray
        end

        for i, v in ipairs(classPropertyList) do
            propChunks[#propChunks+1] = chunks.prop.encode(instId, v, propertyTypeList[i], propertyValueList[v])
        end

        instChunks[instId+1] = chunks.inst.encode(instId, class, refs)

        instId = instId+1
    end

    -- print(serpent.block(parents, {
    --     comment = false,
    --     metatostring = false,
    -- }))
    -- print(serpent.block(classRefArrays, {
    --         comment = false,
    --         metatostring = false,
    --     }))
    -- print(serpent.block(propertyList, {
    --     comment = false,
    --     metatostring = false,
    -- }))

    -- Fun bug fact: You need to process the file before writing the header because of the INST chunk count

    local meta = chunks.meta.encode(METADATA)
    local prnt = chunks.prnt.encode(parents)

    print("Writing magic number")
    stream.writeSetLengthString(MAGIC_NUMBER)
    print("Writing version: 0")
    stream.writeLEUInt16(0x0000)

    print("Writing INST chunk count:", #instChunks)
    stream.writeLEUInt32(#instChunks)
    print("Writing INST count:", instCount)
    stream.writeLEUInt32(instCount)

    print("Writing reserved bytes")
    stream.writeSetLengthString("\x00\x00\x00\x00\x00\x00\x00\x00")

    print("Writing META chunk")
    chunks.writeChunk(stream, "META", meta)

    print("Writing INST chunks")
    for _, v in ipairs(instChunks) do
        chunks.writeChunk(stream, "INST", v)
    end

    print("Writing PROP chunks")
    for _, v in ipairs(propChunks) do
        chunks.writeChunk(stream, "PROP", v)
    end

    print("Writing PRNT chunk")
    chunks.writeChunk(stream, "PRNT", prnt)

    print("Writing END chunk")
    chunks.writeChunk(stream, "END", Stream(END_CHUNK_CONTENT))

    return stream.dumpString()
end

return writer