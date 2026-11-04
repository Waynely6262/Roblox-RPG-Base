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
					if mob.state ~= "roam" then
						mob:roam()
					end
				end
			end

		end)
	end
	return reconcile
end