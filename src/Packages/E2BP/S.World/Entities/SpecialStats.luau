--!strict
-- data structure used for accounting for special situations during hit packets

local Class = {}
Class.__index = Class

local SpecialStats = {}
SpecialStats.Class = Class

function SpecialStats.new(shield: number?)
	local self = setmetatable({
		shieldActive = shield;
		Immune = nil;
		skills = nil;
	}, Class)

	return self
end

export type Stats = {
	shieldActive: boolean?;
	Immune: boolean?;
	skills: {[string]: number}?;
}

return SpecialStats