local mt = {}
mt.__type = "Faces"

function mt:__tostring()
    return string.format("[%s, %s, %s, %s, %s, %s]",
        tostring(self.Top), tostring(self.Bottom), tostring(self.Left),
        tostring(self.Right), tostring(self.Back), tostring(self.Front)
    )
end

function mt:__eq(other)
    return self.Top == other.Top and self.Bottom == other.Bottom and self.Left == other.Left and
        self.Right == other.Right and self.Back == other.Back and self.Front == other.Front
end

function mt:__index(index)
    error(string.format("%s is not a valid member of Faces", tostring(index)), 2)
end

--- Creates a new `Faces` out of the arguments.
local function new(top, bottom, left, right, back, front)
    assert(type(top) == "boolean", "arg #1 to Faces.new must be a boolean")
    assert(type(bottom) == "boolean", "arg #2 to Faces.new must be a boolean")
    assert(type(left) == "boolean", "arg #3 to Faces.new must be a boolean")
    assert(type(right) == "boolean", "arg #4 to Faces.new must be a boolean")
    assert(type(back) == "boolean", "arg #5 to Faces.new must be a boolean")
    assert(type(front) == "boolean", "arg #6 to Faces.new must be a boolean")

    local self = {}

    self.Top = top
    self.Bottom = bottom
    self.Left = left
    self.Right = right
    self.Back = back
    self.Front = front

    setmetatable(self, mt)

    return self
end

return {
    new = new,
}