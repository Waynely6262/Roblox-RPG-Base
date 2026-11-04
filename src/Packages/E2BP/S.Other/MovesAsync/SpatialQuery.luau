--!strict
local Spatial = {}

Spatial.Parameters = OverlapParams.new()

function Spatial.query(pos: Vector3, radius: number, Params: OverlapParams?): {BasePart}
	return workspace:GetPartBoundsInRadius(pos, radius, Params)
end

function Spatial.fromTo(d0: Vector3, d1: Vector3, radius: number, Params: OverlapParams?): {BasePart}
	
	local p = Instance.new("Part")

	
	local pos = d0:Lerp(d1, 0.5)
	
	local CF = CFrame.new(pos, d1)
	
	local Size = Vector3.new(radius, radius, (d1 - d0).Magnitude)
	
	
	return workspace:GetPartBoundsInBox(CF, Size, Params)
end

function Spatial.fromPartBounds(p: BasePart, Params: OverlapParams?): {BasePart}
	return workspace:GetPartsInPart(p, Params)
end

return Spatial
