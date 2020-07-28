local mt = {}
mt.__type = "Axes"

function mt:__tostring()
    return string.format("[%s, %s, %s]", tostring(self.X), tostring(self.Y), tostring(self.Z))
end

function mt:__eq(other)
    return self.X == other.X and self.Y == other.Y and self.Z == other.Z
end

function mt:__index(index)
    error(string.format("%s is not a valid member of Axes", tostring(index)), 2)
end

--- Creates a new `Axes` out of the arguments.
local function new(x, y, z)
    assert(type(x) == "boolean", "arg #1 to Axes.new must be a boolean")
    assert(type(y) == "boolean", "arg #2 to Axes.new must be a boolean")
    assert(type(z) == "boolean", "arg #3 to Axes.new must be a boolean")

    local self = {}

    self.X = x
    self.Y = y
    self.Z = z

    setmetatable(self, mt)

    return self
end

return {
    new = new,
}