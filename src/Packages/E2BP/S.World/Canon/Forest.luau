local Spawner = require(script.Parent.Parent.Spawner)
local Hopper = require(game.ServerScriptService.Root.World.Structures.ZoneHopper)
local LoadSimilar = require(game.ServerScriptService.Root.World.CanonUtil.LoadSimilar)
local self = LoadSimilar.init(script)

self:insertSpawner(Spawner.new("forestProp", nil, nil, nil, nil, 100))
self:insertSpawner(Spawner.new("forestNPC", nil, nil, nil, nil, 20))

Hopper(self:CellToWorldSpace(100, 20), "Village", 50, 99)
Hopper(self:CellToWorldSpace(100, 83), "Crossroads", 2, 15)
Hopper(self:CellToWorldSpace(1, 30), "Mountain Range", 99, 80)

LoadSimilar.prebuild(self)

return self
