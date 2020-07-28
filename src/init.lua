_G.MODULE_NAME = ...

package.path = string.format("%s/?.lua;%s/?/init.lua;", MODULE_NAME, MODULE_NAME)..package.path

local reader = require("reader")
local writer = require("writer")

return {
    reader = reader,
    writer = writer,
}