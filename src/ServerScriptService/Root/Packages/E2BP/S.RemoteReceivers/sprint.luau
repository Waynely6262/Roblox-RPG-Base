local Entities = require(game.ServerScriptService.Root.World.Entities)
local E = game.ReplicatedStorage.Remotes.MainE



return {
	onInvoke = function(player: Player)
		local chum = Entities.getHumanoid(player)
		if chum then
			chum:setMultipliedStats("sprint", if chum._mul_stats_modifiers.sprint then
				nil else {WalkSpeed = 1.5}
			)
		end
	end,
}