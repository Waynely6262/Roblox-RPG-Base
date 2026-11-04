--!strict
local RunService = game:GetService("RunService")
local Config = require(game.ReplicatedStorage.Modules.Game.Config)
local BaseClass = require(script.Parent.Parent.NPC.Superclass)
return function(mob: BaseClass.type)
	local aggravatedUntil = -Config.NPC_COMBAT_TIME
	local target: typeof(mob.chumanoid)?
	local mainLoop: RBXScriptConnection?

	local function reconcile(run: boolean?)

		if not run then
			mob:newState(nil)
			if mainLoop then
				mainLoop:Disconnect()
				mainLoop = nil
			end
			return
		end
		if mainLoop then return end
		mainLoop = RunService.Heartbeat:Connect(function()

			if target and os.clock() < aggravatedUntil then

				target.effects.infamous:addDuration(30, 30)
				if mob:isEntityInView(target) then
					aggravatedUntil = os.clock() + Config.NPC_COMBAT_TIME
				end

			else
				local immediateEnemy = mob.chumanoid:getImmediateEnemy()
				if immediateEnemy then
					mob:attack(immediateEnemy)
					target = immediateEnemy
					aggravatedUntil = os.clock() + Config.NPC_COMBAT_TIME
				else
					
					
					local inView = mob:playersInView()
					for player, chumanoid in inView do
						if chumanoid.effects.infamous and chumanoid.effects.infamous:isActive() then
							mob:attack(chumanoid)
							target = chumanoid
							aggravatedUntil = os.clock() + Config.NPC_COMBAT_TIME
							return
						end
					end
					
					if mob.state ~= nil then
						mob:newState(nil)
					end
				end
			end

		end)
	end
	return reconcile
end