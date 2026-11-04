local LocalPlayer = game:GetService("Players").LocalPlayer

local BaseEmitAPI = require(game.ReplicatedStorage.Modules.Utility.Emit)
return {
	onInvoke = function(source: Player, act, ...)
		if source == LocalPlayer then
			return
		end
		
		BaseEmitAPI[act](...)
	end
}

