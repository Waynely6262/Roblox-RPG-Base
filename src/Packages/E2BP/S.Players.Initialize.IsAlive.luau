local valueBaseCreator = require(game.ServerScriptService.Root.Players.ProfileDataInstances.ValueObjectCaster)

return function(player)
	local tempFolder = valueBaseCreator("Transient", {
		IsAlive = false;
	})

	tempFolder.Parent = player
end
