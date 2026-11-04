--!strict
-- Inventory Class
local Containers = require(script.Container)
local KeyContainers = require(script.KeyContainer)
local Items = require(script.Item)
local Locations = require(script.Location)

local Inventories = {}
local Inventory = {}
Inventory.__index = Inventory

local HTTPService = game:GetService("HttpService")
local PConfig = require(game.ReplicatedStorage.Modules.PackageConfig.Inventory)

-- moves all items in t to T
local function table_merge(T: {any}, t: {any})
	for i, v in t do
		table.insert(T, v)
		t[i] = nil
	end
end 

function Inventories.new(): Inventory
	
	local self = {
		Hotbar = Containers.new(10, "Hotbar");
		Equipment = KeyContainers.new(PConfig.EquipmentKeys, "Equipment"):: KeyContainers.KeyContainer;
		Storage = Containers.new(30, "Storage");
		Grasp = nil;
	}
	
	
	return setmetatable(self, Inventory)
end

function Inventories.fromJSON(JSON: string)
	
	local nontransient = HTTPService:JSONDecode(JSON)
	local self = {
		Hotbar = Containers.fromJSON(10, "Hotbar", nontransient.Hotbar);
		Equipment = KeyContainers.fromJSON(0, "Equipment", nontransient.Equipment);
		Storage = Containers.fromJSON(30, "Storage", nontransient.Storage);
		Grasp = nil;
	}
	
	setmetatable(self, Inventory)
	
	return self:: Inventory
end


--/ Methods

--// Readers
function Inventory.count(self: Inventory, name: string, quota: number?): number
	
	local count = 0
	
	for slot, item in self.Hotbar.contents do
		if item.name == name then
			count += item.dynamic.amt:: number
			
			if quota and count >= quota then
				return count
			end
		end
	end
	
	for slot, item in self.Storage.contents do
		if item.name == name then
			count += item.dynamic.amt:: number
			
			if quota and count >= quota then
				return count
			end
		end
	end
	
	for slot, item in self.Equipment.contents do
		if item.name == name then
			count += item.dynamic.amt:: number
			
			if quota and count >= quota then
				return count
			end
		end
	end
	
	
	return count
end

function Inventory.findAll(self: Inventory, name: string): {Items.item}
	
	local found = {}:: {Items.item}
	
	for _, item in self.Hotbar.contents do
		if item.name == name then
			table.insert(found, item)
		end
	end
	
	for _, item in self.Storage.contents do
		if item.name == name then
			table.insert(found, item)
		end
	end
	
	for _, item in self.Equipment.contents do
		if item.name == name then
			table.insert(found, item)
		end
	end
	
	return found
end

--// Manipulators (All manipulators will return a list of items that were modified as the second return value. This is for client user interface updates)

function Inventory.actOn(self: Inventory, name: string, f: (Items.item) -> (boolean)): (boolean, {Items.item})
	
	local modified = {}
	for _, item in self.Hotbar.contents do
		if item.name == name then
			table.insert(modified, item)
			if f(item) then
				return true, modified
			end
		end
	end
	
	for _, item in self.Storage.contents do
		if item.name == name then
			table.insert(modified, item)
			if f(item) then
				return true, modified
			end
		end
	end
	
	for _, item in self.Equipment.contents do
		if item.name == name then
			table.insert(modified, item)
			if f(item) then
				return true, modified
			end
		end
	end
	
	return false, modified
end

function Inventory.insert(self: Inventory, src: Items.item | string): (boolean, {Items.item})
	
	local item: Items.item
	if typeof(src) == "string" then 
		item = Items.fromJSON(src)
	else
		item = src
	end
	
	local result
	local totalModified = {}
	
	if item:getLimits().stack > 1 then
		-- try hotbar spread
		do
			local modified
			result, modified = self.Hotbar:spread(item)
			if result then return true, modified end -- exit early without using table_merge because this is the first time 'modified' would be written to
			table_merge(totalModified, modified)
		end
		-- try storage spread
		do
			local modified
			result, modified = self.Storage:spread(item)
			table_merge(totalModified, modified)
		end
		-- try equipment spread
		if not result then
			local modified
			result, modified = self.Equipment:spread(item)
			table_merge(totalModified, modified)
		end
	end
	
	-- try hotbar insert
	if not result then
		local modified
		result, modified = self.Hotbar:insert(item, true)
		if result then return true, modified end
		table_merge(totalModified, modified)
	end
	-- try storage insert
	if not result then
		local modified
		result, modified = self.Storage:insert(item, true)
		if result then return true, modified end
		table_merge(totalModified, modified)
	end
	-- try equipment insert
	if not result then
		local modified
		result, modified = self.Equipment:insert(item, true)
		if result then return true, modified end
		table_merge(totalModified, modified)
	end
	
	return false, totalModified
end

function Inventory:place(item: Items.item | string, container: string, slot: number): (boolean, {Items.item})
	if typeof(item) == "string" then item = Items.fromJSON(item) end
	return self[container]:place(item, slot)
end

function Inventory.remove(self: Inventory, name: string, limit: number?): (number, {Locations.Location | Items.item})
	
	local modified = {}:: {Locations.Location | Items.item}
	
	local totalResult = 0
	
	
	
	local n1, t1 = self.Hotbar:remove(name, limit)
	totalResult += n1
	table_merge(modified, t1)
	
	if limit and totalResult >= limit then return totalResult, modified end
	
	local n2, t2 = self.Storage:remove(name, limit)
	totalResult += n2
	table_merge(modified, t2)
	
	if limit and totalResult >= limit then return totalResult, modified end
	
	local n3, t3 = self.Equipment:remove(name, limit)
	totalResult += n3
	table_merge(modified, t3)
	
	if limit and totalResult >= limit then return totalResult, modified end
	
	return totalResult, modified
end

function Inventory.getEverything(self: Inventory): {Items.item | Locations.Location}
	
	local things = {}:: {Items.item | Locations.Location}
	
	for i = 1, self.Hotbar.slots do
		local v = self.Hotbar.contents[i] or Locations.new(self.Hotbar, i)
		
		table.insert(things, v)
		
	end
	
	for i = 1, self.Storage.slots do
		local v = self.Storage.contents[i] or Locations.new(self.Storage, i)
		
		table.insert(things, v)
		
	end
	
	for i = 1, self.Equipment.slots do
		local v = self.Equipment.contents[i] or Locations.new(self.Equipment, i)
		
		table.insert(things, v)
		
	end
	
	return things
end


function Inventory.toJSON(self: Inventory)
	local nontransient = {
		
		Hotbar = self.Hotbar:toJSON();
		Storage = self.Storage:toJSON();
		Equipment = self.Equipment:toJSON();
		
	}
	
	return HTTPService:JSONEncode(nontransient)
end
table.freeze(Inventory)
table.freeze(Inventories)

export type Inventory = typeof(setmetatable({} :: {
	Hotbar: Containers.Class;
	Equipment: KeyContainers.KeyContainer;
	Storage: Containers.Class;
	Grasp: nil; -- awaiting implementation
}, Inventory))
return Inventories