--!strict

-- Used to despawn elements after a certain amount of time of existence

local Despawnables = {}
local CONFIG = require(game.ReplicatedStorage.Modules.Game.Config)
local Teams = require(game.ServerScriptService.Root.Other.Teams)

local DespawnablesTeam = Teams.get("Despawnables")

local TerrainRaycast = RaycastParams.new()
TerrainRaycast.FilterType = Enum.RaycastFilterType.Exclude
TerrainRaycast.FilterDescendantsInstances = {
	Teams.get("Despawnables"):getFolder();
	Teams.get("Entities"):getFolder();
	Teams.get("fx"):getFolder();
}

function Despawnables.new(position: Vector3, template: Model, duration: number?)

	local new = template:Clone()
	
	local lv = Vector3.yAxis
	
	local raycastResult = workspace:Raycast(position, Vector3.new(0, -100, 0), TerrainRaycast)
	if raycastResult then
		position = raycastResult.Position
		lv = raycastResult.Normal
	end
	
	local cf, size = new:GetBoundingBox()
	
	local offsetMagnitude = size.Z
	
	local finalPos = position + offsetMagnitude * lv
	
	new:PivotTo(CFrame.new(finalPos, finalPos + lv) * CFrame.Angles(0, math.random() * 2 * math.pi, 0))
	
	
	DespawnablesTeam:addChild(new)
	
	local handle = new:FindFirstChild("Handle"):: BasePart or new:FindFirstChildWhichIsA("BasePart"):: BasePart

	handle.Anchored = true
	
	task.delay(duration or CONFIG.ITEM_LIFETIME, function()
		
		--TODO.ADD_CHECK_IF_ON_A_SAFE_TILE?
		new:Destroy()
	end)
	
	return new, handle
end

function Despawnables.task(new: Model, duration: number?)

	DespawnablesTeam:addChild(new)

	local handle = new:FindFirstChild("Handle"):: BasePart or new:FindFirstChildWhichIsA("BasePart"):: BasePart

	handle.Anchored = true

	task.delay(duration or CONFIG.ITEM_LIFETIME, function()

		--TODO.ADD_CHECK_IF_ON_A_SAFE_TILE?
		new:Destroy()
	end)

	return new, handle
end

return Despawnables