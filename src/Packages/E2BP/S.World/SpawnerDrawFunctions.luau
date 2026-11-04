--!strict
local Rollers = require(script.Parent.RNGRoller)

local Ores = {
	["Titanium Ore"] = 2;
	["Iron Ore"] = 10;
	["Coal Ore"] = 15;
	["Copper Ore"] = 12;
	["Tin Ore"] = 12;
	["Gold Ore"] = 1;
	["Stone"] = 64;
}

local rollOres do
	local roller = Rollers.new(Ores)
	rollOres = function()
		return roller:nextOutcome()
	end
end



local rollCaveMob: (number) -> (string) do

	local roller = Rollers.new({
		["Giant Spider"] = 1;
	})

	rollCaveMob = function(difficulty: number?)
		return roller:nextOutcome():: string
	end
end

local rollUnderworldMob: (number) -> (string) do


	local function distribution_function(x: number): number
		-- 1/x^2 + 1
		-- shifted to be centered at 0.5
		-- 1/((x-0.5)^2 + 1)
		-- expanded, then powered multiple times to exaggerate the distribution
		-- more round: (x^2 - x + 1.25)^-15
		-- more sharp: (50(x-0.5)^2 + 1))^-1
		return math.pow(x*x-x+1.25,-15)
	end

	local elements = {"A","B","C","D","E","F","G","H"}
	table.freeze(elements)
	local len = #elements
	
	local partition_size = math.min(10, len)

	local maxbegin = len - partition_size

	local roller = Rollers.new()
	for i = 1, partition_size do
		roller:addOutcome(tostring(i), distribution_function((i-0.5)/partition_size))
	end

	rollUnderworldMob = function(difficulty: number?)
		local difficulty = difficulty or 0
		local n = tonumber(roller:nextOutcome()) :: number

		-- where to begin such that the last elements are all within the roller distribution range
		-- e.g. for difficulty 100 but only 80 elements, start distributing from 70
		-- for difficulty 70, start distributing from 70
		local begin = math.min(difficulty, maxbegin)

		-- the clamping statement allows difficulty to be negative
		local result = math.clamp(begin + n, 1, len)

		return elements[result]
	end
end

local rollUnderworldStructure: () -> string do

	local UnderworldStructureRoller = Rollers.new({
		["Iron Ore"] = 1;
		["Coal Ore"] = 1;
		["Copper Ore"] = 1;
		["Tin Ore"] = 1;
		["Gold Ore"] = 1;
		["Stone"] = 1;
		["Titanium Ore"] = 1;

	})

	rollUnderworldStructure = function()
		return UnderworldStructureRoller:nextOutcome():: string
	end
end

local rollForestProp: () -> string do
	
	local ForestPropRoller = Rollers.new({
		Tree = 10,
		Stone = 1,
		Bush = 2,
	})
	
	rollForestProp = function()
		return ForestPropRoller:nextOutcome():: string
	end
end


local villagers: () -> string do
	villagers = function()	
		return "Villager"
	end
end

local guard: () -> string do
	guard = function()
		return "Guard"
	end
end

local royalGuard: () -> string do
	royalGuard = function()
		return "Royal Guard"
	end
end

local rollBush: () -> string do
	rollBush = function()	
		return "Bush"
	end
end

local rollTree: () -> string do
	rollTree = function()	
		return "Tree"
	end
end

local rollForestMob: () -> string do
	
	local ForestMobRoller = Rollers.new({
		Sheep = 1;
		Cow = 1;
		Pig = 1;
		Rat = 1;
	})
	
	rollForestMob = function()
		return ForestMobRoller:nextOutcome():: string
	end
end
local uniformAnyNPC: (any) -> () do
	
	local roller = Rollers.new()
	
	for _, v in game.ReplicatedStorage.Models.Entities:GetChildren() do
		local h = v:FindFirstChildWhichIsA('Humanoid')

		if h then
			roller:addOutcome(v.Name, 1)
		end
	end

	uniformAnyNPC = function()
		return roller:nextOutcome():: string
	end
end

local sandboxNPC do
	
	local roller = Rollers.new()
		
		
	for _, v in game.ServerScriptService.Root.World.EntityGenManager.NPC:GetChildren() do
		roller:addOutcome(v.Name, 1)
	end
	sandboxNPC = function()
		return roller:nextOutcome()
	end
end
	

local _mobs = setmetatable({
	uwNPC = rollUnderworldMob;
	forestNPC = rollForestMob;
	uniformAnyNPC = uniformAnyNPC;
	sandboxNPC = sandboxNPC;
	caveNPC = rollCaveMob;
	villagers = villagers;
}, {
	__index = function(self, k)
		self[k] = function()
			return k
		end
		print("Created an entry for", k)
		return self[k]
	end,
})

return setmetatable({
	uwProp = rollUnderworldStructure;
	forestProp = rollForestProp;
	ores = rollOres;
	_mobs = _mobs;
	
}, {__index = _mobs})