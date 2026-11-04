
for _, v in game.Selection:Get() do
	if not v:IsA("Model") then continue end
	local pivot: CFrame = v.WorldPivot
	
	local components = {pivot:GetComponents()}
	components[2] = 0
	v.WorldPivot = CFrame.new(table.unpack(components))
	
	if v.PrimaryPart then
		warn(v:GetFullName(), " has a primary part")
		v.PrimaryPart = nil
	end
end