return function(chumanoid, level: number)
	if level > 0 then
		chumanoid:setAddedStats("U_Defender", {Defense = level})
	end
end