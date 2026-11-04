return function(chumanoid, level: number)
	if level > 0 then
		chumanoid:setAddedStats("U_Vitality", {MaxHealth = level * 25})
	end
end