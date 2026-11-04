return function(player, char: Model)

	for _,v in char:GetChildren() do
		if v:IsA("Accessory") then
			for _, vv in v:GetDescendants() do
				if vv:IsA("BasePart") then
					vv.CanCollide = false
					vv.CanQuery = false
					vv.CanTouch = false
				end
			end
		end
	end
end