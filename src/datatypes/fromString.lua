local types = {
    -- unknown = require("datatypes.codecs.unknown"),
    string = require("datatypes.codecs.string"),
    boolean = require("datatypes.codecs.boolean"),
    int32 = require("datatypes.codecs.int32"),
    float32 = require("datatypes.codecs.float32"),
    float64 = require("datatypes.codecs.float64"),
    udim = require("datatypes.codecs.udim"),
    udim2 = require("datatypes.codecs.udim2"),
    ray = require("datatypes.codecs.ray"),
    -- faces = require("datatypes.codecs.faces"),
    -- axes = require("datatypes.codecs.axes"),
    brickcolor = require("datatypes.codecs.brickcolor"),
    color3 = require("datatypes.codecs.color3"),
    vector2 = require("datatypes.codecs.vector2"),
    vector3 = require("datatypes.codecs.vector3"),
    -- unknown = require("datatypes.codecs.unknown"),
    cframe = require("datatypes.codecs.cframe"),
    -- quaternion = require("datatypes.codecs.quaternion"),
    enum = require("datatypes.codecs.enum"), -- token
    referent = require("datatypes.codecs.referent"),
    -- vector3int16 = require("datatypes.codecs.vector3int16"),
    numbersequence = require("datatypes.codecs.numbersequence"),
    colorsequence = require("datatypes.codecs.colorsequence"),
    numberrange = require("datatypes.codecs.numberrange"),
    rect = require("datatypes.codecs.rect"),
    physicalproperties = require("datatypes.codecs.physicalproperties"),
    color3uint8 = require("datatypes.codecs.color3uint8"),
    int64 = require("datatypes.codecs.int64"),
    sharedstring = require("datatypes.codecs.sharedstring"),
    bytecode = require("datatypes.codecs.bytecode"),
    optionalcoordinateframe = require("datatypes.codecs.cframe")
}

setmetatable(types, {
    __index = function(_, index)
        error(string.format("type `%s` is either unknown or not implemented", index), 2)
    end,
})

return types