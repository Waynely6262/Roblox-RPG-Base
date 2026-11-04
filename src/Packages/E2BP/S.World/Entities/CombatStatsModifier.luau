--!strict
-- data structure used for applying modifiers to attacks.
-- key-ing is not strict, but it's advised to follow conventions otherwise things get M E S S Y
-- NOTE: Apply deepcloning if in the future a mutable type is added to ModifierStats

local Class = {}
Class.__index = Class
Class.__add = function(self: Modifier, stats2: Modifier | RawModifier | number): Modifier
	
	
	local result = self:clone(true)
	if typeof(stats2) == "number" then
		for i, v in result do
			result[i] += stats2:: number
		end
	else
		for i, v in stats2:: Modifier | RawModifier do
			local v2 = (result[i] or 0) + v
			result[i] = if v2 ~= 0 then v2 else nil
		end
	end
	
	return result
end

Class.__sub = function(self: Modifier, stats2: Modifier | RawModifier | number): Modifier
	local result = self:clone(true)
	if typeof(stats2) == "number" then
		for i, v in result do
			result[i] -= stats2:: number
		end
	else
		for i, v in stats2 do
			local v2 = (result[i] or 0) - v
			result[i] = if v2 ~= 0 then v2 else nil
		end
	end
	return result
end

Class.__mul = function(self: Modifier, stats2: Modifier | RawModifier | number): Modifier

	local result = self:clone(true)
	if typeof(stats2) == "number" then
		for i, v in result do
			result[i] *= stats2:: number
		end
	else
		for i, v in stats2 do
			local v2 = (result[i] or 1) * v
			result[i] = if v2 ~= 1 then v2 else nil
		end
	end
	return result
end

Class.__div = function(self: Modifier, stats2: Modifier | RawModifier | number): Modifier
	
	local result = self:clone(true)
	if typeof(stats2) == "number" then
		for i, v in result do
			result[i] /= stats2:: number
		end
	else
	end
	for i, v in stats2 do
		local v2 = (result[i] or 1) / v
		result[i] = if v2 ~= 1 then v2 else nil
	end
		
	return result
end

Class.__eq = function(self: Modifier, stats2: Modifier | RawModifier): boolean
	
	if rawequal(self, stats2) then
		return true
	end
	if typeof(stats2) ~= "table" then
		return false
	end
	
	local expected = {}
	
	for i, v in stats2 do
		expected[i] = v
	end
	
	for i, v in self do
		if expected[i] == v then
			expected[i] = nil
		else
			return false
		end
	end
	
	return not next(expected)
	
	
end


local CombatStats = require(script.Parent.CombatStats)
local ModifierStats = {}
ModifierStats.Class = Class
Class.__index = CombatStats.Class


function ModifierStats.new(dmg: number? ,def: number?, hit: number?, miss: number?, crit: number?, speed: number?, pen: number?, a_size: number?, a_speed: number?, maxhealth: number?): Modifier
	local self: Modifier = setmetatable({
		Damage = dmg;
		Defense = def;
		Precision = hit;
		Dodge = miss;
		CritChance = crit;
		WalkSpeed = speed;
		Piercing = pen;
		AttackSize = a_size;
		AttackSpeed = a_speed;
		MaxHealth = maxhealth;
	}, Class)

	table.freeze(self)
	return self:: Modifier
end

-- this method trusts that the programmer has only the valid keys in the passed table.
function ModifierStats.fromRaw(t: RawModifier?)
	local self = setmetatable(table.clone(t or {}), Class)
	
	return table.freeze(self:: any):: Modifier
end





table.freeze(Class)
table.freeze(ModifierStats)

export type RawModifier = {
	Damage: number?,
	Defense: number?,

	Precision: number?,
	Dodge: number?,

	CritChance: number?,
	Piercing: number?,

	WalkSpeed: number?,
	
	AttackSize: number?;
	AttackSpeed: number?;

	MaxHealth: number?,
} & {[string]: number?}

export type Modifier = typeof(table.freeze(setmetatable({}:: RawModifier, Class)))

return ModifierStats