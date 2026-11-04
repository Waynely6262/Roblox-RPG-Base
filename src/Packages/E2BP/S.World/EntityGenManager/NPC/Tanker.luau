--!strict
local MovesAsync = require(game.ServerScriptService.Root.Other.MovesAsync)

local Super = require(script.Parent.Superclass)

local Variant = {}
Variant.__index = Variant
setmetatable(Variant, Super.class)

local name = script.Name

function Variant.attack(self: Super.type, chum)

	Super.class.attack(self, chum, function(target)
	end)
end


return {
	new = function()
		local self = Super.new(name)
		setmetatable(self, Variant)

		self.attackDebounce = 0
		self.attackCooldown = .75

		return self
	end
}