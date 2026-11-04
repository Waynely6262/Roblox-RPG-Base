--!strict
local HTTPService = game:GetService("HttpService")

local Containers = require(script.Parent.Container)
local items = require(script.Parent.Item) -- purely for type checking

local KeyContainers = {}

local KeyContainer = setmetatable({}, Containers.class)
KeyContainer.__index = KeyContainer

export type KeyContainer = {
	
	keys: {[string]: number}
} & Containers.Class
function KeyContainers.new(keys_allowed: {string}, name: string?): KeyContainer
	
	local self = Containers.new(#keys_allowed, name):: KeyContainer
	
	-- build internal indices
	local keys = {}
	
	for i, v in keys_allowed do
		keys[v] = i
	end
	
	self.keys = keys:: {[string]: number}
	
	return setmetatable(self, KeyContainer)
	
end

function KeyContainers.fromJSON(slots: number, name: string?, JSON: string): KeyContainer


	local pack = HTTPService:JSONDecode(JSON)
	local keys, things = table.unpack(pack)
	-- keys is already [v] = i, so manually set it to avoid flipping iv again
	local self = KeyContainers.new({}, name)
	
	for _, v in things do
		local t = items.fromJSON(v.jsonItem)
		t.container = self
		t.slot = v.slot
		self.contents[v.slot] = t

	end
	
	self.keys = keys

	return self:: KeyContainer
end

function KeyContainer.toJSON(self: KeyContainer)
	
	local keys = self.keys
	local things = {}
	for k, v in self.contents:: {items.item} do
		table.insert(things, {
			slot = k;
			jsonItem = v:toJSON();
		})
	end
	return HTTPService:JSONEncode({keys, things})
end

function KeyContainer.insert(self: KeyContainer, item: items.item): (boolean, {items.item})

	local key = item:getData().key:: string

	if not key then
		return false, {} :: any
	end

	-- obtain the interal inde, to pass to KC.place()
	local slot = self.keys[key] 
	if slot then
		local a, b = self:place(item, slot)
		return a, b
	end
	return false, {} :: any
end

function KeyContainer.place(self: KeyContainer, item: items.item, slot: number | string): (boolean, {items.item})
	-- slot is usually obtained through GUI queries, which means it is possible for it to be received as a number, and therefore SHOULD be received as a number. HOWEVER. I'm dumb so I'll sanitize it
	
	
	
	local keyReq = item:getData().key
	
	if not keyReq then return false, {} end
	
	-- failsafe sanitization: keyReq == slot will auto-translate slot: string to the required slot: number
	if slot == keyReq then
		slot = self.keys[keyReq]
	end
	
	if slot ~= self.keys[keyReq] then return false, {} end

	local old: items.item? = self.contents[slot:: number]

	if old and old.name ~= item.name then
		return false, {}
	elseif old then
		return item:stackOn(old:: items.item), {item, old}
	else
		item:add(self, slot:: number)
		print(item)
		return true, {item}
	end
end


return KeyContainers