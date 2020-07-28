local UDim = require("datatypes.UDim")

local mt = {}
mt.__type = "UDim2"

function mt:__tostring()
    return string.format("%s, %s", tostring(self.X), tostring(self.Y) )
end

function mt:__eq(other)
    return self.X == other.X and self.Y == other.Y
end

function mt:__index(index)
    error(string.format("%s is not a valid member of UDim2", tostring(index)), 2)
end

--- Creates a new `UDim2` out of the arguments.
local function new(xScale, xOffset, yScale, yOffset)
    assert(type(xScale) == "number", "arg #1 to UDim2.new should be a number")
    assert(type(xOffset) == "number", "arg #2 to UDim2.new should be a number")
    assert(type(yScale) == "number", "arg #3 to UDim2.new should be a number")
    assert(type(yOffset) == "number", "arg #4 to UDim2.new should be a number")
    assert(xOffset%1 == 0, "argument #2 to UDim2.new should be an integer")
    assert(yOffset%1 == 0, "argument #4 to UDim2.new should be an integer")

    local self = {}

    self.X = UDim.new(xScale, xOffset)
    self.Y = UDim.new(yScale, yOffset)

    setmetatable(self, mt)

    return self
end

return {
    new = new,
}