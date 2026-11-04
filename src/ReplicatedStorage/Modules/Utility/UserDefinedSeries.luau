--!strict
-- User-defined sequence based leveling system
-- Same API shape as the geometric/arithmetic versions

-- Written by Grok
-- Supervised by Waynely

local LevelCalc = {}
local Class = {}
Class.__index = Class
LevelCalc.Class = Class

function LevelCalc.new(StartingLevel: number, XpSequence: {number})
	assert(#XpSequence > 0, "XpSequence must not be empty")
	local self = {
		STARTING_LEVEL   = StartingLevel;
		XP_SEQUENCE      = XpSequence;
		DEFAULT_MAX_LEVEL = #XpSequence;
		cumulativeSums   = {}:: {number};               -- [n] → sum of first n terms
		lastCached       = 0;                -- highest n for which cumulativeSums[n] is valid
	}
	return setmetatable(self, Class)
end

export type Class = typeof(LevelCalc.new(0, {}))

-- Local helper for large n: cumulative sum with caching (fills intermediates)
local function getCachedTotal(self: Class, n: number): number
	if n <= self.lastCached then
		return self.cumulativeSums[n]
	end

	-- Fill from lastCached + 1 → n
	local sum = self.lastCached == 0 and 0 or self.cumulativeSums[self.lastCached]

	for i = self.lastCached + 1, n do
		sum += self.XP_SEQUENCE[i]
		self.cumulativeSums[i] = sum
	end

	self.lastCached = n
	return sum
end

-- Local helper for large maxSteps: binary search, leveraging totalXpForLevel (which caches if needed)
local function findLevelLarge(self: Class, totalXP: number, effectiveMax: number): (number, number)
	local low = 0
	local high = effectiveMax - self.STARTING_LEVEL
	local seqLength = #self.XP_SEQUENCE
	high = math.min(high, seqLength)
	while low < high do
		local mid = math.floor((low + high + 1) / 2)
		local cum = self:totalXpForLevel(self.STARTING_LEVEL + mid)
		if cum == nil then
			high = mid - 1
			continue
		end
		if cum <= totalXP then
			low = mid
		else
			high = mid - 1
		end
	end
	local k = low
	local level = self.STARTING_LEVEL + k
	local cum = if k == 0 then 0 else self:totalXpForLevel(level) :: number
	local levelXP = totalXP - cum
	return level, levelXP
end

-- =========================
-- XP REQUIRED FOR ONE LEVEL
-- =========================
-- XP needed to go from currentLevel -> currentLevel + 1
function Class.xpToNextLevel(self: Class, currentLevel: number, max_level: number?): number?
	assert(currentLevel >= self.STARTING_LEVEL, "Level must be >= STARTING_LEVEL")
	if currentLevel >= (max_level or self.DEFAULT_MAX_LEVEL) then
		return nil
	end
	local idx = currentLevel - self.STARTING_LEVEL + 1
	if idx > #self.XP_SEQUENCE or idx < 1 then
		return nil
	end
	return self.XP_SEQUENCE[idx]
end

-- =========================
-- TOTAL XP REQUIRED TO REACH A LEVEL
-- =========================
-- Total XP required to reach the START of queryLevel
-- (i.e. level self.STARTING_LEVEL => 0 XP)
function Class.totalXpForLevel(self: Class, queryLevel: number, max_level: number?): number?
	assert(queryLevel >= self.STARTING_LEVEL, "Level must be >= STARTING_LEVEL")
	if queryLevel == self.STARTING_LEVEL then
		return 0
	end
	local n = queryLevel - self.STARTING_LEVEL
	local effectiveMax = max_level or self.DEFAULT_MAX_LEVEL
	if n < 1 or queryLevel > effectiveMax or n > #self.XP_SEQUENCE then
		return nil
	end
	return getCachedTotal(self, n)
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
	local effectiveMax = max_level or self.DEFAULT_MAX_LEVEL
	local maxSteps = effectiveMax - self.STARTING_LEVEL
	
	return findLevelLarge(self, totalXP, effectiveMax)
end

return LevelCalc