--!strict

-- Written by CHATGPT
-- Supervised by Waynely

-- Leveling library using geometric sequences and series

local LevelCalc = {}
local Class = {}
Class.__index = Class
LevelCalc.Class = Class

function LevelCalc.new(StartingLevel: number, BaseXP: number, GrowthRate: number, MaxLevel: number)
	assert(GrowthRate > 1, `GrowthRate must be greater than 1 (got {GrowthRate})`)
	local self = {
		STARTING_LEVEL = StartingLevel;
		BASE_XP = BaseXP;
		GROWTH_RATE = GrowthRate;
		DEFAULT_MAX_LEVEL = MaxLevel;
	}
	
	return setmetatable(self, Class)
end

export type Class = typeof(LevelCalc.new())

-- =========================
-- CONFIGURATION
-- =========================

-- =========================
-- XP REQUIRED FOR ONE LEVEL
-- =========================
-- XP needed to go from currentLevel -> currentLevel + 1
function Class.xpToNextLevel(self: Class, currentLevel: number, max_level: number?): number?
	assert(currentLevel >= self.STARTING_LEVEL, "Level must be >= STARTING_LEVEL")
	
	if currentLevel >= (max_level or self.DEFAULT_MAX_LEVEL) then
		return nil
	end

	return self.BASE_XP * (self.GROWTH_RATE ^ (currentLevel - self.STARTING_LEVEL))
end

-- =========================
-- TOTAL XP REQUIRED TO REACH A LEVEL
-- =========================
-- Total XP required to reach the START of queryLevel
-- (i.e. level self.STARTING_LEVEL => 0 XP)
function Class.totalXpForLevel(self: Class, queryLevel: number, max_level: number?): number?
	assert(queryLevel >= self.STARTING_LEVEL, "Level must be >= self.STARTING_LEVEL")

	if queryLevel == self.STARTING_LEVEL then
		return 0
	end
	
	if queryLevel > (max_level or self.DEFAULT_MAX_LEVEL) then
		return nil
	end

	-- Sum of geometric series:
	-- a( r^n - 1 ) / (r - 1)
	local a = self.BASE_XP
	local r = self.GROWTH_RATE
	local n = queryLevel - self.STARTING_LEVEL

	return a * ((r ^ n - 1) / (r - 1))
end

-- =========================
-- GET LEVEL FROM TOTAL XP
-- =========================
-- Returns:
-- level (number)
-- levelXP (number) progress into that level
function Class.getLevel(self: Class, totalXP: number, max_level: number?): (number, number)
	assert(totalXP >= 0, "totalXP must be >= 0")

	if totalXP == 0 then
		return self.STARTING_LEVEL, 0
	end

	local a = self.BASE_XP
	local r = self.GROWTH_RATE

	-- Invert geometric series:
	-- totalXP = a (r^n - 1) / (r - 1)
	-- r^n = (totalXP (r - 1) / a) + 1
	local n = math.log((totalXP * (r - 1)) / a + 1, r)

	-- n = levels completed
	local completedLevelCount = math.floor(n)
	local level = math.min(completedLevelCount + self.STARTING_LEVEL, (max_level or self.DEFAULT_MAX_LEVEL))

	-- level <= MAX_LEVEL, so Class.totalXpForLevel return value is not nil
	local levelXP = totalXP - self:totalXpForLevel(level, max_level):: number

	return level, levelXP
end

return LevelCalc
