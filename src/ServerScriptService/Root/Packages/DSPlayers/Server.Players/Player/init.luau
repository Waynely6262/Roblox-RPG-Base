local Players: Players = game:GetService("Players")
Players.CharacterAutoLoads = false

local Giver = require(game:GetService("ServerScriptService").Root.Utils.Giver)
local Profiles = require(game:GetService("ServerScriptService").Root.Players.Profiles)

local character = require(script.Character)


local modules = {}


for _, v in script:GetChildren() do
	if v:IsA("ModuleScript") then
		pcall(function()
			table.insert(modules, require(v))
		end)
	end
end

return function(player: Player)
	
	for _, m in modules do
		task.spawn(m, player)
	end
	
	-- only handles the first load
	
	player:LoadCharacterAsync()
	
	task.defer(function()
		while player.Parent do
			local dt = task.wait(20)
			if not player.Parent then break end
			Giver.addPlayerStats(player, "TimeSpentTotal", dt)
		end
	end)
end