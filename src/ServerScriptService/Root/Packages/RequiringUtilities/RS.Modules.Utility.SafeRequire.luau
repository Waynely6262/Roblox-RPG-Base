-- must be used on ALL require scripts, otherwise some may not be detected by the InProgress table
local lazy_require = require(script.Parent.LazyRequire)

local InProgress: {[any]: boolean} = {}

local function safe_require(v)
	if InProgress[v] then
		-- We are in a require cycle (module required is currently requiring something as well) → defer
		
		return lazy_require(v)
	end

	InProgress[v] = true
	local result = require(v)
	InProgress[v] = nil

	return result
end

return safe_require