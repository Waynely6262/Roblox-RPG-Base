--!strict
-- Written by Grok
-- Server-side Crafting API module
-- Place this in ServerScriptService or ReplicatedStorage (if you want to require it from both sides, but logic should stay server-only)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerInventories = require(game.ServerScriptService.Root.Players.PlayerInventories) -- adjust path as needed
local CraftConfig = require(ReplicatedStorage.Modules.PackageConfig.Crafting)

local Crafting = {}

-- Returns whether the player can craft the item (has all required materials)
function Crafting.canCraft(player: Player, itemName: string): boolean
	local recipe = CraftConfig.flat[itemName]
	if not recipe then
		warn("No crafting recipe found for:", itemName)
		return false
	end

	for materialName: string, requiredCount: number in recipe do
		local playerHas = PlayerInventories.countOf(player, materialName)
		if playerHas < requiredCount then
			return false
		end
	end

	return true
end

-- Attempts to craft the item.
-- Returns true if crafting succeeded, false if failed (insufficient materials or no recipe)
function Crafting.craft(player: Player, itemName: string): boolean
	local recipe = CraftConfig.flat[itemName]
	if not recipe then
		warn("Attempted to craft non-existent recipe:", itemName)
		return false
	end

	-- Phase 1: Check if player has everything required
	for materialName: string, requiredCount: number in recipe do
		if PlayerInventories.countOf(player, materialName) < requiredCount then
			-- Optional: you could fire a client event here to show "Missing X iron ore" etc.
			return false
		end
	end

	-- Phase 2: Consume materials (only if all checks passed)
	for materialName: string, requiredCount: number in recipe do
		PlayerInventories.removeItem(player, materialName, requiredCount)
	end

	-- Phase 3: Give the crafted item
	-- Assuming most crafted items start with amount = 1
	-- If some recipes produce more than 1, you can extend the recipe format later
	PlayerInventories.giveNewItem(player, itemName, {
		amt = 1,
		craftedAt = tick(),
	})

	return true
end

return Crafting