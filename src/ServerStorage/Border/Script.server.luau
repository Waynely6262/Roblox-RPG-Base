local cfg = require(game.ReplicatedStorage.Modules.Game.Config)

local big = cfg.TILE_SIZE * cfg.FLOOR_SIZE

script.Parent:PivotTo(CFrame.new(big/2, 0, big/2))