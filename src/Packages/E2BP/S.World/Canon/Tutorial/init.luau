local Spawner = require(script.Parent.Parent.Spawner)
local Hopper = require(game.ServerScriptService.Root.World.Structures.ZoneHopper)
local LoadSimilar = require(game.ServerScriptService.Root.World.CanonUtil.LoadSimilar)
local self = LoadSimilar.init(script)

--self:insertSpawner(Spawner.new("forestProp", 1, 1, 100, 100, 60))

--self:insertSpawner(Spawner.new("forestNPC", 1, 1, 100, 100, 15))

self:setSpawnCell(50,50)


if game:GetService("RunService"):IsStudio() then
	Hopper(self:CellToWorldSpace(40, 40), "Sandbox", 35, 35)
end

Hopper(self:CellToWorldSpace(50, 99), "Village", 50, 2)
LoadSimilar.prebuild(self)

return self
