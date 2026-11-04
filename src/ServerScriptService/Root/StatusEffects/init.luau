--!strict
local Players = game:GetService("Players")

local vars = require(script.Parent.Players.vars)
local Entities = require(script.Parent.World.Entities)
local StatsModifier = require(game.ServerScriptService.Root.World.Entities.CombatStatsModifier)

local Effect = require(script.Effect)
local f = {}

local HumanoidEffects = setmetatable({}, {__mode = "k"})

local effectHandlers: {
	[string]: (chum: any, Effect.Effect) -> ()
} = {
	
	fire = function(chum: any, data: Effect.Effect)
		task.defer(function()
			while task.wait(1 / data.lv) and os.clock() < data.t1 do
				Entities.rawDamagePacket(nil, chum, 1)
			end
		end)
		
		return
		
	end,
	
	regen = function(chum: any, data: Effect.Effect)
		task.defer(function()
			while task.wait(1) and os.clock() < data.t1 do
				Entities.rawHealPacket(nil, chum, data.lv * 2)
			end
		end)
		
	end,
	
	immune = function(chum: any, data: Effect.Effect)
	end,
	
	infamous = function(chum: any, data: Effect.Effect)
		
		task.defer(function()
			
			while task.wait(2) and os.clock() < data.t1 do
				
				local timeLeft = math.clamp(data.t1 - os.clock(), 1, 1000)
				local debuff = 1 / timeLeft
				local modifier = StatsModifier.new(nil, debuff, nil, debuff, nil, 1 - math.log10(timeLeft), nil, nil, nil, nil)
				chum:setMultipliedStats("infamy", modifier)
			end
			if f.hasEffect(chum, "infamous") then return end -- if the effect is still present, then exit because a newer handler is active
			
			-- reset the modifier
			
			chum:setMultipliedStats("infamy", nil)
			
		end)
		
		
	end,
	
}

function f.setEffect(chum: any, effectName: string, duration: number, lv: number?, incrementIfPresent: boolean?, maximumIncrementDuration: number?)
	lv = lv or 1
	
	if f.hasEffect(chum, effectName, lv + 1) then print("did not overwrite because higher level is present") return end -- if a higher level of the effect is present, then abort
	
	local existingData = chum.effects[effectName]
	
	-- end the old existing effect
	
	if existingData then
		
		if incrementIfPresent and existingData.lv == lv and existingData:isActive() then
			existingData:addDuration(duration, maximumIncrementDuration)
			
			chum:ifPlayer(function(player)
				vars.longset(player, "effects", effectName, existingData)
			end)
			return
		else
			
			existingData:clear()
		end
	end
	
	
	
	
	local effectData = Effect.new(duration, lv)
	
	chum:ifPlayer(function(player)
		vars.longset(player, "effects", effectName, effectData)
	end)
	
	chum.effects[effectName] = effectData
	
	if effectHandlers[effectName] then
		effectHandlers[effectName](chum, effectData)
	end
end

function f.hasEffect(chum: any, effectName: string, reqlv: number?): boolean
	
	local effectData = chum.effects[effectName]
	
	if not effectData then return false end
	
	local isEffectLevelSufficient = (not reqlv) or reqlv <= effectData.lv
	
	return isEffectLevelSufficient and effectData:isActive()
end

function f.clearEffect(chum: any, effectName: string)
	
	if chum.effects[effectName] then
		chum.effects[effectName]:clear()
		chum.effects[effectName] = nil
	end
	
	chum:ifPlayer(function(player)
		vars.longclear(player, "effects", effectName)
	end)
end

function f.clearAllEffects(chum: any)
	
	for name, data in chum.effects do
		data:clear()
		chum.effects[name] = nil
	end
	chum:ifPlayer(function(player)
		vars.longset(player, "effects", {})
	end)
end

return f