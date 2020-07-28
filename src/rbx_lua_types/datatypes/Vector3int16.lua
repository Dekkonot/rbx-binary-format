local mt = {}
mt.__type = "Vector3int16"

function mt:__tostring()
    return string.format("<%i, %i, %i>", self.X, self.Y, self.Z)
end

function mt:__eq(other)
    return self.X == other.X and self.Y == other.Y and self.Z == other.Z
end

function mt:__index(index)
    error(string.format("%s is not a valid member of Vector3int16", tostring(index)), 2)
end

--- Creates a new `Vector3int16` out of the arguments.
local function new(x, y, z)
    assert(type(x) == "number", "arg #1 to Vector3int16.new must be a number")
    assert(type(y) == "number", "arg #2 to Vector3int16.new must be a number")
    assert(type(z) == "number", "arg #3 to Vector3int16.new must be a number")
    assert(x%1 == 0, "arg #1 to Vector3int16.new must be an integer")
    assert(y%1 == 0, "arg #2 to Vector3int16.new must be an integer")
    assert(z%1 == 0, "arg #3 to Vector3int16.new must be an integer")

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