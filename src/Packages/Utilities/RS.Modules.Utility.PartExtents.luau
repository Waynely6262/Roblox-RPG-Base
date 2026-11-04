local p2 = 2 * math.pi
local cos,sin = math.cos, math.sin
local rand = Random.new()
local rn = math.random
@native
local function rs()
	return (0.5 - rn())
end

local F = {
	[Enum.PartType.Block] = function(p)
		local x,y,z = rs(),rs(),rs()
		local s = p.Size
		
		
		return 
			p.Position +
			p.CFrame.LookVector * z * s.Z +
			p.CFrame.UpVector * y * s.Y +
			p.CFrame.RightVector * x * s.X
	end,
	
	[Enum.PartType.Ball] = function(p)
		return p.Position + (rand:NextUnitVector() * math.min(p.Size.X,p.Size.Y,p.Size.Z) * 0.5)
	end,
	
	[Enum.PartType.Cylinder] = function(p)
		local r = math.min(p.Size.Y,p.Size.Z) * 0.5
		local rn_r = rn() * p2
		local y,z = cos(rn_r),sin(rn_r)
		
		return
			p.Position +
			p.CFrame.LookVector * z * r +
			p.CFrame.UpVector * y * r +
			p.CFrame.RightVector * rs() * p.Size.X  
	end,
	
}

F.Block = F[Enum.PartType.Block]
F.Sphere = F[Enum.PartType.Ball]
F.Cylinder = F[Enum.PartType.Cylinder]


return function(p)
	return F[p.Shape](p)
end