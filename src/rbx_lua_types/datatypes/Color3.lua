local mt = {}
mt.__type = "Color3"

function mt:__tostring()
    return string.format("(%g, %g, %g)", self.R, self.G, self.B)
end

function mt:__eq(other)
    return self.R == other.R and self.G == other.G and self.B == other.B
end

function mt:__index(index)
    error(string.format("%s is not a valid member of Color3", tostring(index)), 2)
end

--- Creates a new `Color3` out of the arguments. Takes fractions as its arguments.
local function new(r, g, b)
    assert(type(r) == "number", "arg #1 to Color3.new must be a number")
    assert(type(g) == "number", "arg #2 to Color3.new must be a number")
    assert(type(b) == "number", "arg #3 to Color3.new must be a number")

    local self = {}

    self.R = r
    self.G = g
    self.B = b

    setmetatable(self, mt)

    return self
end

--- Creates a new `Color3` from its arguments. Takes integers as arguments.
local function fromRGB(r, g, b)
    assert(type(r) == "number", "arg #1 to Color3.new must be a number")
    assert(type(g) == "number", "arg #2 to Color3.new must be a number")
    assert(type(b) == "number", "arg #3 to Color3.new must be a number")

    local self = {}

    self.R = r/255
    self.G = g/255
    self.B = b/255

    setmetatable(self, mt)

    return self
end

return {
    new = new,
    fromRGB = fromRGB,
}