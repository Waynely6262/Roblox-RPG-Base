local EasingFunctions = require(game.ReplicatedStorage.Modules.Utility.EasingFunctions)
local Tween = require(game.ReplicatedStorage.Modules.Utility.Tween)

return function(part: BasePart, final_properties: {[string]: any}, easing: string, duration: number)

	local f = EasingFunctions[easing]

	Tween(part, final_properties, f, duration, function()
		part:Destroy()
	end)
end