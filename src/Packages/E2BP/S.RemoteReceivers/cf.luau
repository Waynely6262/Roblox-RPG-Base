local remotee = game.ReplicatedStorage.Remotes.MainE
return function(player, cf: CFrame)
	if typeof(cf) == "CFrame" then
		remotee:FireAllClients("cf",player, cf)
	end
end