local Entities = require(game.ServerScriptService.Root.World.Entities)
local StatusEffects = require(game.ServerScriptService.Root.StatusEffects)
local CombatStats = require(game.ServerScriptService.Root.World.Entities.CombatStats)
export type Packet = {atk_stats: CombatStats.Stats, effects: {any}?}
export type NormalPacket = {atk_stats: CombatStats.Stats}

return function(owner: Entities.CustomHumanoid?, AttackResult: {[Model]: Packet | NormalPacket} | {[Model]: Packet} | {[Model]: NormalPacket}, pos: Vector3?)
	for M, info in AttackResult do
		
		local h = Entities.getHumanoid(M)
		
		if h then
			if info.effects then
				for _, effect in info.effects do
					StatusEffects.setEffect(h, table.unpack(effect))
				end
			end
			Entities.rawHitPacket(owner, h, pos, info.atk_stats)
		end
	end
end
