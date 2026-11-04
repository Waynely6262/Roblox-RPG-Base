if not game:GetService("RunService"):IsStudio() then return nil end
local Tracers = {}

local parent = workspace.fx

function Tracers.Raycast(self: any, pos0: Vector3, ray_vector: Vector3, param: RaycastParams)
	
	local p = Instance.new("Part")
	
	local result = self:Raycast(pos0, ray_vector, param)
	
	local pos1 = result and result.Position or (pos0 + ray_vector)
	
	p.CFrame = CFrame.new(pos0:Lerp(pos1, 0.5), pos0)
	
	p.Size = Vector3.new(0.1,0.1,result and result.Distance or ray_vector.Magnitude)
	
	p.Color = result and Color3.new(0,1,0) or Color3.new(1,1,1)
	p.Material = Enum.Material.Neon
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CastShadow = false
	
	p.Name = "RaycastTracer"
	p.Parent = parent
	task.delay(result and 10 or 1, function()
		p:Destroy()
	end)
	
	return result:: RaycastResult?
end

function Tracers.Spherecast(self: any, pos0: Vector3, radius: number, ray_vector: Vector3, param: RaycastParams)
	
	local p = Instance.new("Part")

	local result = self:Spherecast(pos0, radius, ray_vector, param)

	local pos1 = result and result.Position or (pos0 + ray_vector)

	p.CFrame = CFrame.new(pos0:Lerp(pos1, 0.5), pos0)

	p.Size = Vector3.one * (radius * 2)

	p.Color = result and Color3.new(0,1,0) or Color3.new(1,1,1)
	p.Material = Enum.Material.Neon
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CastShadow = false

	p.Name = "SpherecastTracer"
	p.Parent = parent
	task.delay(result and 10 or 1, function()
		p:Destroy()
	end)

	return result:: RaycastResult?
end

return Tracers