return function(chumanoid, level: number)
	if level > 0 then
		chumanoid:setAddedStats("U_Attacker", {Damage = level})
	end
end