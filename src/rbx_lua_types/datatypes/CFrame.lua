local Vector3 = require("datatypes.Vector3")

local mt = {}
mt.__type = "CFrame"

function mt:__tostring()
    return string.format("%s, %s, %s, %s",
        tostring(self.Position), tostring(self.RightVector),
        tostring(self.UpVector), tostring(self.LookVector)
    )
end

function mt:__eq(other)
    return self.Position == other.Position and self.RightVector == other.RightVector
        and self.UpVector == self.UpVector and self.LookVector == other.LookVector
end

function mt:__index(index)
    error(string.format("%s is not a valid member of CFrame", tostring(index)), 2)
end

--- Creates a new `CFrame` out of the arguments.
local function new(x, y, z, rX, rY, rZ, uX, uY, uZ, lX, lY, lZ)
    assert(type(x) == "number", "arg #1 to CFrame.new should be a number")
    assert(type(y) == "number", "arg #2 to CFrame.new should be a number")
    assert(type(z) == "number", "arg #3 to CFrame.new should be a number")
    assert(type(rX) == "number", "arg #4 to CFrame.new should be a number")
    assert(type(rY) == "number", "arg #5 to CFrame.new should be a number")
    assert(type(rZ) == "number", "arg #6 to CFrame.new should be a number")
    assert(type(uX) == "number", "arg #7 to CFrame.new should be a number")
    assert(type(uY) == "number", "arg #8 to CFrame.new should be a number")
    assert(type(uZ) == "number", "arg #9 to CFrame.new should be a number")
    assert(type(lX) == "number", "arg #10 to CFrame.new should be a number")
    assert(type(lY) == "number", "arg #11 to CFrame.new should be a number")
    assert(type(lZ) == "number", "arg #12 to CFrame.new should be a number")

    local self = {}

    self.Position = Vector3.new(x, y, z)
    self.RightVector = Vector3.new(rX, rY, rZ)
    self.UpVector = Vector3.new(uX, uY, uZ)
    self.LookVector = Vector3.new(lX, lY, lZ)

    setmetatable(self, mt)

    return self
end

return {
    new = new,
}