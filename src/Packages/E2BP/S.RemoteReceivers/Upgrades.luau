--!strict
local Root = game.ServerScriptService.Root
local vars = require(game.ServerScriptService.Root.Players.vars)
local LevelUtil = require(game.ReplicatedStorage.Modules.Game.Levelling)
local Config = require(game.ReplicatedStorage.Modules.Game.Config)
local Signal = require(game.ReplicatedStorage.Modules.Utility.Signal)

local LevelChangedSignal = Signal.new():: Signal.Signal<Player, string, number>

local Calculators = LevelUtil.Upgrades:: {[string]: typeof(LevelUtil.Upgrades.Scholar)} & typeof(LevelUtil.Upgrades)

local function tryUpgrade(player: Player, upgradeName: string)
	
	local essence = vars.get(player, "essence"):: number
	local currentLevel = vars.get(player, "upgrades", upgradeName):: number? or 0
	
	if not Calculators[upgradeName] then error(`{upgradeName} is not a valid upgrade`) return end
	
	local required_essence = Calculators[upgradeName]:xpToNextLevel(currentLevel)
	
	if required_essence and essence >= required_essence then
		vars.set(player, "essence", essence - required_essence)
		vars.longset(player, "upgrades", upgradeName, currentLevel + 1)
		LevelChangedSignal:Fire(player, upgradeName, currentLevel + 1)
	end
	
end

local function getUpgradeLevel(player: Player, upgradeName: string): number
	return vars.get(player, "upgrades", upgradeName) or 0
end


return {
	onInvoke = tryUpgrade,
	getUpgradeLevel = getUpgradeLevel,
	LevelChanged = LevelChangedSignal,
}