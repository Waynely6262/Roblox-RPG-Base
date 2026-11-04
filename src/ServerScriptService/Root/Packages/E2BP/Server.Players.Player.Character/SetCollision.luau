local CollisionGroups = require(game.ServerScriptService.Root.CollisionGroups)

return function(player, char)
	
	for _,v in char:GetDescendants() do
		if v:IsA("BasePart") then
			(v:: BasePart).CollisionGroup = CollisionGroups.Character
		end
	end
end