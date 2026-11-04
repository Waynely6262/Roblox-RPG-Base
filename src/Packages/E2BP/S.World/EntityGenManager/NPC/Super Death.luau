--!strict
local MovesAsync = require(game.ServerScriptService.Root.Other.MovesAsync)

local Super = require(script.Parent.Superclass)

local Variant = {}
Variant.__index = Variant
setmetatable(Variant, Super.class)

local name = script.Name

function Variant.attack(self: Super.type, chum)

	Super.class.attack(self, chum, function(target: typeof(self.chumanoid))

		local d = target.adornee:GetPivot().Position
		local diff = d - self.RootPart.Position
		local sideVector = diff:Cross(Vector3.new(0, math.random() - 0.5)).Unit
		
		if self.attackDebounce < os.clock() and (diff).Magnitude < 100 then
			self.attackDebounce = os.clock() + self.attackCooldown:: number
			
			task.defer(MovesAsync.dash, 4, self.chumanoid, self.RootPart.Position, diff.Unit:Lerp(sideVector, 0.25))
			task.defer(MovesAsync.beam, 2, self.chumanoid, self.RootPart.Position, d)
		end
	end)
end


return {
	new = function()
		local self = Super.new(name)
		setmetatable(self, Variant)

		self.attackDebounce = 0
		self.attackCooldown = 1

		return self
	end
}
