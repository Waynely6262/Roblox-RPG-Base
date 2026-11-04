return function(chumanoid, level: number)
	if level > 0 then
		chumanoid:setAddedStats("U_MovingTarget", {Dodge = level * 0.08})
	end
end