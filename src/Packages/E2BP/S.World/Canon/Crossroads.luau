local Spawner = require(script.Parent.Parent.Spawner)
local Hopper = require(game.ServerScriptService.Root.World.Structures.ZoneHopper)
local LoadSimilar = require(game.ServerScriptService.Root.World.CanonUtil.LoadSimilar)
local self = LoadSimilar.init(script)
self:setSpawnCell(50,40)

Hopper(self:CellToWorldSpace(50, 1), "Village", 50, 99)
Hopper(self:CellToWorldSpace(1, 30), "Forest", 99, 83)
Hopper(self:CellToWorldSpace(50, 100), "Castle (North)", 50, 2)
Hopper(self:CellToWorldSpace(100, 50), "Memorial", 2, 50)

LoadSimilar.prebuild(self)

return self
