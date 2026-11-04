--!strict

local HTTPService = game:GetService("HttpService")

local catalog = require(script.Catalog)
local items = {}
export type dynamic = {
	["amt"]: number,
	[string]: any,
}
local item = {}
item.__index = item

export type item = typeof(setmetatable({} :: {
	dynamic: dynamic,
	name: string,
	container: any,
	slot: number,
}, item))


function items.new(name: string, dynamic: dynamic?): item
	
	dynamic = dynamic or {}:: dynamic
	dynamic.amt = dynamic.amt or 1
	
	local self = setmetatable({
		dynamic = dynamic:: dynamic;
		name = name;
		container = nil:: any; -- modules have to require each other to get the Container data type so just leave it as any for inferring
		slot = nil:: number?;
	}, item):: item
	
	return self
end

function items.fromJSON(JSON: string): item
	
	local self = setmetatable(HTTPService:JSONDecode(JSON), item)
	
	return self
end


function item.getData(self: item): catalog.data
	return catalog[self.name]
end

function item.getLimits(self: item): catalog.limits
	return self:getData().limits
end

function item.getWeight(self: item, count: number?): number
	return self:getData().weight:: number * (count or self.dynamic.amt:: number)
end

function item:remove()
	
	if self.container then
		self.container.contents[self.slot] = nil
	end
	
	self.container = nil:: any
	self.slot = nil:: number?
end

function item.move(self: item, container: any, slot: number)
	self:remove()
	container.contents[slot] = self
	self.container = container
	self.slot = slot
end

function item.addAmt(self: item, n: number)
	
	self.dynamic.amt += n
	
	if self.container then
		self.container.weight += self:getWeight(n)
	end
end

function item.subAmt(self: item, n: number)
	return self:addAmt(-n)
end

function item.stackOn(self: item, old: item)
	if old.name ~= self.name then return false end
	local stackSize: number = self:getLimits().stack
	
	local freeSpace = stackSize - old.dynamic.amt
	if freeSpace > 0 then

		local added = math.min(self.dynamic.amt, freeSpace)
		old:addAmt(added)
		self:subAmt(added)
		
		if self.dynamic.amt <= added then
			return true
		end
	end
	return false
end

local transient = {
	"container",
	"slot",
}

-- Encodes to JSON. This function is semi-costly
function item.toJSON(self: item): string
	-- excludes transient variables
	local nontransient = {}
	for k,v in self do
		if table.find(transient, k) then
			continue
		end
		nontransient[k] = v
	end
	return HTTPService:JSONEncode(nontransient)
end

item.add = item.move


table.freeze(item)
table.freeze(items)

return items

