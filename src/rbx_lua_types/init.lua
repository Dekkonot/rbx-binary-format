--HOME: https://github.com/dekkonot/rbx-lua-types
package.path = string.format("%s/rbx_lua_types/?.lua;%s/rbx_lua_types/?/init.lua;", MODULE_NAME, MODULE_NAME)..package.path
-- I hate Lua's module system

local Util = require("util")

return {
    typeof = Util.typeof,
    Instance = require("Instance"),
    Vector3 = require("datatypes.Vector3"),
    Vector2 = require("datatypes.Vector2"),
    CFrame = require("datatypes.CFrame"),
    Color3 = require("datatypes.Color3"),
    BrickColor = require("datatypes.BrickColor"),
    Ray = require("datatypes.Ray"),
    Region3 = require("datatypes.Region3"),
    Rect = require("datatypes.Rect"),
    UDim = require("datatypes.UDim"),
    UDim2 = require("datatypes.UDim2"),
    NumberRange = require("datatypes.NumberRange"),
    NumberSequenceKeypoint = require("datatypes.NumberSequenceKeypoint"),
    NumberSequence = require("datatypes.NumberSequence"),
    ColorSequenceKeypoint = require("datatypes.ColorSequenceKeypoint"),
    ColorSequence = require("datatypes.ColorSequence"),
    Faces = require("datatypes.Faces"),
    Axes = require("datatypes.Axes"),
    Vector3int16 = require("datatypes.Vector3int16"),
    PhysicalProperties = require("datatypes.PhysicalProperties"),
}