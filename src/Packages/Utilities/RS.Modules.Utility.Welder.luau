local welder = {}

function welder.weldSpecified(p1s: {BasePart}, p0: BasePart?, motortype: string?)
	p0 = p0 or p1s[1]
	motortype = motortype or "Weld"
	
	
	for _, p1 in p1s do
		if p1 == p0 then continue end
		local weld = Instance.new(motortype)
		weld.C1 = p1.CFrame:ToObjectSpace(p0.CFrame);
		weld.Name = p1.Name;
		weld.Part0 = p0;
		weld.Part1 = p1;
		weld.Parent = p0;
	end
	
end

function welder.weldAll(m: Instance, abortIfJointFound: boolean)
	local descendants = m:GetDescendants()
	local p1s = {}
	
	for i, v in descendants do
		if v:IsA("BasePart") then
			table.insert(p1s, v)
		elseif v:IsA("JointInstance") then
			if abortIfJointFound then
				return
			end
			warn("Joint detected (may conflict):", v:GetFullName(), debug.traceback())
		end
	end
	
	welder.weldSpecified(p1s)
	
end

return welder