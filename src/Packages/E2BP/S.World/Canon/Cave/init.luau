local Spawner = require(script.Parent.Parent.Spawner)
local Hopper = require(game.ServerScriptService.Root.World.Structures.ZoneHopper)
local LoadSimilar = require(game.ServerScriptService.Root.World.CanonUtil.LoadSimilar)
local self = LoadSimilar.init(script)

--self:insertSpawner(Spawner.new("ores", 1, 1, 100, 100, 50))
--self:insertSpawner(Spawner.new("caveNPC", 1, 1, 100, 100, 25))
Hopper(self:CellToWorldSpace(50, 50), 1)
Hopper(self:CellToWorldSpace(87,81), "Village", 14, 26)

LoadSimilar.prebuild(self)

return self
