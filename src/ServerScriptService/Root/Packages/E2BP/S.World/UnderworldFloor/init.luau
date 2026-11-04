--!strict
local CONFIG = require(game.ReplicatedStorage.Modules.Game.Config)
local Spawner = require(script.Parent.Spawner)
local Floor = require(script.Parent.Floor)
local THEMES = require(script.Parent.Themes)
local Entities = require(game.ServerScriptService.Root.World.Entities)
local Agent = require(script.PathingAgent)


local THEME_MODULUS = #THEMES
local PARTITION_BUFFER = 128 -- space dedicated to custom zones

-- reused for each floor; floor information is passed as parameters for difficulty accommodation
local uwMobSpawner = Spawner.new("uwNPC")
local uwStructureSpawner = Spawner.new("uwProp")

local UWFloor = {}
local Class = setmetatable({}, Floor.Class)
Class.__index = Class:: typeof(Floor.Class) & typeof(Class)

local function random_sign()
	return math.random() > 0.5 and 1 or -1
end

function Class.newWall(self: Class, x: number, y: number)

	local M = Instance.new("Model")
	local adornee = Instance.new("Part");


	local themeSet: any = THEMES[(self.Number:: number % THEME_MODULUS) + 1]

	for _, normalId in {
		Enum.NormalId.Left;
		Enum.NormalId.Back;
		Enum.NormalId.Right;
		Enum.NormalId.Front;
		} do

		local texture = Instance.new("Texture");
		texture.Texture = themeSet.WallTexture 
		texture.Face = normalId
		texture.Parent = adornee

	end


	local WALL_HEIGHT = math.random(CONFIG.MIN_WALL_HEIGHT, CONFIG.MAX_WALL_HEIGHT)
	adornee.Color = themeSet.WallColor 
	adornee.Size = Vector3.new(CONFIG.TILE_SIZE, WALL_HEIGHT, CONFIG.TILE_SIZE)
	--adornee.Transparency = themeSet.WallTransparency  -- laggy
	adornee.Anchored = true
	adornee.Position = self.origin + Vector3.new(x * CONFIG.TILE_SIZE, WALL_HEIGHT / 2, y * CONFIG.TILE_SIZE)
	adornee.PivotOffset = CFrame.new(0, -WALL_HEIGHT / 2, 0)
	adornee.Parent = M

	M.PrimaryPart = adornee

	adornee.Name = `{x}_{y}`

	local chum = Entities.newHumanoid(M, "Wall", math.random(10, math.min(self.Number, 2e9)))

	self.EntityGenManager:registerEntity(chum)
	
	return chum
end
-- why is the typechecker tweaking, you ask? It doesn't recognize superclasses
function UWFloor.new(l: string)
	local floor_num = tonumber(l)
	assert(floor_num, `Attempt to build a random-generated floor for a non-underworld zone (these need to be manually defined):{l}`)
	assert(floor_num > 0 and floor_num % 1 == 0, "Invalid underworld floor: " .. l .. " (must be a natural number)")

	local name = "Underworld: " .. l
	local new = setmetatable(Floor.new(name, floor_num + PARTITION_BUFFER), Class);
	
	new.room_count = 0;
	new.agent = Agent.new(new.Content, 1, 1);
	new.agentParams = {
		Costs = {
			--WALL = -0.1;
			__null = l;
		}:: {[string]: number};
		RandomWeightIgnoreChance = 0.5;
		TurningCost = 0.5;
	};
	new._wallsLoaded = nil:: boolean?;
	
	new.attributes.isUnderworld = true;

	local self = new -- attempt to correct typechecking; attempt unsuccessful. Give up 1924 -> 1925

	local roomCoords = self:buildRooms();
	self:loadBase();
	self:insertSpawner(uwMobSpawner);
	self:insertSpawner(uwStructureSpawner);
	task.defer(function() -- asynchronous room generation, to prevent hogging resources

		self:connectWaypoints(roomCoords);
		for _ = 1, math.random(10,30) do -- paths to random spots

			local x = math.random(2, CONFIG.FLOOR_SIZE - 1);
			local y = math.random(2, CONFIG.FLOOR_SIZE - 1);
			self:tunnelAsync(x,y);
		end

		self:generateWalls();
	end)
	return self
end

-- Returns a list of sets of coordinates ({x,y}), which is a coordinate to best represent the center of each room.
function Class.buildRooms(self: Class, tries: number?): {{number}}
	for x, xrow in self.Content do
		for y, cell in xrow do
			cell.Content = "WALL"
		end
	end

	-- CARVE

	local tries = tries or 2000

	local rooms = {}:: {{number}}

	for _ = 1, tries do
		if self.room_count >= CONFIG.MAX_ROOMS then
			break
		end

		local x1 = math.random(1, CONFIG.FLOOR_SIZE)
		local y1 = math.random(1, CONFIG.FLOOR_SIZE)

		local x2 = x1 + math.random(CONFIG.MIN_ROOM_SIZE, CONFIG.MAX_ROOM_SIZE)
		local y2 = y1 + random_sign() * math.random(CONFIG.MIN_ROOM_SIZE, CONFIG.MAX_ROOM_SIZE)

		if self:checkBetween(x1 + CONFIG.ROOM_PADDING * math.sign(x1 - x2), x2 + CONFIG.ROOM_PADDING * math.sign(x2 - x1), y1 + CONFIG.ROOM_PADDING * math.sign(y1 - y2), y2 + CONFIG.ROOM_PADDING * math.sign(y2 - y1), function(cell): boolean
				return cell and cell.Content == "WALL"
			end) then

			self:checkBetween(x1, x2, y1, y2, function(cell)
				if cell then
					cell.Content = nil
				end
				
				return true
			end)
			self.room_count += 1

			table.insert(rooms, {(x1 + x2) // 2, (y1 + y2) // 2})

		end
	end
	if #rooms > 0 then
		self.agent:teleportTo(table.unpack(rooms[#rooms]))
	end

	return rooms
end

function Class.tunnelAsync(self: Class, x: number, y: number)

	local pathresult = self.agent:pathfind(x, y, self.agentParams)

	if pathresult.reached then
		for _, v in pathresult.history do
			v.Content = nil
		end
	else
		warn("path not found")
	end
	task.wait()
end

function Class.connectWaypoints(self: Class, coords: {{number}})
	for _, t in coords do -- connect the rooms
		
		-- The following line averages ~0.01 -> 0.05 seconds
		self:tunnelAsync(t[1],t[2])
	end
end

function Class.generateWalls(self: Class)
	if self._wallsLoaded then return end
	for x, t in self.Content do
		for y, cell in t do
			if cell.Content == "WALL" then
				self:newWall(x,y)
			end
		end
	end
	self._wallsLoaded = true
end

export type Class = typeof(UWFloor.new("1")) & typeof(Floor.new("1", 1))

return UWFloor 