return function(chumanoid, level: number)
	if level > 0 then
		chumanoid:setAddedStats("U_Critical", {CritChance = level})
	end
end