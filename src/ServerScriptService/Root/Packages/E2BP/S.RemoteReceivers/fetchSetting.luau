local template = require(game.ServerStorage.DSTemplate)
local Profiles = require(game:GetService("ServerScriptService").Root.Players.Profiles)

return function(player)
	local pf = Profiles[player]
	if pf then
		local data = pf.Data
		if data then
			return data.Preferences
		end
	end
	return template.Preferences
end