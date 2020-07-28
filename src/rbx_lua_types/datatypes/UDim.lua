local mt = {}
mt.__type = "UDim"

function mt:__tostring()
    return string.format("{%g, %i}", self.Scale, self.Offset)
end

function mt:__eq(other)
    return self.Scale == other.Scale and self.Offset == other.Offset
end

function mt:__index(index)
    error(string.format("%s is not a valid member of UDim", tostring(index)), 2)
end

--- Creates a new `UDim` out of the arguments.
local function new(scale, offset)
    assert(type(scale) == "number", "arg #1 to UDim.new must be a number")
    assert(type(offset) == "number", "arg #2 to UDim.new must be a number")
    assert(offset % 1 == 0, "arg #2 to UDim.new must be an integer")

    local self = {}

    self.Scale = scale
    self.Offset = offset

    setmetatable(self, mt)

    return self
end

return {
    new = new,
}