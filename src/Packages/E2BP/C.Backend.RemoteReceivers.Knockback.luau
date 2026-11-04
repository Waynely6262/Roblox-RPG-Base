local Player = game:GetService("Players").LocalPlayer

local function getHRP(): BasePart
	local c = Player.Character
	if c then
		return c:FindFirstChild("HumanoidRootPart")
	end
end


local knockbacks = require(game.ReplicatedStorage.Modules.Game.KnockbackTypes)

return {
	onInvoke = function(sourceType: string, ...)
		
		knockbacks[sourceType](assert(getHRP(), "couldn't perform move instruction because no root part found"), ...)
	end,
	
	_aliases = {
		"kb";
		"move";
	}
}