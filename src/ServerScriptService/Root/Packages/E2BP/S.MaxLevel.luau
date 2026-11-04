local Upgrades = require(game.ServerScriptService.Root.RemoteReceivers.Upgrades)
local vars = require(game.ServerScriptService.Root.Players.vars)
local Reincarnation = require(game.ServerScriptService.Root.ReadReincarnation)

local maxLevelCache = {}
local maxSkillLevelCache = {}

local function maxLevel(ascensions: number, reincarnations: number)
	return 60 + (ascensions * 5) + reincarnations
end

local function maxSkillLevel(level: number)
	return 10 * (level + 1)
end

-- When Ascension or Skill Mastery changes → update cache + long value
Upgrades.LevelChanged:Connect(function(player: Player, upgrade: string, level: number)
	if upgrade == "Ascension" then
		local reincarnations = Reincarnation.getTotalCount(player)

		local newMax = maxLevel(level, reincarnations)
		maxLevelCache[player] = newMax
		vars.longQuietSet(player, "maxLevel", newMax)

	elseif upgrade == "Skill Mastery" then
		local newMaxSkill = maxSkillLevel(level)
		maxSkillLevelCache[player] = newMaxSkill
		vars.longQuietSet(player, "maxSkillLevel", newMaxSkill)
	end
end)

-- Optional: clean up cache when player leaves
game.Players.PlayerRemoving:Connect(function(player)
	maxLevelCache[player] = nil
	maxSkillLevelCache[player] = nil
end)

return {
	getMaxLevel = function(player: Player): number
		-- Fast path: use cache
		if maxLevelCache[player] then
			return maxLevelCache[player]
		end

		-- Otherwise calculate it
		local ascensions = vars.get(player, "upgrades", "Ascension") or 0
		local reincarnations = Reincarnation.getTotalCount(player) or 0

		local value = maxLevel(ascensions, reincarnations)

		-- Cache it for next time
		maxLevelCache[player] = value
		
		-- This is not redundant because this block is only reached when no cached value exists.
		-- When no cached value exists, it's also likely that the client has never received
		-- the value either.
		
		-- Also update the long value if it was missing/outdated
		vars.longGhostSet(player, "maxLevel", value)

		return value
	end,

	getMaxSkillLevel = function(player: Player): number
		-- Fast path: use cache
		if maxSkillLevelCache[player] then
			return maxSkillLevelCache[player]
		end

		-- Get current mastery level
		local masteryLevel = vars.get(player, "upgrades", "Skill Mastery") or 0
		local value = maxSkillLevel(masteryLevel)

		-- Cache it
		maxSkillLevelCache[player] = value

		-- This is not redundant because this block is only reached when no cached value exists.
		-- When no cached value exists, it's also likely that the client has never received
		-- the value either.
		
		-- Make sure the long value is also set
		vars.longGhostSet(player, "maxSkillLevel", value)

		return value
	end,
}