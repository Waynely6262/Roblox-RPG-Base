local vars = require(game.ServerScriptService.Root.Players.vars)
local packageConfig = require(game.ReplicatedStorage.Modules.PackageConfig.ReplicatedVariables)

return function(player: Player, PlayerProfile: any)
	vars.setScope(player, PlayerProfile.Data[packageConfig.Key])
end
