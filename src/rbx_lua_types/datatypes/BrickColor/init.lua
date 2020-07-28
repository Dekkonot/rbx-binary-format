local colorList = require("datatypes.BrickColor.list")

local mt = {}
mt.__type = "BrickColor"

function mt:__tostring()
    return self.Name
end

function mt:__eq(other)
    return self.Number == other.Number
end

function mt:__index(index)
    error(string.format("%s is not a valid member of BrickColor", tostring(index)), 2)
end

--- Creates a new `BrickColor`.
local function new(number)
    assert(type(number) == "number", "arg #1 to BrickColor.new must be a number")

    local self = {}

    local colorData = colorList[number]

    if not colorData then
        colorData = colorList[194]
        number = 194
    end

    self.Number = number
    self.Name = colorData[1]
    self.Color = colorData[2]

    setmetatable(self, mt)

    return self
end

return {
    new = new,
}