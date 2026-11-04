local Players = game:GetService("Players")
local Remotes = game.ReplicatedStorage.Remotes
local E = Remotes.MainE
local F = Remotes.MainF

local PlayerList : {[Player]: true} do
	PlayerList = {}
	for _, Player in Players:GetPlayers() do
		PlayerList[Player] = true
	end
end

Players.PlayerAdded:Connect(function(Player)
	PlayerList[Player] = true
end)

Players.PlayerRemoving:Connect(function(Player)
	PlayerList[Player] = nil
end)

local STREAMING_THRESHOLD = require(game.ReplicatedStorage.Modules.PackageConfig.Communications).STREAMING_THRESHOLD

local FireClientsConditional = function(f: (Player) -> (boolean), ...)
	for p, _ in PlayerList do
		if f(p) then
			E:FireClient(p, ...)
		end
	end

end

local FireTypes = {
	FireClient = function(...)
		E:FireClient(...)
	end,
	InvokeClient = function(...)
		F:InvokeClient(...)
	end,
	FireAllClients = function(...)
		E:FireAllClients(...)
	end,
	FireAllClientsExcept = function(exception, ...)
		for p, _ in PlayerList do
			if p == exception then continue end
			E:FireClient(p, ...)
		end 
	end,
	
	FireClientsIf = FireClientsConditional,
	
	StreamFireClients = function(location: Vector3, ...)
		return FireClientsConditional(function(player: Player)
			local dist = player:DistanceFromCharacter(location)
			return dist ~= 0 and dist < STREAMING_THRESHOLD
		end, ...)
	end,
	
	
	
	Event = E,
	Function = F,
}

return FireTypes