local UserDB = require(game.ServerScriptService.Root.Utils.UserDebounce)
local Signal = require(game.ReplicatedStorage.Modules.Utility.Signal)

local LMB_CD = UserDB.new()

-- intention is to use weak keys mode so if the rig is destroyed then the signal reference is also removed
local UnequippedSignals = setmetatable({}:: {[Model]: Signal.Signal<>}, {__mode = "k"})

return {
	
	click = function(rig: Model, humanoid: Humanoid, tool: Model, extraInfo: any)
		
		if LMB_CD:isDebounced(rig) then return end
		LMB_CD:addDebounced(rig, 3)
		
		print(`{rig.Name} clicked with {tool.Name}`)
		
		UnequippedSignals[rig] = UnequippedSignals[rig] or Signal.new()
		
		UnequippedSignals[rig]:Once(function()
			print(`click action ended for {rig.Name} because unequipped signal fired`)
		end)
	end,
	
	_equip = function(rig: Model, humanoid: Humanoid, tool: Model)
		-- humanoid:LoadAnimation(<equip_animation>):Play()
		print(`{rig.Name} equipped {tool.Name}`)
	end,
	
	_unequip = function(rig: Model, humanoid: Humanoid, tool: Model)
		-- humanoid:LoadAnimation(<unequip_animation>):Play()
		print(`{rig.Name} equipped {tool.Name}`)
		if UnequippedSignals[rig] then
			UnequippedSignals[rig]:Fire()
		end
	end,
	
	
	
}