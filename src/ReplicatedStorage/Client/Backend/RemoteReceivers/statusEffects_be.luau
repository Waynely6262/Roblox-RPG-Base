--!strict

local Root = game.ReplicatedStorage.Client

local vars = require(Root.Backend.RemoteReceivers.vars)

local Graphics = require(game.ReplicatedStorage.Client.Graphics.statusEffects)

vars.longsetted:Connect(function(motherKey, key, value)
	if motherKey ~= "effects" then return end


	-- Originally, before implementing "longclear" function, the purpose was to clear status effects by longsetting as nil.
	-- This is no longer the case however. Only use this information in case any issues occur.
	
	if key then
		if value then
			Graphics.setStatusEffect(key, value.t, value.lv)
		else
			Graphics.clearStatusEffect(key)
		end
	else
		Graphics.clearAllEffects()
	end
	
end)

vars.longcleared:Connect(function(motherKey, key)
	if motherKey ~= "effects" then return end
	Graphics.clearStatusEffect(key)
end)

return {
	onInvoke = Graphics.setStatusEffect
}