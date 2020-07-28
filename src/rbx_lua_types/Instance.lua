local Util = require("util")

local WEAK_VALUE_MT = Util.WEAK_VALUE_MT
local READ_ONLY_MT = Util.READ_ONLY_MT

local refNumber = 0

local mt = {}
mt.__type = "Instance"

function mt:__tostring()
    return self.Properties.Name or string.format("<Instance %i>", self.Ref)
end

function mt:__eq(other)
    return self.Ref == other.Ref
end

local members = {}

function mt:__index(index)
    if members[index] then
        return members[index]
    else
        error(string.format("%s is not a valid member of %s", tostring(index), self.ClassName), 2)
    end
end

function members:addProperty(propName, propValue)
    assert(type(propName) == "string", "property names must be strings")

    rawset(self.Properties, propName, propValue)

    return self
end

function members:addProperties(props)
    local properties = self.Properties

    for k, v in pairs(props) do
        assert(type(k) == "string", "property names must be strings")

        rawset(properties, k, v)
    end

    return self
end

function members:addChild(child)
    assert(getmetatable(child) == mt, "children must be Instances")

    child.Parent = self
    self.Children[child.Ref] = child

    return self
end

function members:addChildren(kinder)
    local children = self.Children

    for i, v in ipairs(kinder) do
        assert(getmetatable(v) == mt, "children must be Instances")

        v.Parent = self
        children[v.Ref] = v
    end

    return self
end

function members:getChildren()
    local kinder = {}

    for _, v in pairs(self.Children) do
        kinder[#kinder+1] = v
    end

    return kinder
end

function members:removeChild(child)
    self.Children[child.Ref] = nil
end

function members:removeChildren(kinder)
    local children = self.Children

    for _, v in ipairs(kinder) do
        children[v.Ref] = nil
    end
end

local nullClass = setmetatable({
    Parent = nil,
    Properties = setmetatable({}, READ_ONLY_MT),
    Children = {},
    Ref = -1,
    ClassName = "NULL",
}, mt)
nullClass.Parent = nullClass

--- Takes a ClassName and returns a new Instance of that class.
local function new(class, ref)
    assert(type(class) == "string", "arg #1 to Instance constructor should be a string")

    local self = {}

    self.Parent = nullClass
    self.Properties = setmetatable({}, READ_ONLY_MT)
    self.Children = {}
    self.Ref = ref or refNumber
    self.ClassName = class -- It's not meaningful to have ClassName in `Properties` but it's still helpful to keep track of.

    setmetatable(self, mt)

    if not ref then
        refNumber = refNumber+1
    end

    return self
end

return {
    new = new,
}