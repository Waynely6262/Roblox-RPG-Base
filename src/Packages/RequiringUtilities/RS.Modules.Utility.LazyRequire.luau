--!strict

-- Only certain modules are eligible to require lazily:
-- Modules that don't actively do things on their own (such as making script connections like heartbeat)
local function lazy_require(v)
	warn(`{v:GetFullName()} was required under lazy conditions by {debug.info(2, "s")}`)
	local cache: any = nil	
	local function resolve()
		cache = require(v)
	end

	-- Checking cache == nil is valid because ff cache is nil, then the requiring code should expect it to be nil, and therefore it would never be accessed.
	local t = {}
	return setmetatable(t, {
		__index = function(_, k)
			if cache == nil then
				resolve()
			end
			t[k] = cache[k]
			return cache[k]
		end,
		__newindex = function(_, k, val)
			if cache == nil then
				resolve()
			end
			rawset(t, k, val)
			cache[k] = val
		end,
		__call = function(_, ...)
			if cache == nil then
				resolve()
			end
			return cache(...)
		end,
	})
end

return lazy_require