--!strict

local HTTPService = game:GetService("HttpService")


local Signal = require(game.ReplicatedStorage.Modules.Utility.Signal)
local items = require(script.Parent.Item)
local Locations = require(script.Parent.Location)

local Containers = {}
local Container = {}
Container.__index = Container
Containers.class = Container
--export type Container = typeof(setmetatable({}:: {
--	maxWeight: number;
--	weight: number,
--	slots: number,
--	itemAdded: Signal.Signal<items.item>;
--	itemRemoved: Signal.Signal<items.item>;
--	itemDistributed: Signal.Signal<string>;
--	contents: {[number]: items.item};
--	name: string?;
--}, Container))

local function nextAvailable(t: {any}): number
	local len = #t
	for i = 1, len do
		if not t[i] then
			return i
		end
	end
	return len + 1
end

function Containers.new(slots: number, name: string?)
	local self = setmetatable({
		maxWeight = math.huge;
		weight = 0;
		slots = slots; -- o(n) time
		itemAdded = Signal.new();
		itemRemoved = Signal.new();
		itemDistributed = Signal.new();
		contents = {}:: {items.item};
		name = name;
	}, Container)
	
	return self
end

function Containers.fromJSON(slots: number, name: string?, JSON: string): Class

	local self = Containers.new(slots, name)

	local things = HTTPService:JSONDecode(JSON)

	for _, v in things do
		local t = items.fromJSON(v.jsonItem)
		t.container = self
		t.slot = v.slot
		self.contents[v.slot] = t
		
	end
	
	return self:: Class
end

--/ Methods

--// Readers
function Container.count(self: Class, name: string): number
	
	local count = 0
	
	for slot, item in self.contents do
		if item.name == name then
			count += item.dynamic.amt:: number
		end
	end
	return count
end

function Container.findAll(self: Class, name: string): {items.item}
	
	local found = {}
	
	for _, item in self.contents do
		if item.name == name then
			table.insert(found, item)
		end
	end
	return found
end

--// Manipulators (All manipulators will return a list of items that were modified as the second return value. This is for client user interface updates)

--[[
Acts on the occurrences of a given item name,
and exits once the passed function returns a truthy.
The function itself will yield and returns successful or not.
]]
function Container.actOn(self: Class, name: string, f: (items.item) -> (boolean)): (boolean, {items.item})
	
	local modified = {}
	
	for _, item in self.contents do
		if item.name == name then
			table.insert(modified, item)
			if f(item) then
				return true, modified
			end
		end
	end
	return false, modified
end


--[[
spreads the item across existing stacks of that that item in the container without creating a new stack.
This is done so that no new stack is created until all existing stacks are
filled.
]]
function Container.spread(self: Class, item: items.item): (boolean, {items.item})
	
	local modified = {}
	
	local stackSize = item:getLimits().stack
	if stackSize > 1 then -- because items have to have an amount of at least one and if the stack size is 1 then the item isn't stackable

		local result
		result, modified = self:actOn(item.name, function(old: items.item)
			return item:stackOn(old)
		end)

		if result then
			item:remove()
			self.itemDistributed:Fire(item.name)
			return true, modified
		end

	end
	return false, modified
end

--[[
Inserts without bias into the container, first by stacking onto 
existing items, then by inserting as its own item. Optionally,
stacking can be skipped by specifying a truthy as the second argument.
]]
function Container.insert(self: Class, item: items.item, skipSpread: boolean): (boolean, {items.item})
	
	local modified: {items.item} = {}
	if not skipSpread then
		local spreadResult: boolean
		spreadResult, modified = self:spread(item)
		
		if spreadResult then return spreadResult, modified end
	end
	
	local i = nextAvailable(self.contents)
	if i > self.slots then
		return false, modified
	end
	item:add(self, i)
	self.itemAdded:Fire(item)
	
	table.insert(modified, item)
	return true, modified
end

--[[
Attempts to place the item at the specified slot. If not possible, 
tries to stack on the item instead. If not possible, returns false.
]]
function Container.place(self: Class, item: items.item, slot: number): (boolean, {items.item})
	
	local old: items.item? = self.contents[slot]
	
	if old and old.name ~= item.name then
		return false, {}
	elseif old then
		return item:stackOn(old:: items.item), {item, old}
	else
		item:add(self, slot)
		return true, {item}
	end
end

--[[
Removes all items with the given name, returning the quantity removed.
Optionally, specify a limit for removing.
]]
function Container.remove(self: Class, name: string, limit: number?): (number, {Locations.Location})
	
	local removed = 0
	
	local modified = {}:: {Locations.Location}
	
	for slot, item in self.contents do
		if item.name == name then
			table.insert(modified, Locations.new(item.container, item.slot))
			
			if limit then
				local remaining = limit - removed
				
				if item.dynamic.amt <= remaining then
					item:remove()
					removed += item.dynamic.amt
				else
					removed += remaining
					item:subAmt(remaining)
				end
				if removed >= limit then
					break
				end
			else
				item:remove()
				removed += item.dynamic.amt
			end
		end
	end
	return removed, modified
end

--// Translators

function Container.toJSON(self: Class)
	local things = {}
	for k, v in self.contents:: {items.item} do
		table.insert(things, {
			slot = k;
			jsonItem = v:toJSON();
		})
	end
	return HTTPService:JSONEncode(things)
end

table.freeze(Container)
table.freeze(Containers)

export type Class = typeof(Containers.new(0))

return Containers