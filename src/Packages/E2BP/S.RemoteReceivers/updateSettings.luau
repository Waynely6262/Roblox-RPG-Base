local template = require(game.ServerScriptService.Root.Data.DSTemplate)
local Profiles = require(game:GetService("ServerScriptService").Root.Players.Profiles)
return function(player, t: {[string]: any})
	local preferences = Profiles[player].Data.Preferences
	
	for n, v in t do
		if typeof(n) ~= "string" then continue end
		if typeof(v) == typeof(template.Preferences[n]) then
			preferences[n] = v
		else
			warn("type mismatch", n, typeof(v), tostring(v), "expected", typeof(template.Preferences[n]))
		end
	end
	
end