local Spawner = require(script.Parent.Parent.Spawner)
local Hopper = require(game.ServerScriptService.Root.World.Structures.ZoneHopper)
local LoadSimilar = require(game.ServerScriptService.Root.World.CanonUtil.LoadSimilar)
local self = LoadSimilar.init(script)

self:insertSpawner(Spawner.new("sandboxNPC", 1, 1, 100, 100, 50))

self:setSpawnCell(2, 50)


Hopper(self:CellToWorldSpace(1, 50), "Crossroads", 99, 50)
LoadSimilar.prebuild(self)

return self
