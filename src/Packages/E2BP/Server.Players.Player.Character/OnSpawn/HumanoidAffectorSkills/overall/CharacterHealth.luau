return function(chumanoid, level: number)
	chumanoid:setAddedStats("lv_overall_hp", {MaxHealth = level * 2})
end