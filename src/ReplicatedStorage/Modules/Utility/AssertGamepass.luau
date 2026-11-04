-- Handles one-time gamepass assertion

local RetryAsync = require(game.ReplicatedStorage.Modules.Utility.RetryAsync)

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Queue = {}

local function assertGamepass(userId: number, gamepassId: number, trueFunction: () -> (), functionPurpose: string, doOverwrite: boolean, promptIfNotOwned: boolean?): nil
	
	local success, OwnsGamepass = RetryAsync(4, function()
		return MarketplaceService:UserOwnsGamePassAsync(userId, gamepassId)
	end)

	print("User " .. userId .. " owns gamepass: " .. tostring(OwnsGamepass))
	
	if OwnsGamepass == true then
		trueFunction()
	elseif success then
		local player = Players:GetPlayerByUserId(userId)
		
		if not player then return end
			
		Queue[player] = Queue[player] or {}
		Queue[player][gamepassId] = Queue[player][gamepassId] or {}
		
		
		if Queue[player][gamepassId][functionPurpose] and not doOverwrite then
			return
		end
		
		Queue[player][gamepassId][functionPurpose] = trueFunction
		
		
		if promptIfNotOwned then -- pretty useless feature for gamepass assertion
			MarketplaceService:PromptGamePassPurchase(player, gamepassId)
		end
		
	else
		warn("Assertion of gamepass failed to get OwnsGamepass information; UserId: " .. userId .. ", GamePassId: " .. gamepassId .. " - " .. OwnsGamepass)
	end

	
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
	if wasPurchased and Queue[player] and Queue[player][gamepassId] then
		for _, func in Queue[player][gamepassId] do
			func()
		end
		Queue[player][gamepassId] = nil
		
	end
end)

Players.PlayerRemoving:Connect(function(player)
	Queue[player] = nil
end)

return assertGamepass