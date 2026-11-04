--!strict
local MovesAsync = require(game.ServerScriptService.Root.Other.MovesAsync)

local Super = require(script.Parent.Superclass)

local Variant = {}
Variant.__index = Variant
setmetatable(Variant, Super.class)

local name = script.Name

function Variant.attack(self: Super.type, chum)

	Super.class.attack(self, chum, function(target)
		local d = target.adornee:GetPivot().Position
		if self.attackDebounce < os.clock() and (d - self.RootPart.Position:: Vector3).Magnitude > 15 then
			self.attackDebounce = os.clock() + self.attackCooldown:: number
			task.defer(MovesAsync.dash, 4, self.chumanoid, d, d)
		end
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