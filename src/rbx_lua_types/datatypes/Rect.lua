local Util = require("util")

local typeof = Util.typeof

local mt = {}
mt.__type = "Rect"

function mt:__tostring()
    return string.format("%s, %s", tostring(self.Min), tostring(self.Max) )
end

function mt:__eq(other)
    return self.Min == other.Min and self.Max == other.Max
end

function mt:__index(index)
    error(string.format("%s is not a valid member of Rect", tostring(index)), 2)
end

--- Creates a new `Rect` out of the arguments.
local function new(min, max)
    assert(typeof(min) == "Vector2", "arg #1 to Rect.new should be a Vector2")
    assert(typeof(max) == "Vector2", "arg #2 to Rect.new should be a Vector2")

    local self = {}

    self.Min = min
    self.Max = max

    setmetatable(self, mt)

    return self
end

return {
    new = new,
}