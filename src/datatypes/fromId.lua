local types = {
    -- [0x00] = require("datatypes.codecs.unknown"),
    [0x01] = require("datatypes.codecs.string"),
    [0x02] = require("datatypes.codecs.boolean"),
    [0x03] = require("datatypes.codecs.int32"),
    [0x04] = require("datatypes.codecs.float32"),
    [0x05] = require("datatypes.codecs.float64"),
    [0x06] = require("datatypes.codecs.udim"),
    [0x07] = require("datatypes.codecs.udim2"),
    [0x08] = require("datatypes.codecs.ray"),
    -- [0x09] = require("datatypes.codecs.faces"),
    -- [0x0a] = require("datatypes.codecs.axes"),
    [0x0b] = require("datatypes.codecs.brickcolor"),
    [0x0c] = require("datatypes.codecs.color3"),
    [0x0d] = require("datatypes.codecs.vector2"),
    [0x0e] = require("datatypes.codecs.vector3"),
    -- [0x0f] = require("datatypes.codecs.unknown"),
    [0x10] = require("datatypes.codecs.cframe"),
    -- [0x11] = require("datatypes.codecs.quaternion"),
    [0x12] = require("datatypes.codecs.enum"), -- token
    [0x13] = require("datatypes.codecs.referent"),
    -- [0x14] = require("datatypes.codecs.vector3int16"),
    [0x15] = require("datatypes.codecs.numbersequence"),
    [0x16] = require("datatypes.codecs.colorsequence"),
    [0x17] = require("datatypes.codecs.numberrange"),
    [0x18] = require("datatypes.codecs.rect"),
    [0x19] = require("datatypes.codecs.physicalproperties"),
    [0x1a] = require("datatypes.codecs.color3uint8"),
    [0x1b] = require("datatypes.codecs.int64"),
    [0x1c] = require("datatypes.codecs.sharedstring"),
    [0x1d] = require("datatypes.codecs.bytecode"),
    [0x1e] = require("datatypes.codecs.cframe")
}

setmetatable(types, {
    __index = function(_, index)
        error(string.format("type `%02x` is either unknown or not implemented", index), 2)
    end,
})

return types