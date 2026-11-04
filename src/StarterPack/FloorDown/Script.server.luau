local profiles = require(game.ServerScriptService.Root.Players.Profiles)
local world = require(game.ServerScriptService.Root.World)
local e = game.ReplicatedStorage.Remotes.MainE
script.Parent.Activated:Connect(function()
	local player = game.Players:GetPlayerFromCharacter(script.Parent.Parent)
	
	local floor = (tonumber(profiles[player].Data.Instant.Floor) or 0) + 1
	
	e:FireClient(player, "load", true, "Loading floor " .. floor)
	world.teleportPlayer(player, floor)
	e:FireClient(player, "load", false)
end)