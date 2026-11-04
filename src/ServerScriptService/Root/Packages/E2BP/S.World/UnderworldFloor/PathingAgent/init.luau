--!strict
local BinaryHeap = require(script.BinaryHeap)

local Agent = {}
Agent.__index = Agent

local AgentClass = {}

function AgentClass.new(world, x,y)
	local self = setmetatable({
		world = world;
		x = x;
		y = y;
	}, Agent)
	
	return self
end

function Agent:isTrapped(x,y): boolean
	
	return self.world[x][y].Content == "WALL"
end

function Agent:teleportTo(x,y)
	self.x = x
	self.y = y
end

function Agent:digX(n)
	
	for x = self.x, self.x + n, n == 0 and 1 or math.sign(n) do
		self.world[x][self.y].Content = nil
	end
	
end

function Agent:digY(n, func)
	
	for y = self.y, self.y + n, n == 0 and 1 or math.sign(n) do
		self.world[self.x][y].Content = nil
	end 
	
end

export type GridPathfindParameters = {
	Costs: {[string]: number},
	RandomWeightIgnoreChance: number,
	TurningCost: number,

}


local WEIGHT_INCREMENT = 4

function Agent:pathfind(new_x,new_y, Params: GridPathfindParameters)
	
	local Params = Params or {
		Costs = {
			--WALL = -0.1;
			--__null = 1;
		};
		RandomWeightIgnoreChance = 0;
		TurningCost = 0.5;
	}:: GridPathfindParameters
	
	local visited = {}
	
	local jobs: any = BinaryHeap.new({{self.x,self.y,{}, 0, Vector2.new(0,0)}}) -- starting point)

	jobs:setComparator(function(a: {any}, b: {any}): boolean
		return a[4] < b[4]
	end)
	
	local final = Vector2.new(new_x, new_y)
	
	
	local latestHistory = {}
	
	while not jobs:isEmpty() do
		local x,y, history, weight, dir: Vector2 = table.unpack(jobs:pop())
		
		if not (self.world[x] and self.world[x][y]) then continue end
		
		local cell = self.world[x][y]
		
		
		visited[x] = visited[x] or {}
		
		if visited[x][y] then continue end
		
		visited[x][y] = true
		
		history = table.clone(history)
		table.insert(history, cell)
		latestHistory = history
		
		weight = weight or 0
		weight += 1
		
		if cell.Content then
			weight += Params.Costs[cell.Content] or 1
		elseif Params.Costs.__null then
			weight += Params.Costs.__null
		end
		
		if x == new_x and y == new_y then
			return {reached = true, history = history} 
		end		
		
		local desiredDirection = (final - Vector2.new(x,y)).Unit * 2
		
		-- 2 for Params.TurningCost (default value is 1, which makes sure dot product doesn't reduce weight)
		-- 1000 for desiredDirection (basically a large number to only go in an undesired direction when it's the only choice)
		
		weight += WEIGHT_INCREMENT
		
		jobs:insert({x + 1, y, history, weight - Params.TurningCost * dir:Dot(Vector2.xAxis) - desiredDirection:Dot(Vector2.xAxis),Vector2.xAxis})
		jobs:insert({x - 1, y, history, weight - Params.TurningCost * dir:Dot(-Vector2.xAxis) - desiredDirection:Dot(-Vector2.xAxis), -Vector2.xAxis})
		jobs:insert({x, y + 1, history, weight - Params.TurningCost * dir:Dot(Vector2.yAxis) - desiredDirection:Dot(Vector2.yAxis), Vector2.yAxis})
		jobs:insert({x, y - 1, history, weight - Params.TurningCost * dir:Dot(-Vector2.yAxis) - desiredDirection:Dot(-Vector2.yAxis), -Vector2.yAxis})
	end
	return {reached = false, history = latestHistory}
end

return AgentClass