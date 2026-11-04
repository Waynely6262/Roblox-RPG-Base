local Spawner = require(script.Parent.Parent.Spawner)
local Hopper = require(game.ServerScriptService.Root.World.Structures.ZoneHopper)
local LoadSimilar = require(game.ServerScriptService.Root.World.CanonUtil.LoadSimilar)
local self = LoadSimilar.init(script)

Hopper(self:CellToWorldSpace(50,1), "Tutorial", 50, 99)
Hopper(self:CellToWorldSpace(7, 12), "Cave", 86, 80)
Hopper(self:CellToWorldSpace(50, 100), "Crossroads", 25, 2)
Hopper(self:CellToWorldSpace(1, 85), "Forest", 99, 32)


LoadSimilar.prebuild(self)

return self
