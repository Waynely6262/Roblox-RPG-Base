--!strict
local RunService = game:GetService("RunService")
local Config = require(game.ReplicatedStorage.Modules.Game.Config)
local BaseClass = require(script.Parent.Parent.NPC.Superclass)
return function(mob: BaseClass.type)

	local function reconcile(run: boolean?)

		local mainLoop: RBXScriptConnection?
		if not run then
			mob:newState(nil)
			if mainLoop then
				mainLoop:Disconnect()
				mainLoop = nil
			end
			return
		end
		if mainLoop then return end
		
		local aggravatedUntil = -Config.NPC_COMBAT_TIME
		local target: typeof(mob.chumanoid)?
		mainLoop = RunService.Heartbeat:Connect(function()
			if mob.state ~= "roam" then
				mob:roam()
			end
		end)
	end
	return reconcile
end