--!strict
-- data structure used for applying modifiers to attacks.
-- key-ing is not strict, but it's advised to follow conventions otherwise things get M E S S Y
-- NOTE: Apply deepcloning if in the future a mutable type is added to combatstats

local Class = {}
Class.__index = Class
Class.__add = function(self: Stats, stats2: Stats | Modifier | RawModifier | number): Stats
	
	
	local result = self:clone(true)
	if typeof(stats2) == "number" then
		for i, v in self do
			result[i] += stats2:: number
		end
	else
		for i, v in stats2:: Stats | Modifier | RawModifier do
			result[i] += v
		end
	end
	
	return result:: Stats
end

Class.__sub = function(self: Stats, stats2: Stats | Modifier | RawModifier | number): Stats
	local result = self:clone(true)
	if typeof(stats2) == "number" then
		for i, v in self do
			result[i] -= stats2:: number
		end
	else
		for i, v in stats2:: Stats | Modifier | RawModifier do
			result[i] -= v
		end
	end
	return result:: Stats
end

Class.__mul = function(self: Stats, stats2: Stats | Modifier | RawModifier | number): Stats

	local result = self:clone(true)
	if typeof(stats2) == "number" then
		for i, v in self do
			result[i] *= stats2:: number
		end
	else
		for i, v in stats2:: Stats | Modifier | RawModifier do
			result[i] *= v
		end
	end
	return result:: Stats
end

Class.__div = function(self: Stats, stats2: Stats | Modifier | RawModifier | number): Stats
	
	local result = self:clone(true)
	if typeof(stats2) == "number" then
		for i, v in self do
			result[i] /= stats2:: number
		end
	else
		for i, v in stats2:: Stats | Modifier | RawModifier do
			result[i] /= v
		end
	end
		
	return result:: Stats
end

Class.__eq = function(self: Stats, stats2: Stats | Modifier| RawModifier): boolean
	
	if self == stats2 then
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

-- deepcloning isn't necessary because this class (at the point of writing this) only consists of numbers.
function Class.clone(self: Stats, mutable: boolean?): Stats
	local new = table.clone(self)
	
	if not mutable then
		new:freeze()
	end
	return new:: Stats
end

function Class.freeze(self: Stats)
	if not table.isfrozen(self:: {[any]: any}) then
		table.freeze(self:: {[any]: any})
	end
end

local CombatStats = {}
CombatStats.Class = Class

function CombatStats.new(dmg: number, def: number, hit: number, miss: number, crit: number, speed: number, pen: number, a_size: number, a_speed: number, maxhealth: number): Stats
	local self: Stats = setmetatable({
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
	return self:: Stats
end

CombatStats.one 	= CombatStats.new(1,1,1,1,1,1,1,1,1,1)
CombatStats.zero 	= CombatStats.new(0,0,0,0,0,0,0,0,0,0)





table.freeze(Class)
table.freeze(CombatStats)

export type Stats = typeof(setmetatable({}:: {
	Damage: number,
	Defense: number,

	Precision: number,
	Dodge: number,

	CritChance: number,
	Piercing: number,

	WalkSpeed: number,
	
	AttackSize: number;
	AttackSpeed: number;
	
	MaxHealth: number,

}, Class))


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
}

export type Modifier = typeof(table.freeze(setmetatable({}:: RawModifier, Class)))

return CombatStats