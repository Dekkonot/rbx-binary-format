local Util = require("util")

local typeof = Util.typeof

local mt = {}
mt.__type = "ColorSequenceKeypoint"

function mt:__tostring()
    return string.format("%g = %s", self.Time, tostring(self.Value))
end

function mt:__eq(other)
    return self.Time == other.Time and self.Value == other.Value
end

function mt:__index(index)
    error(string.format("%s is not a valid member of ColorSequenceKeypoint", tostring(index)), 2)
end

--- Creates a new `ColorSequenceKeypoint` out of the arguments.
local function new(time, value)
    assert(type(time) == "number", "arg #1 to ColorSequenceKeypoint.new must be a number")
    assert(typeof(value) == "Color3", "arg #2 to ColorSequenceKeypoint.new must be a Color3")

    local self = {}

    self.Time = time
    self.Value = value

    setmetatable(self, mt)

    return self
end

return {
    new = new,
}