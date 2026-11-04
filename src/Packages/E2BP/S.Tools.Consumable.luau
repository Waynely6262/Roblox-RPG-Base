--!strict
local UserDB = require(game.ServerScriptService.Root.Utils.UserDebounce)
local Signal = require(game.ReplicatedStorage.Modules.Utility.Signal)

local Config = require(game.ReplicatedStorage.Modules.Game.Config)
local CHumanoid = require(game.ServerScriptService.Root.World.Entities)
local Notifications = require(game.ServerScriptService.Root.Notifications)

local E = game.ReplicatedStorage.Remotes:WaitForChild("MainE"):: RemoteEvent

local Animations = require(game.ServerScriptService.Root.Utils.LoadAnimation)

local PlayerInventories = require(game.ServerScriptService.Root.Players.PlayerInventories)

local Health_Potion_CD = UserDB.new()

--TODO:Customized_Combat_stats_per_sword,create_a_{[tool]:item}_correspondence_table_and_construct_personalized_combat_stats_based_on_that

-- intention is to use weak keys mode so if the rig is destroyed then the signal reference is also removed
local UnequippedSignals = setmetatable({}:: {[Model]: Signal.Signal<>}, {__mode = "k"})

local ConsumableTypes = {
	["Health Potion"] = function(rig: Model, humanoid: Humanoid, tool: Model)
		
		local chumanoid = CHumanoid.getHumanoid(rig)
		if not chumanoid then return end
		
		return chumanoid:ifPlayer(function(player)
			local isDebounced, timeLeft = Health_Potion_CD:isDebounced(player)
			
			if isDebounced then
				Notifications.NotifyClient(player, `You need to wait {math.ceil(timeLeft:: number)} seconds before you can use this again.`, 2)
				return
			end
			
			Animations.once(humanoid, "Consumable", "drink", 1, function()
				Health_Potion_CD:addDebounced(player, 15)
				
				PlayerInventories.removeItem(player, "Health Potion", 1)
				
				CHumanoid.rawHealPacket(chumanoid, chumanoid, 100 + (chumanoid.combat_stats.MaxHealth // 100) * 10)
				
				if PlayerInventories.countOf(player, "Health Potion") == 0 then
					return "unequip", rig
				end
			end)
			
			
			
		end)
		
	end,
}

local f = {

	click = function(rig: Model, humanoid: Humanoid, tool: Model, extraInfo: any)
		return ConsumableTypes[tool:GetAttribute("OG_NAME")](rig, humanoid, tool, extraInfo)
	end,

	_equip = function(rig: Model, humanoid: Humanoid, tool: Model)
	end,

	_unequip = function(rig: Model, humanoid: Humanoid, tool: Model)
	end,



}

f.auto = f.click

return f