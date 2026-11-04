-- a data structure used by the 'EntityGenManager' class to determine where to attempt to spawn entities
local Roller = require(script.Parent.RNGRoller)
local SpawnerDrawFs = require(script.Parent.SpawnerDrawFunctions)
local Spawner = {}
local Class = {}
Class.__index = Class
Spawner.Class = Class

function Spawner.new(get_f: string, x0: number?, y0: number?, x1: number?, y1: number?, max: number?)
	if get_f == "_mobs" then error("Forbidden identifier '_mobs'") end
	if not SpawnerDrawFs[get_f] then
		error(`Invalid spawner identifier: {get_f}`)
	end
	local self = {
		f = get_f;
		max = max or 1;
		count = 0;
		x0 = x0;
		y0 = y0;
		x1 = x1;
		y1 = y1;
	}
	
	return setmetatable(self, Class)
end

return Spawner