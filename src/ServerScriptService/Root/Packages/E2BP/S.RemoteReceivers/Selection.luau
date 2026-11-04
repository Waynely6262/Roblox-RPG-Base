--!strict
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local OptimalTarget = require(game.ServerScriptService.Root.Other.OptimalTarget)
local Teams = require(game.ServerScriptService.Root.Other.Teams)

local ValidFolder = Teams.get("Entities"):getFolder()

local Selections: {[Player]: Model} = {}

Players.PlayerRemoving:Connect(function(player)
	Selections[player] = nil
end)

RunService.Heartbeat:Connect(function()
	
	for player, selection in Selections do
		
		if not selection:IsDescendantOf(ValidFolder) then
			Selections[player] = nil
			continue
		end
		
		if player.Character then
			
			task.defer(OptimalTarget,player.Character, selection)
			
		end
	end
	
	
end)


return {
	onInvoke = function(player: Player, selection: Model?)
		Selections[player] = selection
	end
}