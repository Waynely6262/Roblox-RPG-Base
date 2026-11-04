--!strict
----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage

local E = ReplicatedStorage.Remotes.MainE

local CraftGraphics = require(ReplicatedStorage.Client.Graphics.Craft)

local Recipes = require(ReplicatedStorage.Modules.PackageConfig.Crafting)

local inventory = require(ReplicatedStorage.Client.Backend.RemoteReceivers.Inventory)
----------------------------------------------------------------------------------------------------

CraftGraphics.CraftRequested:Connect(function(name, amt)
	E:FireServer("Craft", name, amt)
end)

-- sort crafting recipes based on their item requirements;
-- display crafting recipes based on meeting smth like 30% of the material requirements


local function canCraft(name: string): boolean
	local inv = inventory.getCurrentInventory()
	if not inv then return false end
	for mat, count in Recipes.flat[name] do
		if inv:count(mat, count) < count then
			return false
		end
	end
	return true
end


local function refresh()
	local inv = inventory.getCurrentInventory()
	if inv then
		for material, recipes in Recipes.grouped do
			if material == Recipes.uncategorized_key then
				
				for name, recipe in recipes do
					CraftGraphics.setRecipe(name, canCraft(name))
				end
				
			else
				local count = inv:count(material, 1)
				if count > 0 then
					
					for name, recipe in recipes do
						CraftGraphics.setRecipe(name, canCraft(name))
					end
				end
			end
		end
	end
end

CraftGraphics.RequestUpdate:Connect(refresh)

return {
	
	refresh = refresh;
}