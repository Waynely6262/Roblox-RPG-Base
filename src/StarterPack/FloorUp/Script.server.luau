local profiles = require(game.ServerScriptService.Root.Players.Profiles)
local world = require(game.ServerScriptService.Root.World)
local e = game.ReplicatedStorage.Remotes.MainE
script.Parent.Activated:Connect(function()
	local player = game.Players:GetPlayerFromCharacter(script.Parent.Parent)
	e:FireClient(player, "load", true, "Loading floor " .. (profiles[player].Data.Instant.Floor - 1))
	world.teleportPlayer(player, profiles[player].Data.Instant.Floor - 1)
	e:FireClient(player, "load", false)
end)