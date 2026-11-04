--!strict
local UserDB = require(game.ServerScriptService.Root.Utils.UserDebounce)
local Signal = require(game.ReplicatedStorage.Modules.Utility.Signal)

local Config = require(game.ReplicatedStorage.Modules.Game.Config)
local ToolConfig = require(game.ReplicatedStorage.Modules.PackageConfig.CustomTools)
local CHumanoid = require(game.ServerScriptService.Root.World.Entities)
local CombatStats = require(game.ServerScriptService.Root.World.Entities.CombatStats)
local ModifierStats = require(game.ServerScriptService.Root.World.Entities.CombatStatsModifier)
local SpatialQuery = require(game.ServerScriptService.Root.Other.MovesAsync.SpatialQuery)
local Skills = require(game.ServerScriptService.Root.Players.Skills)
local LoadAnimation = require(game.ServerScriptService.Root.Utils.LoadAnimation)

local LMB_CD = UserDB.new()

local ShieldUnblockedSignals: {[Model]: Signal.Signal<>} = {}

local function getSignal(rig: Model)
	if not ShieldUnblockedSignals[rig] then

		ShieldUnblockedSignals[rig] = Signal.new()
		rig.Destroying:Once(function()
			ShieldUnblockedSignals[rig] = nil
		end)
	end
	return ShieldUnblockedSignals[rig]
end

local f = {
	_equip = function(rig: Model, humanoid: Humanoid, tool: Model, item: any)
		local chum = assert(CHumanoid.getHumanoid(rig), `{rig.Name} equipped tool but has no chumanoid?`)
		chum:setMultipliedStats("holdShieldDebuff", ModifierStats.new(nil, nil, nil, 0.9, nil, nil, nil, nil, 0.8))
	end,

	_unequip = function(rig: Model, humanoid: Humanoid, tool: Model)
		local chum = assert(CHumanoid.getHumanoid(rig), `{rig.Name} equipped tool but has no chumanoid?`)
		chum:setMultipliedStats("holdShieldDebuff", 0)
	end,
	
	t = function(rig: Model, humanoid: Humanoid)
		
		local mySignal = getSignal(rig)
		
		local chum = assert(CHumanoid.getHumanoid(rig), `{rig.Name} equipped tool but has no chumanoid?`)
		
		
		local Track = LoadAnimation.pose(humanoid, "Shield", "block", nil)
		
		
		chum.special_stats.shieldActive = true
		chum:setMultipliedStats("blockShieldDebuff", ModifierStats.new(nil, nil, 0.2, 0.5, 0.001, 0.5, nil, 0.6, 0.7, nil))
		mySignal:Once(function()
			Track:Stop()
			chum.special_stats.shieldActive = false
			chum:setMultipliedStats("blockShieldDebuff", nil)
		end)
		
		
		
	end,
	
	f = function(rig: Model, humanoid: Humanoid)
		
		if ShieldUnblockedSignals[rig] then
			ShieldUnblockedSignals[rig]:Fire()
		end
		
	end,
}

f._unequip = f.f

return f