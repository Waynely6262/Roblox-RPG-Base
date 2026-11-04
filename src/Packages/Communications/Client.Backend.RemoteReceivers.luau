local Remotes = game.ReplicatedStorage.Remotes

local RemoteResponses = {}

local search = require(game.ReplicatedStorage.Modules.Utility.Search)

search(script, RemoteResponses, "Client")


Remotes.MainE.OnClientEvent:Connect(function(remote,...)
	--return 
	if typeof(remote) == "table" then
		for _, varargs: {any} in remote do
			local key = table.remove(varargs, 1)
			RemoteResponses[key](table.unpack(varargs))
		end
	else
		RemoteResponses[remote](...)
	end
end)

Remotes.MainF.OnClientInvoke = function(remote,...)
	return RemoteResponses[remote](...)
end

return {
	E = Remotes.MainE;
	F = Remotes.MainF;
}