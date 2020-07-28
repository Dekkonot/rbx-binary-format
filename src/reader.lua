local DEBUG = false

local Stream = require("stream")
local chunks = require("chunks")

local makeInstance = require("rbx_lua_types.Instance").new

local MAGIC_NUMBER = "<roblox!\x89\xff\x0d\x0a\x1a\x0a"
local END_CHUNK_CONTENT = "</roblox>"
local VERSION_SUPPORT = {
    [0x0000] = true
}

local function reader(content)
    local stream = Stream(content)

    local magicHeader = stream.readSetLengthString(#MAGIC_NUMBER)
    if magicHeader ~= MAGIC_NUMBER then -- The scope argument of `error` is too helpful to pass up
        error("malformed file: magic number is wrong", 2)
    end
    local version = stream.readLEUInt16()
    if not VERSION_SUPPORT[version] then
        error("file version is not supported: expected version 0, got version "..tostring(version), 2)
    end

    local instanceTypeCount = stream.readLEUInt32()
    local headerInstanceCount = stream.readLEUInt32()

    for _ = 1, 8 do -- there are 8 reserved bytes that can be ignored.
        stream.readByte()
    end

    local file = {
        header = {
            version = version,
            typeCount = instanceTypeCount,
            instanceCount = headerInstanceCount,
        },
        metadata = nil,
        sharedStrings = nil,

        instances = {},
        properties = {},

        signatures = nil,
        parentMap = nil,

        referents = {},
        tree = {},
    }

    local readInstanceCount = 0

    if DEBUG then
        print("VERSION:", version)
        print("INST TYPE #:", instanceTypeCount)
        print("INST #:", headerInstanceCount)
    end

    while true do
        local rawChunk = chunks.readChunk(stream) -- Read the raw chunk and decompress it
        local chunkName = rawChunk.name

        if DEBUG then
            io.open("chunkData/debug.lz4", "wb"):write(rawChunk.data):close() -- Write it to the debug file
            print(rawChunk) -- Print the header info for the chunk
        end

        if chunkName == "INST" then
            local chunk = chunks.inst.decode(rawChunk)

            for _, ref in ipairs(chunk.referents) do
                if file.referents[ref] then
                    error(string.format("malformed file: duplicate referent %i", ref), 2)
                end
                file.referents[ref] = makeInstance(chunk.name, ref)
            end

            readInstanceCount = readInstanceCount+chunk.count
            file.instances[chunk.id] = chunk

            if DEBUG then
                print(chunk)
                io.open("chunkData/inst/inst"..chunk.id..".lz4", "wb"):write(rawChunk.data):close()
            end
        elseif chunkName == "PROP" then
            local chunk = chunks.prop.decode(rawChunk, file)

            local propTable = file.properties[chunk.instanceId]

            for i, ref in ipairs(file.instances[chunk.instanceId].referents) do
                file.referents[ref]:addProperty(chunk.name, chunk.entries[i])
            end
            if not propTable then
                propTable = {}
                file.properties[chunk.instanceId] = propTable
            end
            propTable[#propTable+1] = chunk

            if DEBUG then
                print(chunk)
                io.open("chunkData/prop/prop"..chunk.instanceId..chunk.name..".lz4", "wb"):write(rawChunk.data):close()
            end
        elseif chunkName == "PRNT" then
            if file.parentMap then
                error("malformed file: multiple PRNT chunks", 2)
            end
            local chunk = chunks.prnt.decode(rawChunk, file)

            for child, parent in pairs(chunk) do
                if parent == -1 then
                    file.tree[#file.tree+1] = file.referents[child]
                else
                    file.referents[parent]:addChild(file.referents[child])
                end
            end
            file.parentMap = chunk

            if DEBUG then
                print(chunk)
                io.open("chunkData/prnt.lz4", "wb"):write(rawChunk.data):close()
            end
        elseif chunkName == "META" then
            if file.metadata then
                error("malformed file: multiple META chunks", 2)
            end

            file.metadata = chunks.meta.decode(rawChunk)

            if DEBUG then
                print(file.metadata)
                io.open("chunkData/meta.lz4", "wb"):write(rawChunk.data):close()
            end
        elseif chunkName == "SSTR" then
            if file.sharedStrings then
                error("malformed file: multiple SSTR chunks", 2)
            end

            file.sharedStrings = chunks.sstr.decode(rawChunk)

            if DEBUG then
                print(file.sharedStrings)
                io.open("chunkData/sstr.lz4", "wb"):write(rawChunk.data):close()
            end
        elseif chunkName == "SIGN" then
            if file.signatures then
                error("malformed file: multiple SIGN chunks", 2)
            end

            file.signatures = chunks.sign.decode(rawChunk)

            if DEBUG then
                print(file.signatures)
                io.open("chunkData/sign.lz4", "wb"):write(rawChunk.data):close()
            end
        elseif chunkName == "END\0" then
            if rawChunk.data ~= END_CHUNK_CONTENT then
                error("malformed file: END chunk is incorrect", 2)
            end
            if DEBUG then
                print(string.format("    %s", END_CHUNK_CONTENT))
            end
            break
        else
            error( --todo come up with better solution to this lol
                string.format("malformed file: unknown chunk type '%s' (%02x %02x %02x %02x)",
                    chunkName,
                    string.byte(chunkName, 1, 4)
                ), 2
            )
        end
    end

    if not file.parentMap then
        error("malformed file: missing PRNT chunk", 2)
    end

    if readInstanceCount ~= headerInstanceCount then
        error("malformed file: INST chunks and header have conflicting instance counts", 2)
    end

    return file
end

return reader