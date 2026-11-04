--!strict
local Config = require(game.ReplicatedStorage.Modules.Game.Config)
local Players = game:GetService("Players")
local World = require(game.ServerScriptService.Root.World)
local Spawner = require(game.ServerScriptService.Root.World.Spawner)
local PlayerNameColor = require(game.ReplicatedStorage.Modules.Utility.PlayerNameColor)

local PURPL3_STUDIOS = 33738605

local Memo = {}

local function isPlayerInGroup(player: Player)
	local s, r = pcall(function()
		Memo[player] = Memo[player] or player:GetRankInGroupAsync(PURPL3_STUDIOS) >= 3
	end)
	if not s then
		warn(`Failed to grab {player.Name}'s group rank - {r}`)
		return false
	end
	
	return Memo[player]
end

local floorMaps = {}
-- Helper function to clamp world → cell coordinates
local function clampedWorldToCell(floor: any, worldPos: Vector3): {x: number, y: number}
	local cell = floor:WorldSpaceToCell(worldPos)  -- may return nil

	if cell then
		return cell  -- already inside bounds
	end
	
	worldPos -= floor.origin

	local cx = if worldPos.X < 0 then 1 else Config.FLOOR_SIZE
	local cy = if worldPos.Z < 0 then 1 else Config.FLOOR_SIZE

	return {x = cx; y = cy;}
end

local Processors = {
	["printCurrentFloor"] = function(player: Player)
		local floor = World.getPlayerFloor(player)
		print(floor:toString())
	end,

	["map"] = function(player: Player)
		local floor = World.getPlayerFloor(player)

		if floorMaps[floor] then
			for _, v in floorMaps[floor] do
				v:Destroy()
			end
		end

		local t = {}
		floorMaps[floor] = t
		for x, xg in floor.Content do
			for y, cell in xg do
				local p = Instance.new("Part")
				p.Parent = workspace.fx
				p.CanCollide = false
				p.CanQuery = false
				p.CanTouch = false
				p.Anchored = true
				p.Position = floor:CellToWorldSpace(x,y)
				p.Material = Enum.Material.ForceField
				p.Color = cell.Content and PlayerNameColor(cell.Content) or Color3.new(1,1,1)
				p.Size = Vector3.new(Config.TILE_SIZE, 16, Config.TILE_SIZE)
				p.Name = `{x},{y}`
				table.insert(t, p)
			end
		end
	end,

	["setCell"] = function(player: Player, v0: Vector3, v1: Vector3, typeofContent: string?)
		
		if typeofContent == "" or typeofContent == "nil" then print("Detected nil input") typeofContent = nil end
		
		local floor = World.getPlayerFloor(player)

		-- Use clamped version instead of assert
		local cell0 = clampedWorldToCell(floor, v0)
		local cell1 = clampedWorldToCell(floor, v1)

		local minx = math.min(cell0.x, cell1.x)
		local maxx = math.max(cell0.x, cell1.x)
		local miny = math.min(cell0.y, cell1.y)
		local maxy = math.max(cell0.y, cell1.y)

		local cellCount = 0
		for x = minx, maxx do
			for y = miny, maxy do
				cellCount += 1
				floor.Content[x][y].Content = typeofContent
			end
		end

		print(`Set {cellCount} cells to {typeofContent} (clamped coordinates)`)

		-- Optional: still show a visual box (using clamped bounds)
		local p = Instance.new("Part")
		local pos0 = floor:CellToWorldSpace(minx, maxy)
		local pos1 = floor:CellToWorldSpace(maxx, miny)  -- note: might want center or average

		-- You can improve the visual here if desired (e.g. semi-transparent selection box)
		p.Parent = workspace.fx
		-- ... set size/position/CFrame as needed ...
	end,

	["newSpawner"] = function(player: Player, v0: Vector3, v1: Vector3, spawnerType: string, max: number)
		local floor = World.getPlayerFloor(player)

		local cell0 = clampedWorldToCell(floor, v0)
		local cell1 = clampedWorldToCell(floor, v1)

		local minx = math.min(cell0.X, cell1.X)
		local maxx = math.max(cell0.X, cell1.X)
		local miny = math.min(cell0.Y, cell1.Y)
		local maxy = math.max(cell0.Y, cell1.Y)

		floor:insertSpawner(Spawner.new(spawnerType, minx, miny, maxx, maxy, max))
		print(`Spawner created ({spawnerType}) at clamped region {minx},{miny} → {maxx},{maxy}`)
	end,
}

return {
	onInvoke = function(player, request, ...)
		if isPlayerInGroup(player) then
			Processors[request](player, ...)
		else
			warn(player, "does not have sufficient permissions to run developer api")
		end
	end
}