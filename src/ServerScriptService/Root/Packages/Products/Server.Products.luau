-- Handles the receipt of DevProduct purchases. Gamepasses should be handled using AssertGamepass

local Players = game:GetService("Players")
local ReplicatedStorage = game.ReplicatedStorage
local MS = game:GetService("MarketplaceService")

local IDs = require(ReplicatedStorage.Modules.Data.ProductIds)
local RetryAsync = require(ReplicatedStorage.Modules.Utility.RetryAsync)




local ProductProviders = {}:: {[any]: (Player) -> (boolean)}

local autoFailReceipt = function() return false end

for offerName, module in script:GetChildren() do
	local s, f = pcall(function()
		return require(module)
	end)
	
	if not s then
		warn(`[Server: Products] Failed to load product provider {module.Name}: {f}`)
	end
	
	f = autoFailReceipt
	
	ProductProviders[module.Name] = f
	if tonumber(module.Name) then
		ProductProviders[module.Name] = f
	end
	
end

--Products[--[[id]]0 ].Completed = function(player)

--	local data = player:WaitForChild("leaderstats")
--	local XP = data:WaitForChild("XP")
--	if XP.Value > 0 and player.Character then
--		XP.Value += 5e6
--		return true
--	else
--		while true do
--			XP.Changed:Wait()
--			if player.Character and player.Character.Parent then
--				XP.Value += 5e6
--				return true
--			end
--		end

--	end
--	return true
--end

local function handleProductPurchase(player, productId)
	local character = player.Character

	local Provider = ProductProviders[productId]

	if Provider then
		--Notifications:FireClient(player,"product", "Successfully purchased " .. (ProductInfo.Feedback) .. "!", Color3.new(0.6,1,0.7))
		return Provider(player)
	else
		warn("Unregistered productId:" , productId)
		return false
	end
end


MS.ProcessReceipt = function(receiptInfo)
	--print(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		warn("Player not found when attempting to process receipt:", receiptInfo)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local s, r = RetryAsync(3, handleProductPurchase, player, receiptInfo.ProductId)
		if not r then warn(`Failed to process receipt for '{receiptInfo.ProductId}' {r}`) end
	return (s and r == true) and Enum.ProductPurchaseDecision.PurchaseGranted or Enum.ProductPurchaseDecision.NotProcessedYet
end

return {
	Providers = ProductProviders
}