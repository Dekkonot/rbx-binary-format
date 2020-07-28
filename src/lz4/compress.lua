local Stream = require("stream")

local function compress(stream)
    return Stream(stream.dumpString())
end

return compress