local Spawner = require(script.Parent.Parent.Spawner)
local Hopper = require(game.ServerScriptService.Root.World.Structures.ZoneHopper)
local LoadSimilar = require(game.ServerScriptService.Root.World.CanonUtil.LoadSimilar)
local self = LoadSimilar.init(script)

self:insertSpawner(Spawner.new("ores", 1, 1, 100, 100, 100))
Hopper(self:CellToWorldSpace(100, 80), "Forest", 2, 30)

LoadSimilar.prebuild(self)

return self
