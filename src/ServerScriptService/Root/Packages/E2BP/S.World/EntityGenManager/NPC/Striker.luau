--!strict
local MovesAsync = require(game.ServerScriptService.Root.Other.MovesAsync)

local Super = require(script.Parent.Superclass)

local Striker = {}
Striker.__index = Striker
setmetatable(Striker, Super.class)

local name = script.Name

function Striker.attack(self: Super.type, chum)
	
	Super.class.attack(self, chum, function(target)
		
		local d = target.adornee:GetPivot().Position
		if self.attackDebounce < os.clock() and (d - self.RootPart.Position:: Vector3).Magnitude < 100 then
			self.attackDebounce = os.clock() + self.attackCooldown:: number
			task.defer(MovesAsync.reign, 4, self.chumanoid, d, d)
		end
	end)
end


return {
		new = function()
		local self = Super.new(name)
		setmetatable(self, Striker)
		
		self.attackDebounce = 0
		self.attackCooldown = 10
		
		return self
	end
}