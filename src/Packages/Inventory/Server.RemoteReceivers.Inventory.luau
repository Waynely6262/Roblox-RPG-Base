--!strict

local PlayerInventories = require(game.ServerScriptService.Root.Players.PlayerInventories)
local CTools = require(game.ServerScriptService.Root.Tools)
local ToolConfig = require(game.ReplicatedStorage.Modules.PackageConfig.CustomTools)
local Remote = require(game.ServerScriptService.Root.Remotes)
local Finder = require(game.ReplicatedStorage.Modules.Utility.Finder)

type item = any

local EquippedItems: {[Player]: {[string]: item}} = {}
local ClientRequestResponses = {}

function ClientRequestResponses.hb(player: Player, slot: number)
	return ClientRequestResponses.equip(player, "Hotbar", slot)
end

local function Unequip(player: Player, group: string, container: string, slot: number)
	
	if EquippedItems[player] then -- if this table isn't even initialized, then player has no tools at all
		PlayerInventories.Unequipped:Fire(player, group, EquippedItems[player][group])
		EquippedItems[player][group] = nil
		CTools.unequip(player.Character:: Model, group)
		Remote.FireClient(player, "inv", "unequip", container, slot)
	end
end

local function Equip(player: Player, item: item)
	local group = item:getData().key or ToolConfig.DEFAULT_GROUP_KEYWORD

	EquippedItems[player] = EquippedItems[player] or {}
	
	local OldItem = EquippedItems[player][group]
	if OldItem ~= item then -- Ignore the request if the item is already equipped.
		
		if OldItem then
			OldItem.dynamic.equipped = nil
			-- since the 'group' is the same, I'm not gonna fire the signal here, otherwise a redundant calculation is done to update combat_stats for nil equip
			--PlayerInventories.Unequipped:Fire(player, group, OldItem)
			Remote.FireClient(player, "inv", "unequip", OldItem.container.name, OldItem.slot)
		end
		
		EquippedItems[player][group] = item
		CTools.equip(player.Character:: Model, item.name, group, true, item)
		PlayerInventories.Equipped:Fire(player, group, item)
		item.dynamic.equipped = true
		Remote.FireClient(player, "inv", "equip", item.container.name, item.slot)
	end
end

local function Toggle(player: Player, item: item)
	local group = item:getData().key or ToolConfig.DEFAULT_GROUP_KEYWORD

	if not (EquippedItems[player] and EquippedItems[player][group] == item) then
		Equip(player, item) -- performs budgetable redundant calculation to get 'group' a second time
	else
		-- This function is only called when the item has stayed in the same place but an equip/unequip is requested.
		-- This means that item.container.name and item.slot are safe to read from.
		item.dynamic.equipped = nil
		Unequip(player, group, item.container.name, item.slot)
	end
end

function ClientRequestResponses.equip(player: Player, c: string, s: string | number)
	if not assert(Finder.followPath(player, "Transient", "IsAlive"):: BoolValue?, `Can't read player isAlive`).Value then return end
	
	local inv = PlayerInventories.getInventory(player)
	
	if inv then
		local item = inv[c].contents[s]
		if item then
			Toggle(player, item)
			
		else
			warn(`{player.Name} does not have an item at {s} -> {c}`)
		end
	end
end

function ClientRequestResponses.swap(player, c1, s1, c2, s2)
	print(`{player.Name} swap from {c1},{s1} to {c2},{s2}`)
	local inv = PlayerInventories.getInventory(player)

	if inv then
		Remote.FireClient(player, "inv", "swap", c1,s1,c2,s2)
		local container1 = inv[c1]
		local container2 = inv[c2]
		
		local item1 = container1.contents[s1]		
		local item2
		
		if not item1 then
			warn(`{player.Name} invalid swap call; nothing found at initial location`)
			return
		end
		
		-- handles stacking and placing if empty
		local success = container2:place(item1, s2)
		
		-- slot isn't empty because container.place() failed
		-- OR: Item cannot go into that slot
		if not success then
			-- get item at the destination
			item2 = container2.contents[s2]
			
			if not item2 then return end -- failure due to incompatible destination, without an occupied destination
			
			local function abort()
				item1:move(container1, s1)
				item2:move(container2, s2)
			end			
			
			-- check if item2 is conflicting
			item1:remove()
			item2:remove()
			local subsuccess1 = container2:place(item1, s2)
			local subsuccess2 = container1:place(item2, s1)
			
			if not (subsuccess1 and subsuccess2) then
				abort() -- failure due to destination's item incompatible with source
				return
			end
		end -- success due to compatible destination and unoccupied destination
		
		-- Successful
		
		
		-- Two parts in Equipment having the same key is attributed to an accessory1 accessory2 feature.
		if c2 == "Equipment" and c2 ~= c1 then
			Equip(player, item1)
		end
		-- Items are unequipped when the player moves them for all items, so this section isn't limited to
		-- Equipment items.
		
		if c1 == "Equipment" then
			if c1 ~= c2 then
				-- if c1 is equipment, s1 is an equipment key. Since PInventories interacts with
				-- CustomTools by using the 'key' property, s1 can be used directly instead of
				-- indexing through item2:getData().key
				
				-- I LIED. s1 is a number because equipment internally uses numbers!! </3 screw everything.
				
				-- Toggle() will default the group value, but Unequip won't.
				-- This is fine however, because "item:getData().key" should never return nil when the associated container is "Equipment".
				item1.dynamic.equipped = nil
				Unequip(player, item1:getData().key, c1, s1)
			end
		else-- if c1 was equipment, then the item would be unequipped because equipment automatically gets unequipped when moving out of the Equipment container.
			local key1 = item1:getData().key or ToolConfig.DEFAULT_GROUP_KEYWORD
			local key2 = item2 and item2:getData().key or ToolConfig.DEFAULT_GROUP_KEYWORD
			
			if EquippedItems[player] then
				if EquippedItems[player][key1] == item1 then
					Remote.FireClient(player, {
						{"inv", "unequip", c1, s1;};
						{"inv", "equip", c2, s2;};
					})
				end
				
				if item2 and EquippedItems[player][key2] == item2 then
					Remote.FireClient(player, {
						{"inv", "unequip", c2, s2;};
						{"inv", "equip", c1, s1;};
					})
				end
			end

		end
	end
end

return {
	onInvoke = function(player, act, ...)
	
		ClientRequestResponses[act](player, ...)
	end;
	reset = function(player: Player)	
		local Equipped = EquippedItems[player]
		if Equipped then
			for group, item in Equipped do
				Unequip(player, group, item.container.name, item.slot)
			end
		end		
	end,
	
	-- equip anything in equipment
	reconcileAsync = function(player: Player)
		
		local Inventory = PlayerInventories.getInventory(player)
		
		if not Inventory then return end
		
		for slot, item in Inventory.Equipment.contents do
			Equip(player, item)
		end
	end,
	
	_aliases = {
		"inv";
	};
}