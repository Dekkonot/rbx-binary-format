local Util = require("util")

local typeof = Util.typeof

local mt = {}
mt.__type = "NumberSequence"

function mt:__tostring()
    local keypointStrs = {}
    for i, v in ipairs(self.Keypoints) do
        keypointStrs[i] = tostring(v)
    end
    return string.format("{%s}", table.concat(keypointStrs, ", "))
end

function mt:__eq(other)
    if #self.Keypoints ~= #other.Keypoints then return false end
    for i, v in ipairs(self.Keypoints) do
        if v ~= other.Keypoints[i] then
            return false
        end
    end
    return true
end

function mt:__index(index)
    error(string.format("%s is not a valid member of NumberSequence", tostring(index)), 2)
end

--- Creates a new `NumberSequence` out of the arguments.
--- `keypoints` is not stored in the NumberSequence, but the keypoints *are*.
local function new(keypoints)
    assert(typeof(keypoints) == "table", "arg #1 to NumberSequence.new must be an array of NumberSequenceKeypoints")
    local newKeypointTable = {}
    for i, v in ipairs(keypoints) do
        if typeof(v) == "NumberSequenceKeypoint" then
            newKeypointTable[i] = v
        else
            error("arg #1 to NumberSequence.new must be an array of NumberSequenceKeypoints", 2)
        end
    end

    local self = {}

    self.Keypoints = newKeypointTable

    setmetatable(self, mt)

    return self
end

return {
    new = new,
}