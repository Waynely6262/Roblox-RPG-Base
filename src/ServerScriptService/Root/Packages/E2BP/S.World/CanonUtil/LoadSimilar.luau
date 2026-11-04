--!strict
local WorldModulePath = game.ServerScriptService.Root.World
local Floor = require(WorldModulePath.Floor)
local Spawner = require(WorldModulePath.Spawner)
local Roller = require(WorldModulePath.RNGRoller)
local TickUpdate = require(WorldModulePath.TickUpdate)

return {
	init = function(script: Instance)
		
		local src = script:FindFirstChild("src")
		local self: Floor.Class
		
		if src then
			self = Floor.fromString(script.Name, script:GetAttribute("_n"), require(src))
		else
			self = Floor.new(script.Name, script:GetAttribute("_n"))
		end
		
		-- note that spawners are also added through src loading. Make sure to disable any manual spawner building if it is saved within.
		
		local MapTemplate = script:FindFirstChildWhichIsA("Model")
		if MapTemplate then
			local Map = MapTemplate:Clone()
			Map:PivotTo(CFrame.new(self.center_point - Vector3.yAxis * 0.5))
			self.EntityGenManager:register(Map)
			
			-- At the time of writing this, the PrimaryPart is used to pivot the model.
			-- Once the model is pivoted, the primary part serves as a redundant floor,
			-- in which case it should be removed.
			
		end
		return self
	end,
	
	prebuild = function(self: Floor.Class)
		local spawnerCapacity = 0

		for _, v in self.Spawners do
			spawnerCapacity += v.max or 0
		end

		-- Prebuild structures & entities
		for i = 1, spawnerCapacity do 
			TickUpdate(self)
		end
	end,
}

