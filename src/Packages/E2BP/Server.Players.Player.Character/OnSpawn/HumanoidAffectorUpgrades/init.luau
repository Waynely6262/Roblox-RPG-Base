local OnChangeFunctions = {}

for _, v in script:GetChildren() do
	local t = {}
	OnChangeFunctions[v.Name] = t
	for _, vv in v:GetChildren() do
		t[vv.Name] = require(vv)
	end
end

local Upgrades = require(game.ServerScriptService.Root.RemoteReceivers.Upgrades)
local Entities = require(game.ServerScriptService.Root.World.Entities)

Upgrades.LevelChanged:Connect(function(player: Player, upgradeName: string, level: number)

	local chum = Entities.getHumanoid(player)

	if chum and OnChangeFunctions[upgradeName] then
		for _, fn in OnChangeFunctions[upgradeName] do
			fn(chum, level)
		end
	end
end)

return function(player: Player, chum: Entities.CustomHumanoid)
	
	for upgradeName, skill_fns in OnChangeFunctions do
		local level = Upgrades.getUpgradeLevel(player, upgradeName)
		for _, fn in skill_fns  do
			fn(chum, level)
		end
	end
end