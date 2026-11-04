local Spawner = require(script.Parent.Parent.Spawner)
local Hopper = require(game.ServerScriptService.Root.World.Structures.ZoneHopper)
local LoadSimilar = require(game.ServerScriptService.Root.World.CanonUtil.LoadSimilar)
local self = LoadSimilar.init(script)

Hopper(self:CellToWorldSpace(50, 1), "Crossroads", 50, 49)
Hopper(self:CellToWorldSpace(50, 100), "Castle (South)", 50, 2)

LoadSimilar.prebuild(self)

return self
