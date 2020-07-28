local mt = {}
mt.__type = "NumberRange"

function mt:__tostring()
    return string.format("[%g, %g]", self.Min, self.Max)
end

function mt:__eq(other)
    return self.Min == other.Min and self.Max == other.Max
end

function mt:__index(index)
    error(string.format("%s is not a valid member of NumberRange", tostring(index)), 2)
end

--- Creates a new `NumberRange` out of the arguments.
local function new(min, max)
    assert(type(min) == "number", "arg #1 to NumberRange.new must be a number")
    assert(type(max) == "number", "arg #2 to NumberRange.new must be a number")

    local self = {}

    self.Min = min
    self.Max = max

    setmetatable(self, mt)

    return self
end

return {
    new = new,
}