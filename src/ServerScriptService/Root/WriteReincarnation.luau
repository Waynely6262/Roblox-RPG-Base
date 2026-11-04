local vars = require(game.ServerScriptService.Root.Players.vars)
local Levelling = require(game.ReplicatedStorage.Modules.Game.Levelling)
local Skills = require(game.ServerScriptService.Root.Players.Skills)

local API = {}
function API.canReincarnate(player: Player): boolean

	return Skills.getSkillLevel(player) >= 60 + API.getTotalCount(player)
end

function API.performReincarnation(player: Player): boolean

	if API.canReincarnate(player) then

		local skills = vars.get(player, "levelling")
		local reincarnations = vars.get(player, "carns")
		local playerUpgrades = vars.get(player, "upgrades")
		
		
		-- get best skill
		local bestSkill: string
		local bestXP = 0

		for name, xp in skills do
			if name == "overall" then continue end
			if reincarnations[name] and reincarnations[name] == 10 then continue end
			if xp > bestXP then
				bestSkill = name
				bestXP = xp
				skills[name] = 0
			end
		end
		
		local specificReincarnationCount = (reincarnations[bestSkill] or 0) + 1
		reincarnations[bestSkill] = specificReincarnationCount
		
		
		-- Accumulate refund
		local refund = 0
		
		for upgrade: string, level: number in playerUpgrades do
			refund += Levelling.Upgrades[upgrade]:totalXPForLevel(level)
		end
		-- Essence refund %
		local refundPercent = (playerUpgrades["Lasting Legacy"] or 0) * 0.1
		
		vars.set(player, "essence", refund * refundPercent)
		vars.set(player, "levelling", skills)
		vars.set(player, "upgrades", {})
		vars.longset(player, "carns", bestSkill, specificReincarnationCount)
		
		return true
	end
	return false
end

return API