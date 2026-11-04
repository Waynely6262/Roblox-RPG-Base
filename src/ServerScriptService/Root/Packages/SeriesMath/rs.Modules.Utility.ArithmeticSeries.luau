-- Written by Grok


-- Arithmetic progression based leveling system
-- Same API shape as the geometric version
local LevelCalc = {}
local Class = {}
Class.__index = Class
LevelCalc.Class = Class

function LevelCalc.new(StartingLevel: number, BaseXP: number, LevelIncrement: number, MaxLevel: number)
	-- LevelIncrement is the amount XP increases per level (common difference 'd')
	local self = {
		STARTING_LEVEL = StartingLevel,
		BASE_XP = BaseXP,           -- XP needed to go from STARTING_LEVEL → STARTING_LEVEL+1
		LEVEL_INCREMENT = LevelIncrement,  -- d in arithmetic sequence
		DEFAULT_MAX_LEVEL = MaxLevel,
	}
	return setmetatable(self, Class)
end

export type Class = typeof(LevelCalc.new())

-- =====================================
-- XP REQUIRED FOR ONE LEVEL
-- =====================================
-- XP needed to go from currentLevel → currentLevel + 1
function Class.xpToNextLevel(self: Class, currentLevel: number, max_level: number?): number?
	assert(currentLevel >= self.STARTING_LEVEL, "Level must be >= STARTING_LEVEL")

	local effectiveMax = max_level or self.DEFAULT_MAX_LEVEL
	if currentLevel >= effectiveMax then
		return nil
	end

	-- Arithmetic: xp_to_next = base + (level - start_level) × increment
	local steps = currentLevel - self.STARTING_LEVEL
	return self.BASE_XP + steps * self.LEVEL_INCREMENT
end

-- =====================================
-- TOTAL XP REQUIRED TO REACH A LEVEL
-- =====================================
-- Total XP required to reach the START of queryLevel
-- (i.e. level STARTING_LEVEL = 0 XP)
function Class.totalXpForLevel(self: Class, queryLevel: number, max_level: number?): number?
	assert(queryLevel >= self.STARTING_LEVEL, "Level must be >= STARTING_LEVEL")

	if queryLevel == self.STARTING_LEVEL then
		return 0
	end

	local effectiveMax = max_level or self.DEFAULT_MAX_LEVEL
	if queryLevel > effectiveMax then
		return nil
	end

	-- Number of level-ups completed to reach queryLevel
	local n = queryLevel - self.STARTING_LEVEL

	-- Arithmetic series sum: S_n = n/2 × (first + last)
	-- first = BASE_XP, last = BASE_XP + (n-1)×increment
	local first = self.BASE_XP
	local last = self.BASE_XP + (n - 1) * self.LEVEL_INCREMENT

	return n * (first + last) / 2
end

-- =====================================
-- GET LEVEL FROM TOTAL XP
-- =====================================
-- Returns: level, levelXP (progress into that level)
function Class.getLevel(self: Class, totalXP: number, max_level: number?): (number, number)
	assert(totalXP >= 0, "totalXP must be >= 0")

	if totalXP == 0 then
		return self.STARTING_LEVEL, 0
	end

	local effectiveMax = max_level or self.DEFAULT_MAX_LEVEL

	-- Using quadratic formula for arithmetic sequence
	-- total = n/2 × (2a + (n-1)d)
	-- → d n² + (2a - d) n - 2 total = 0
	local a = self.BASE_XP
	local d = self.LEVEL_INCREMENT

	-- Solve quadratic: n = [-b ± sqrt(b² - 4ac)] / 2a
	local A = d
	local B = 2 * a - d
	local C = -2 * totalXP

	local discriminant = B * B - 4 * A * C
	if discriminant < 0 then
		-- Shouldn't happen with valid positive inputs, but safety
		return effectiveMax, 0
	end

	local sqrtD = math.sqrt(discriminant)
	-- We take the positive root
	local n = (-B + sqrtD) / (2 * A)

	local completedLevels = math.floor(n)
	local level = math.min(self.STARTING_LEVEL + completedLevels, effectiveMax)

	local xpAtLevelStart = self:totalXpForLevel(level, effectiveMax) :: number
	local progress = totalXP - xpAtLevelStart

	-- Edge case: exactly at level boundary
	if progress == 0 and level < effectiveMax then
		-- already reached next level
		level = level + 1
		progress = 0
	end

	return level, progress
end

return LevelCalc