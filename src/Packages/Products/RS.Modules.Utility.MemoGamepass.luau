--!strict
local memo: {[Player]: {[string]: boolean}} = {}

local ms = game:GetService("MarketplaceService")

local RetryAsync = require(game.ReplicatedStorage.Modules.Utility.RetryAsync)

game:GetService("Players").PlayerRemoving:Connect(function(player)
	memo[player] = nil
end)

local getGamepassMemo = function(player: Player, id: number): boolean
	
	local stringLiteral = tostring(id)
	memo[player] = memo[player] or {}
	local currentValue = memo[player][stringLiteral]
	
	-- even if currentValue exists but is false, 
	--it still needs to be checked in case the state has changed.
	-- If the value is true, it shouldn't change to false so that
	-- doesn't need to be checked.
	
	if currentValue then
		return currentValue
	else
		local s, r = RetryAsync(3, ms.UserOwnsGamePassAsync,ms, player.UserId, id)
		if s then
			memo[player][stringLiteral] = r
			return r
		else
			warn("Unable to memoize gamepass result for", player, "for id", id, "due to", r) 
			return false
		end
	end
end

ms.PromptGamePassPurchaseFinished:Connect(function(plr: Instance, gpid: number, wasPurch: boolean)
	if not wasPurch then return end
	local stringLiteral: string = tostring(gpid)
	
	memo[plr:: Player] = memo[plr:: Player] or {}
	memo[plr:: Player][stringLiteral] = true
end)

return getGamepassMemo
