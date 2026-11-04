local Remotes = game.ReplicatedStorage.Remotes


local RemoteResponses = {}

local search = require(game.ReplicatedStorage.Modules.Utility.Search)
search(script, RemoteResponses, "Server")

Remotes.MainE.OnServerEvent:Connect(function(player,remote,...) -- one-way 
	return RemoteResponses[remote](player,...)
end)

Remotes.MainF.OnServerInvoke = function(player, remote, ...) -- two-way
	return RemoteResponses[remote](player, ...)
end

return Remotes.MainE