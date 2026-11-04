--!strict
type FloorContent = {
	{
		{
			Content: string,
			Health: number,
		}
	}
}

local HttpService = game:GetService("HttpService")

local CONFIG = require(game.ReplicatedStorage.Modules.Game.Config)
--TODO: Migrate these variables to CONFIG -- ?What variables am I talking about idk

local EntityGenManager = require(script.Parent.EntityGenManager)
local SpiralCoord = require(script.SpiralCoordinate)
local Entities = require(script.Parent.Entities)
local Cell = require(script.Cell)

local Class = {}
Class.__index = Class

local Floor = {}
Floor.Class = Class



function Class.CellToWorldSpace(self: Class, x: number,y: number): Vector3
	return self.origin:: Vector3 + Vector3.new(x * CONFIG.TILE_SIZE, 0, y * CONFIG.TILE_SIZE)
end

function Class.WorldSpaceToCell(self: Class, v: Vector3): Cell.Cell?
	v -= self.origin
	local x,y = math.round(v.X / CONFIG.TILE_SIZE), math.round(v.Z / CONFIG.TILE_SIZE)
	
	if x < 1 or y < 1 or x > CONFIG.FLOOR_SIZE or y > CONFIG.FLOOR_SIZE then
		warn(x,y)
		return nil
	end
	
	return self.Content[x][y]
end

-- QUERIES
function Class.findOpenSpace(self: Class, padding: number?, brute_force: boolean?, x0: number?, y0: number?, x1: number?, y1: number?): (Vector3?, Cell.Cell?)
	
	local padding = padding or 0
	
	assert(padding >= 0 and padding % 1 == 0, "Invalid CONFIG.ROOM_PADDING (whole numbers only)")
	
	local x, y = 1,1
	
	local minx = (x0 or 1) + padding
	local maxx = (x1 or CONFIG.FLOOR_SIZE) - padding
	if minx > maxx then warn("Region x is too small") return nil, nil end
	
	local miny = (y0 or 1) + padding
	local maxy = (y1 or CONFIG.FLOOR_SIZE) - padding
	if miny > maxy then warn("Region y is too small") return nil, nil end
	
	for _ = 1, math.min((maxy - miny) * (maxx - minx), 1000) do
		
		x = math.random(minx, maxx)
		y = math.random(miny, maxy)
		
		local invalid
		
		for xp = x - padding, x + padding do
			for yp = y - padding, y + padding do
				if self.Content[xp][yp].Content ~= nil then
					invalid = true
					break
				end
			end
		end
		if not invalid then			
			return self:CellToWorldSpace(x,y), self.Content[x][y]:: Cell.Cell
		end
	end
	if brute_force then
		for x = minx, maxx do
			for y = miny, maxy do
				
				local invalid
				
				for xp = x - padding, x + padding do
					for yp = y - padding, y + padding do
						if self.Content[xp][yp].Content ~= nil then
							invalid = true
							break
						end
					end
				end
				
				if not invalid then
					return self:CellToWorldSpace(x,y), self.Content[x][y]:: Cell.Cell
				end
			end
		end
	end
	return nil, nil
end

-- use this function loop from (x1,y1) to (x2, y2) and check each cell in between these two points, inclusive.
function Class.checkBetween(self: Class, x1, x2, y1, y2, func): boolean
	
	for x = x1, x2, x1 == x2 and 1 or math.sign(x2 - x1) do
		for y = y1, y2, y1 == y2 and 1 or math.sign(y2 - y1) do

			if not func(self.Content[x] and self.Content[x][y]) then
				return false
			end
		end
	end
	
	return true
end

-- /QUERIES

-- LOADING

local border_constant = CONFIG.FLOOR_SIZE * CONFIG.TILE_SIZE / 2


local GroundTemplate: BasePart do
	GroundTemplate = Instance.new("Part")
	GroundTemplate.Size = Vector3.new(border_constant * 2, CONFIG.TILE_SIZE, border_constant * 2)
	GroundTemplate.Anchored = true

	local Texture = Instance.new("Texture")
	Texture.Parent = GroundTemplate
	Texture.Face = Enum.NormalId.Top
end

local BorderTemplate: BasePart do
	BorderTemplate = Instance.new("Part")
	BorderTemplate.Anchored = true
	BorderTemplate.Material = Enum.Material.ForceField
	BorderTemplate.Size = Vector3.new(border_constant * 2, CONFIG.MAX_WALL_HEIGHT, CONFIG.TILE_SIZE)
end

function Class.Load(self: Class)
	self.IsLoaded = true
	self.EntityGenManager:Load()
end

function Class.Unload(self: Class)
	self.IsLoaded = false
	self.EntityGenManager:Unload()
end

function Class.insertSpawner(self: Class, spawner: any)
	table.insert(self.Spawners, spawner)
	
	if CONFIG.IS_STUDIO then
		local P = Instance.new("Part")
		
		local pos0 = self:CellToWorldSpace(spawner.x0 or 1, spawner.y0 or 1)
		local pos1 = self:CellToWorldSpace(spawner.x1 or CONFIG.FLOOR_SIZE, spawner.y1 or CONFIG.FLOOR_SIZE)
		P.Position = pos0:Lerp(pos1, 0.5)
		P.Size = (pos1 - pos0) + Vector3.new(0, 100, 0)
		P.Anchored = true
		P.CanCollide = false
		P.CanQuery = false
		P.CanTouch = false
		P.Parent = workspace.fx
		P.Material = Enum.Material.ForceField
		P.Color = Color3.new(0.5,1,0.5)
	end
	
end

local floorYOffset = CONFIG.TILE_SIZE* 0.5
function Class.loadBase(self: Class)

	-- floors go downward, so negate everything
	-- floors start from 1 so subtract once
	-- the ground is below the walls so subtract tile size
	-- the floor has a thickness and its pivot is at center so subtract half its size

	local Ground = GroundTemplate:Clone()
	Ground.Position = Vector3.new(self.center_point.X, -CONFIG.TILE_SIZE, self.center_point.Z)
	Ground.Parent = workspace.Map
	
	self.EntityGenManager:register(Ground)
	
	--TODO: because the borders are only one tile-size larger, this offset is needed. This cuts off walls at the edge, but it's an affordable temporary fix. Fix if desired
	local offset = Vector3.new(CONFIG.TILE_SIZE*0.5, CONFIG.MAX_WALL_HEIGHT/2 - floorYOffset, CONFIG.TILE_SIZE*0.5)
	
	for _, place in {
		Vector3.new(2,0,1);
		Vector3.new(0,0,1);
		Vector3.new(1,0,2);
		Vector3.new(1,0,0);
		} do

		local pos = self.origin + Vector3.new(place.X * border_constant, 0, place.Z * border_constant)

		local newBorder = BorderTemplate:Clone()

		newBorder:PivotTo(CFrame.new(pos, self.center_point) + offset)

		self.EntityGenManager:register(newBorder)
	end
	

end

function Class.setSpawnCell(self: Class, x: number, y: number)
	if self.default_spawn_cell then
		self.default_spawn_cell.Content = nil
	end
	self.default_spawn_cell = self.Content[x][y];
	(self.default_spawn_cell:: Cell.Cell).Content = "preferred_spawn_cell"
	
end

function Class.toString(self: Class)
	
	local criticalInfo = {
		len_x = CONFIG.FLOOR_SIZE;
		len_y = CONFIG.FLOOR_SIZE;
		spawners = self.Spawners;
		spawn_cell = self.default_spawn_cell and {self.default_spawn_cell.x, self.default_spawn_cell.y};
	}
	
	local str = ""
	
	for x = 1, CONFIG.FLOOR_SIZE do
		for y = 1, CONFIG.FLOOR_SIZE do
			-- transient tag
			local content = self.Content[x][y].Content:: string?
			if not content or (content):sub(1, 2) == "t." then content = "" end
			str = str .. `{content}>>`
		end
	end
	
	
	return HttpService:JSONEncode(criticalInfo) .. "|||" .. str
end

function Floor.new(name: string?, l: number)
	
	-- generate 2d array
	local floorContentTable = {}:: {{Cell.Cell}}
	for x = 1, CONFIG.FLOOR_SIZE do
		floorContentTable[x] = {} 
		for y = 1, CONFIG.FLOOR_SIZE do
			floorContentTable[x][y] = Cell.new(x,y, nil)
		end
	end
	
	local spacing_x, spacing_y = SpiralCoord(l)
	
	local self = setmetatable({
		
		Content = floorContentTable;
		EntityGenManager = EntityGenManager.new(l);
		Name = name or "undefined";
		Number = l;
		IsLoaded = false;
		origin = Vector3.new(spacing_x * CONFIG.LOCATION_SPACING, 0, spacing_y * CONFIG.LOCATION_SPACING);
		Spawners = {}:: {any};
		attributes = {}:: {[string]: any};
		default_spawn_cell = nil:: Cell.Cell?
		
	}, Class)
	
	self.center_point = self.origin + Vector3.new(border_constant, 0, border_constant)
	
	self:loadBase()
	
	return self
end

function Floor.fromString(name: string, l: number, str: string)
	
	local self = Floor.new(name, l)
	
	local criticalInfoJSON, data = table.unpack(string.split(str, "|||"))
	
	local info: CriticalInfo = HttpService:JSONDecode(criticalInfoJSON)
	
	local cellContents = data:split(">>")
	
	for x = 1, info.len_x do
		self.Content[x] = self.Content[x] or {}
		for y = 1, info.len_y do
			local content = cellContents[y + ((x-1) * info.len_y)]
			self.Content[x][y] = Cell.new(x,y, content ~= "" and content or nil)
		end
	end
	
	self.Spawners = info.spawners:: {any} -- TODO:Check_if_this_causes_issues;any_metatable_of_spawners_will_be_gone
	for _, v in self.Spawners do
		v.count = 0
	end
	if info.spawn_cell then
		self:setSpawnCell(info.spawn_cell[1], info.spawn_cell[2])
	end
	
	return self
end


type CriticalInfo = {
	len_x: number,
	len_y: number,
	spawners: {any},
	spawn_cell: {number}?,
}

export type Class = typeof(Floor.new(nil, -1))

return Floor





