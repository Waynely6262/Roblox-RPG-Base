--!strict
----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local Inventories = require(ReplicatedStorage.Modules.Inventory)
local Graphics = require(ReplicatedStorage.Client.Graphics.inventory)
local Containers = require(ReplicatedStorage.Modules.Inventory.Container)
local items = require(ReplicatedStorage.Modules.Inventory.Item)
local Locations = require(ReplicatedStorage.Modules.Inventory.Location)

local RemoteE = ReplicatedStorage.Remotes.MainE

local Catalog = require(ReplicatedStorage.Modules.Inventory.Item.Catalog)
local ItemsFolder = ReplicatedStorage.Models
----------------------------------------------------------------------------------------------------

local inventory: Inventories.Inventory
local external: Containers.Class?

-- TODO.finish_this_function_and_rename_it
local function createTestViewportModel(v)
	local m = Instance.new("Model")
	local p = Instance.new("Part")
	p.Parent = m
	m:MoveTo(Vector3.zero)
	
	return m
end

local function updateGraphic(ele: Locations.Location | items.item?)
	if ele and (ele.__index:: any).whatsHere then
		local oldele = ele -- save the original value
		-- if it's a location, try to retrieve the item at the location. if an item isn't found, go back to the location element
		ele = (ele:: Locations.Location):whatsHere() 
		
		if not ele then
			Graphics.clearOne(oldele.container.name, oldele.slot)
			return
		end
	end
	local item: items.item = ele:: items.item
	
	local displayText = `{item.name} {item.dynamic and item.dynamic.amt and item.dynamic.amt ~= 1 and `x{item.dynamic.amt}` or ``}`
	Graphics.set(item.container.name, item.slot, item)
end

local function setState(ele: Locations.Location | items.item, isEquipped: boolean)
	return Graphics.setHighlight(ele.container.name, ele.slot, isEquipped)
end

local Selection: items.item? = nil

Graphics.SelectionBegan:Connect(function(container: "Hotbar" | "Storage" | "Equipment", slot: number)
	Selection = inventory[container].contents[slot]
	if Selection then
		Graphics.set("Drag", 1, Selection)
	end
end)

Graphics.SelectionEnded:Connect(function(container, slot)
	if Selection then
		Graphics.clearOne("Drag", 1)
		RemoteE:FireServer("inv", "swap", Selection.container.name, Selection.slot, container, slot)
	end
end)


local responses = {
	
	overwrite = function(JSON: string)
		inventory = Inventories.fromJSON(JSON)
		for _, v in inventory:getEverything() do
			updateGraphic(v)
		end
		
	end,
	
	modify = function(method: string, ...)
		
		local _, modded: {items.item | Locations.Location} = (inventory:: any)[method](inventory, ...)
		
		if modded then
			for _, v in modded do
				updateGraphic(v)
			end
		end
	end,
	
	load_external = function(containerJSON)
		
		if containerJSON then
			external = Containers.fromJSON(30, "External",containerJSON)
			Graphics.toggleExternal(true)
			
			for _, v in external.contents do
				updateGraphic(v)
			end
		else
			Graphics.toggleExternal(false)
		end
	end,
	
	update_external = function(slot: number, itemJSON: string)
		
		assert(external, `Could not update external data because no external container has been set`)
		
		external.contents[slot] = items.fromJSON(itemJSON)
	end,
	
	swap = function(c1, s1, c2, s2)
		
		local container1 = inventory[c1]:: Containers.Class
		local container2 = inventory[c2]:: Containers.Class

		local item1 = container1.contents[s1]		

		-- handles stacking and placing if empty
		local success = container2:place(item1, s2)

		-- slot isn't empty because container.place() failed
		-- OR: Item cannot go into that slot
		if not success then
			-- get item at the destination
			local item2 = container2.contents[s2]

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
		
		updateGraphic(Locations.new(container1, s1))
		updateGraphic(Locations.new(container2, s2))
		
		
	end,
	
	equip = function(c, s)
		Graphics.setHighlight(c, s, true)
	end,
	
	unequip = function(c, s)
		Graphics.setHighlight(c, s, false)
	end,
	
}

function responses.tuple(acts)
	for _, args in acts do
		
		local act = args[1]
		table.remove(args, 1)
		
		responses[act](table.unpack(args))
	end
end



return {
	onInvoke = function(act: string, ...)
		responses[act](...)
	end,
	getCurrentInventory = function()
		return inventory
	end,
	_aliases = {
		"inv";
	}
}