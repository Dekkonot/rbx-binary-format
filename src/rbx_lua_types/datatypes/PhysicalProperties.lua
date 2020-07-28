local mt = {}
mt.__type = "PhysicalProperties"

function mt:__tostring()
    return string.format("(%g, %g, %g, %g, %g)",
        self.Density, self.Friction, self.Elasticity,
        self.FrictionWeight, self.ElasticityWeight)
end

function mt:__eq(other)
    return self.Density == other.Density and self.Friction == other.Friction and self.Elasticity == other.Elasticity and
        self.FrictionWeight == other.FrictionWeight and self.ElasticityWeight == other.ElasticityWeight
end

function mt:__index(index)
    error(string.format("%s is not a valid member of PhysicalProperties", tostring(index)), 2)
end

--- Creates a new `PhysicalProperties` out of the arguments.
local function new(density, friction, elasticity, frictionWeight, elasticityWeight)
    assert(type(density) == "number", "arg #1 to PhysicalProperties.new must be a number")
    assert(type(friction) == "number", "arg #2 to PhysicalProperties.new must be a number")
    assert(type(elasticity) == "number", "arg #3 to PhysicalProperties.new must be a number")
    assert(type(frictionWeight) == "number", "arg #4 to PhysicalProperties.new must be a number")
    assert(type(elasticityWeight) == "number", "arg #5 to PhysicalProperties.new must be a number")

    local self = {}

    self.Density = density
    self.Friction = friction
    self.Elasticity = elasticity
    self.FrictionWeight = frictionWeight
    self.ElasticityWeight = elasticityWeight

    setmetatable(self, mt)

    return self
end

return {
    new = new,
}