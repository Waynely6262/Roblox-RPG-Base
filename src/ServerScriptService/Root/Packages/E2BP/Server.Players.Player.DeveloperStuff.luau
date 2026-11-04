local Config = require(game.ReplicatedStorage.Modules.Game.Config)

local PlayerInventories = require(game.ServerScriptService.Root.Players.PlayerInventories)

local InvConfig = require(game.ReplicatedStorage.Modules.PackageConfig.Inventory)

if Config.IS_STUDIO then
	
	return function(player: Player)
		for thing, staticInfo in InvConfig.Catalog do
			if staticInfo.type then
				PlayerInventories.giveNewItem(player, thing, {amt = 1})
			end
		end
	end
	
end

return nil