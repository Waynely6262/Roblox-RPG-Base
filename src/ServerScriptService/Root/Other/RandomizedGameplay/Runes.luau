local Runes = {
	"Stained",
	"Glowing",
	"Humming",
	"Ancient",
	"Radiant"
}
local MaxRuneLevel = 5
local rarity_const = 100
local sqrt_rarity_const = math.sqrt(rarity_const)

local function shuffle(t)
	for i = #t, 1, -1 do
		local j = math.random(1, i)
		t[i], t[j] = t[j], t[i]
	end
end

local function max_rune(power: number)
	return math.min(MaxRuneLevel, power/rarity_const)
end

local function roll_rune_alpha(power: number)
	return math.pow(math.random(), math.max(1, rarity_const / math.sqrt(power)))
end

local function damp_power(power: number)
	return power // 2
end

local function getRunes(power: number)
	
	local levels = {}
	
	for i = 1, #Runes do
		local roll = max_rune(power) * roll_rune_alpha(power)
		power = damp_power(power)
		table.insert(levels, math.floor(roll))
	end
	shuffle(levels)
	
	
	-- order of runes being applied
	local runes = {}
	for key, name in Runes do
		runes[name] = levels[key]
	end
	return runes
end

return getRunes