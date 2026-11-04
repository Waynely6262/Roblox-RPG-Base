--!strict
local vars = require(game.ServerScriptService.Root.Players.vars)

local API = {}

-- Returns how many extra levels a specific skill gets from reincarnations
-- Format: 1 reincarnation → +10 levels, 2 → +20, etc.
function API.getSkillBuff(player: Player, skillName: string): number
	if not player or not skillName then
		return 0
	end

	local carnData = vars.get(player, "carns") -- {[string]: number}
	if not carnData then
		return 0
	end

	local count = carnData[skillName] or 0
	return count * 10
end

-- Returns the total number of reincarnations the player has performed
-- (sum of all reincarnation counts across all skills)
function API.getTotalCount(player: Player): number
	if not player then
		return 0
	end

	local carnData = vars.get(player, "carns")
	if not carnData then
		return 0
	end

	local total = 0
	for _, count in carnData do
		total += count
	end

	return total
end

-- Returns the full reincarnation data table
-- Format: { ["Fishing"] = 3, ["Mining"] = 1, ["Combat"] = 5, ... }
function API.getList(player: Player): { [string]: number }
	if not player then
		return {}
	end

	local carnData = vars.get(player, "carns")
	if not carnData then
		return {}
	end

	-- Return a shallow copy to prevent accidental mutation
	local result = {}
	for skill, count in carnData do
		result[skill] = count
	end

	return result
end

-- Optional: for convenience / debugging
function API.getTotalReincarnationsFormatted(player: Player): string
	local total = API.getTotalCount(player)
	if total == 0 then
		return "No reincarnations"
	elseif total == 1 then
		return "1 reincarnation"
	else
		return total .. " reincarnations"
	end
end

return API