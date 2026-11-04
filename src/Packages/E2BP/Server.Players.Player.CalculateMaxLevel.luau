local MaxLevel = require(game.ServerScriptService.Root.MaxLevel)


return function(player: Player)
	
	MaxLevel.getMaxLevel(player)
	MaxLevel.getMaxSkillLevel(player)
end