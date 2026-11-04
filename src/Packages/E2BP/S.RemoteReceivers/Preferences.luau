local Finder = require(game.ReplicatedStorage.Modules.Utility.Finder)
local Template = require(game.ServerScriptService.Root.Data.DSTemplate)
local Profiles = require(game:GetService("ServerScriptService").Root.Players.Profiles)

return function(player: Player, settingName: string, value: unknown)
	
	local s: boolean, r: string = pcall(function()
		local playerData = Profiles[player].Data
		local expectedType = typeof(Template.Preferences[settingName])
		
		if typeof(value) ~= expectedType then
			warn("player preferences: type of value did not match expected type", player.Name, "expected:", expectedType, "got", typeof(value))
			return
		end
		playerData.Preferences[settingName] = value
	end)
	
	if not s then
		-- attempt to index nil with ... (ignore this exception)
		if r and not r:find("dex ni") then
			error("player preferences: could not set player preference " .. settingName .. " because " .. tostring(r))
		end
	end
	
end

