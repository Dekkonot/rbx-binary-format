local mt = {}
mt.__type = "NumberSequenceKeypoint"

function mt:__tostring()
    return string.format("%g = %g +- %g", self.Time, self.Value, self.Envelope)
end

function mt:__eq(other)
    return self.Time == other.Time and self.Value == other.Value and self.Envelope == other.Envelope
end

function mt:__index(index)
    error(string.format("%s is not a valid member of NumberSequenceKeypoint", tostring(index)), 2)
end

--- Creates a new `NumberSequenceKeypoint` out of the arguments.
local function new(time, value, envelope)
    assert(type(time) == "number", "arg #1 to NumberSequenceKeypoint.new must be a number")
    assert(type(value) == "number", "arg #2 to NumberSequenceKeypoint.new must be a number")
    assert(type(envelope) == "number", "arg #3 to NumberSequenceKeypoint.new must be a number")

    local self = {}

    self.Time = time
    self.Value = value
    self.Envelope = envelope

    setmetatable(self, mt)

    return self
end

return {
    new = new,
}