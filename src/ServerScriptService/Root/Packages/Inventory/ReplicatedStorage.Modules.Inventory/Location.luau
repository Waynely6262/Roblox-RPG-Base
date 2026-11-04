--!strict
local Locations = {}
local Location = {}
Location.__index = Location

export type Location = typeof(setmetatable({} :: {
	container: any,
	slot: any,
}, Location))

function Locations.new(container, slot): Location
	assert(typeof(container) == "table") -- I forget my code works like this
	local self = {
		container = container;
		slot = slot;
	}
	return setmetatable(self, Location)
end

function Location.whatsHere(self: Location)
	if not (self.container and self.slot) then return end
	return self.container.contents[self.slot]
end

return Locations