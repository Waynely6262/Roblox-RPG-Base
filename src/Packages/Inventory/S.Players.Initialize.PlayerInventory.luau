local PackageConfig = require(game.ReplicatedStorage.Modules.PackageConfig.Inventory)
local AccessKey = PackageConfig.ProfileAccessKey
local PlayerInventories = require(game.ServerScriptService.Root.Players.PlayerInventories)


return function(player: Player, PlayerProfile)
	PlayerInventories.loadJSON(player, PlayerProfile.Data[AccessKey])
end