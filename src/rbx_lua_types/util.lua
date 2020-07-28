---@param thing any
---@return string type
---Acts as Roblox's `typeof` function.
local function typeof(thing)
    if type(thing) == "table" then
        if getmetatable(thing) then
            return getmetatable(thing).__type or "table"
        else
            return "table"
        end
    else
        return type(thing)
    end
end

local READ_ONLY_MT = {
    __newindex = function()
        error("attempted to write to a readonly table", 2)
    end,
}

local WEAK_VALUE_MT = { __mode = "v" }

return {
    typeof = typeof,
    READ_ONLY_MT = READ_ONLY_MT,
    WEAK_VALUE_MT = WEAK_VALUE_MT,
}