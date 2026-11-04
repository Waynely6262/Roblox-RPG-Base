return function(chumanoid, level: number)
	if level > 0 then
		chumanoid:setAddedStats("U_Precision", {Precision = level * 0.08})
	end
end