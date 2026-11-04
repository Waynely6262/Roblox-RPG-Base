local OnChangeFunctions = {}

for _, v in script:GetChildren() do
	local t = {}
	OnChangeFunctions[v.Name] = t
	for _, vv in v:GetChildren() do
		t[vv.Name] = require(vv)
	end
end

local Skills = require(game.ServerScriptService.Root.Players.Skills)
local Entities = require(game.ServerScriptService.Root.World.Entities)

Skills.LevelChanged:Connect(function(player: Player, skillName: string, level: number)
	
	local chum = Entities.getHumanoid(player)
	
	if not chum then return end
	if OnChangeFunctions[skillName] then
		for _, fn in OnChangeFunctions[skillName] do
			fn(chum, level)
		end
	end
end)

return function(player: Player, chum: Entities.CustomHumanoid)
	
	for skillName, skill_fns in OnChangeFunctions do
		local level = Skills.getSkillLevel(player, skillName)
		for _, fn in skill_fns do
			fn(chum, level)
		end
	end
end