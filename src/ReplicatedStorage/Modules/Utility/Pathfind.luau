--!strict
local PathfindingService = game:GetService("PathfindingService")

local ThrottleRun = require(game.ReplicatedStorage.Modules.Utility.ThrottleRun)

local AgentParams = {
	AgentRadius = 4,
	AgentHeight = 6,
	AgentCanJump = true,
	WaypointSpacing = 7;
	Costs = {
		Road = 6;
		Alley = 10;
		Border = math.huge;
	}
}
--typechecking
local pcall = pcall:: ((...any) -> (any),...any) -> (boolean, any)

local threads = setmetatable({}, {__mode = "k"})

local function stop(Rig: Model)
	local thread = threads[Rig] 
	
	if thread then
		coroutine.close(thread)
	end
	
	local Humanoid = Rig:FindFirstChildWhichIsA("Humanoid"):: Humanoid
	if not Humanoid then warn("no humanoid") return end
	Humanoid:Move(Vector3.zero)
end

local function pathfindInterruptable(Rig: Model, endPos: Vector3)
	
	threads[Rig] = coroutine.running()
	local Path: Path = PathfindingService:CreatePath(AgentParams)
	
	local state = false
	
	local Humanoid = Rig:FindFirstChildWhichIsA("Humanoid"):: Humanoid
	if not Humanoid then warn("No humanoid, can't pathfind") return false end
	local HRP = Rig:WaitForChild("HumanoidRootPart"):: BasePart
	if not HRP then warn("No HumanoidRootPart, can't pathfind") return false end

	if Humanoid:GetState() == Enum.HumanoidStateType.Dead then
		warn("humanoid is dead; can't pathfind with a corpse", Humanoid:GetFullName())
		return false
	end

	local beginPos = Rig:GetPivot().Position

	local s,r = pcall(function()
		Path:ComputeAsync(beginPos, endPos)
	end)

	if not s then
		warn("compute path unsuccessful: " .. r)
		return false
	end

	if Path.Status == Enum.PathStatus.NoPath then
		print("cancelled pathfind due to no path")
		return false
	end


	for _, waypoint: PathWaypoint in Path:GetWaypoints() do
		if waypoint.Action == Enum.PathWaypointAction.Jump then
			Humanoid.Jump = true
		end

		local reached = false
		for i = 1, 4 do

			Humanoid:MoveTo(waypoint.Position)
			
			
			
			reached = Humanoid.MoveToFinished:Wait()

			if reached then
				break
			else
				if i > 2 then
					Humanoid.Jump = true
					--task.wait(.5)
				end

			end


		end
		if not reached then
			return pathfindInterruptable(Rig, endPos)
		end
		
	end
	return true
end

return {
	pathfindInterruptable = pathfindInterruptable;
	stop = stop;
	modifyGlobalAgentParams = function(newAgentParams: {[string]: any})
		AgentParams = newAgentParams
	end;
}
