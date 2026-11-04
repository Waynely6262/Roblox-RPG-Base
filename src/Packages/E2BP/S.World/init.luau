--!strict
--------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game.ReplicatedStorage

local CONFIG = require(ReplicatedStorage.Modules.Game.Config)
local Floor = require(script.Floor)
local Profiles = require(script.Parent.Players.Profiles)
local TickUpdate = require(script.TickUpdate)
local UnderworldFloor = require(script.UnderworldFloor)
--------------------------------------------
local e = ReplicatedStorage.Remotes.MainE

local weak_keys = {__mode = "k"}

local FloorNextUpdates: {[typeof(Floor.new(nil,-1))]: number} = {}

local Locations = {}

local Floors: {[number | string]: Floor.Class} = {
}
for i, v in script.Canon:GetChildren() do
	v:SetAttribute("_n", i)
	Floors[v.Name] = require(v)
end


local UnsortedUnderworldFloors = {}
--TODO: Add unloading floors after some amount of inactivity
local MaximumGeneratedUnderworldFloors = 25


local PlayerFloors = setmetatable({}:: {[Player]: string}, weak_keys)

-- Core Loop
RunService.Heartbeat:Connect(function()
	
	local RelevantFloors = {}
	-- remember floors that are currently occupied by a player
	for player, location_name in PlayerFloors do
		RelevantFloors[Floors[location_name]] = false
	end
	
	-- go through all floors
	for i, floor in Floors do
		-- ignore unloaded floors
		if not floor.IsLoaded then continue end
		
		-- already updated; this is to account for possible multiple entries of the same floor
		-- The "Floors" table is not necessarily injective
		if RelevantFloors[floor] then continue end
		
		-- unload floors that aren't occupied by a player
		if RelevantFloors[floor] == nil then
			--TODO: Deleting floors after a LONG period of inactivity or high volatility to conserve memory
			floor:Unload()
			continue
		end
		
		-- make sure an update is scheduled for the floor
		FloorNextUpdates[floor] = FloorNextUpdates[floor] or os.clock() + (CONFIG.SPAWN_PERIOD / math.sqrt(floor.Number))
		
		-- check if the update is due
		if FloorNextUpdates[floor] <= os.clock() then
			FloorNextUpdates[floor] = os.clock() + (CONFIG.SPAWN_PERIOD / math.sqrt(floor.Number))
			-- generate stuff
			TickUpdate(floor)
		end
		
		-- mark as updated
		RelevantFloors[floor] = true
	end
end)


local getFloor = function(l: number | string): Floor.Class
	local l = tostring(l)
	local query_result = Floors[l]
	-- Only underworld floors won't be predefined
	if not query_result then
		query_result = UnderworldFloor.new(l)
		
		Floors[l] = query_result
		Floors[query_result.Name] = query_result
		table.insert(UnsortedUnderworldFloors, query_result)
	end
	query_result:Load()
	return query_result
end

local function getPlayerFloor(player: Player)
	return PlayerFloors[player] and Floors[PlayerFloors[player]]
end

return {
	
	teleportPlayer = function(player: Player, floor_name: string | number, x: number?, y: number?): boolean
		floor_name = floor_name or "Overworld"
		
		local floor = getFloor(floor_name)
		--TODO: Add some kind of loading screen sequence here so the player doesn't just freeze while the server tries to load the floor		
		
		
		local char = player.Character
		
		if not char then
			warn(`Expected {player.Name}'s character but it wasn't found.`)
			return false
		end
		
		local hrp: BasePart = assert(char:FindFirstChild("HumanoidRootPart"), `Couldn't teleport {player.Name} because missing HRP`):: BasePart
		
		
		hrp.Anchored = true
		
		e:FireClient(player, "load", true, "Loading floor " .. floor.Name)
		local CharacterPivot = char:GetPivot()
		
		local spot: Vector3?
		
		if floor.default_spawn_cell then
			x = x or floor.default_spawn_cell.x
			y = y or floor.default_spawn_cell.y
		end
		
		
		if (x and y) then
			
			
			if floor.Content[x][y].Content ~= nil then
				warn(`Content is not nil at {x}, {y} on {floor.Name}`)
			end
			
			spot = floor:CellToWorldSpace(x, y)			
		else
			spot, _ = floor:findOpenSpace()
			
		end
		if not spot then
			warn("Unable to teleport player")
			hrp.Anchored = false
			return false
		end
		hrp.AssemblyLinearVelocity = Vector3.zero
		
		char:PivotTo(CFrame.new(spot + Vector3.new(0, 5, 0)) * CharacterPivot.Rotation)
		
		task.delay(1, function()
			hrp.Anchored = false
		end)
		-- update variables after success
		Profiles[player].Data.Instant.Floor = floor_name
		PlayerFloors[player] = floor.Name
		
		return true
	end,
	
	getPlayerFloor = getPlayerFloor
}