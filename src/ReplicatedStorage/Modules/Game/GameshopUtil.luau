local Places = require(game.ReplicatedStorage.Modules.Data.Jetpacks)
local Finder = require(game.ReplicatedStorage.Modules.Utility.Finder)
local util = {}

function util.ownsJetpackAsync(jetpackName: string, player: Player)
	assert(typeof(jetpackName) == "string", "GameshopUtil: You need to send me a string, good sir.")
	local PlaceData = Places[jetpackName]

	if PlaceData then
		return Finder.followPathAsync(player, "Data", "OwnedJetpacks"):FindFirstChild(jetpackName) ~= nil
	end
	return false
end

return util