local Entities = require(game.ServerScriptService.Root.World.Entities)
local StatusEffects = require(game.ServerScriptService.Root.StatusEffects)
local CombatStats = require(game.ServerScriptService.Root.World.Entities.CombatStats)
export type Packet = {percent: number, add: number, effects: {{string | number}}}

return function(owner: Entities.CustomHumanoid?, AttackResult: {[Model]: Packet})
	for M, info in AttackResult do
		
		local h = Entities.getHumanoid(M)
		
		if h then
			if info.effects then
				for _, effect in info.effects do
					StatusEffects.setEffect(h, table.unpack(effect))
				end
			end
			local heal = h.combat_stats.MaxHealth * (info.percent or 0) + (info.add or 0)
			Entities.rawHealPacket(owner, h, heal)
		end
	end
end
