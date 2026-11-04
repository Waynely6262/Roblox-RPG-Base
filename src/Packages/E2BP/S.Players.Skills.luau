--!strict
local Root = game.ServerScriptService.Root
local vars = require(game.ServerScriptService.Root.Players.vars)
local LevelUtil = require(game.ReplicatedStorage.Modules.Game.Levelling)
local Config = require(game.ReplicatedStorage.Modules.Game.Config)
local Signal = require(game.ReplicatedStorage.Modules.Utility.Signal)
local Upgrades = require(game.ServerScriptService.Root.RemoteReceivers.Upgrades)
local MaxLevel = require(game.ServerScriptService.Root.MaxLevel)
local ReadReincarnations = require(game.ServerScriptService.Root.ReadReincarnation)

local function GetPlayerXPMultiplier(player: Player)
	local scholarLevel = Upgrades.getUpgradeLevel(player, "Scholar") or 0
	return 1 + (0.2 * scholarLevel) + (0.05 * ReadReincarnations.getTotalCount(player))
end

local LevelChangedSignal = Signal.new():: Signal.Signal<Player, string, number>

local Skills = {}

local PlayerSkills = {}:: {[Player]: {[string]: number}}

local function _getCachedResult(player: Player, skillName: string): number?
	return PlayerSkills[player] and PlayerSkills[player][skillName]
end

local function _cacheResult(player: Player, skillName: string, totalxp: number?)
	
	local cachedResult = _getCachedResult(player, skillName)
	if not totalxp and cachedResult then return end
	
	local totalxp = totalxp or vars.get(player, "levelling")[skillName:: string] or 0

	local newLevel = LevelUtil.Levels:getLevel(totalxp, skillName == "overall" and Config.MAX_OVERALL_LEVEL or Config.MAX_SKILL_LEVEL)
		
	PlayerSkills[player] = PlayerSkills[player] or {}:: {[string]: number}
	PlayerSkills[player][skillName] = newLevel
	
	if cachedResult and cachedResult == newLevel then return end
	LevelChangedSignal:Fire(player, skillName, newLevel)
	
	return 
end

function Skills.addSkillXP(player: Player, skillName: string, xp: number)
	xp = xp * GetPlayerXPMultiplier(player)
	local levelling_data = vars.get(player, "levelling"):: {[string]: number?}
	
	local oldxp = levelling_data[skillName] or 0
	local totalxp = oldxp + xp
	
	
	-- limiting xp gain
	local oldLevel = Skills.getSkillLevel(player, skillName)
	_cacheResult(player, skillName, totalxp)
	local newLevel = Skills.getSkillLevel(player, skillName)
	
	local maxSkillLevel = MaxLevel.getMaxSkillLevel(player)
	
	vars.longset(player, "levelling", skillName, totalxp)
	
	if newLevel < maxSkillLevel then
		
		local total_overall_xp = (levelling_data.overall or 0) + xp
		_cacheResult(player, "overall", total_overall_xp)
		vars.longset(player, "levelling", "overall", total_overall_xp)
		
	elseif oldLevel < maxSkillLevel then
		
		local totalForNewLevel = LevelUtil.Levels:totalXpForLevel(maxSkillLevel, maxSkillLevel):: number
		local xpPastMax = totalxp - totalForNewLevel
		
		local total_overall_xp = (levelling_data.overall or 0) + xp - xpPastMax
		_cacheResult(player, "overall", total_overall_xp)
		vars.longset(player, "levelling", "overall", total_overall_xp)
	end
end

function Skills.getSkillLevel(player: Player, skillName: string?)
	skillName = skillName or "overall"
	
	_cacheResult(player, skillName)
	return PlayerSkills[player][skillName]
end

Skills.LevelChanged = LevelChangedSignal

return Skills