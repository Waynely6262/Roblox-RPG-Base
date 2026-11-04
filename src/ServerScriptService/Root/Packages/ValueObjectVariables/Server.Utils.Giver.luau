--!strict
local Finder = require(game.ReplicatedStorage.Modules.Utility.Finder)
local Profiles = require(game:GetService("ServerScriptService").Root.Players.Profiles)
local Giver = {}

local overallstatsTranslation = {
	GiveCash = "CashGainedTotal";
	TakeCash = "CashSpentTotal";
	GiveWins = "TotalWins";
	GiveJumps = "TotalJumps";
	GiveDistance = "DistanceTravelled";
	GiveXP = "TotalXP";
}


-- Statistics only go up!!
-- Increments to Statistics are always floored 
function Giver.addPlayerStats(player: Player, key: string, value: number)
	local s,r = pcall(function()
		local profileDataStatistics = Profiles[player].Data.Statistics

		profileDataStatistics[key] += math.floor(value)
	end)

	if not s then
		warn("Unable to add " .. value .." " .. key .. " to " .. player.Name .. "'s statistics:", r)
	end
end

function Giver.tryAddPlayerStats(player: Player, modType: "Give" | "Take", statName: string, amt: number)
	
	
	local key = overallstatsTranslation[modType .. statName]:: string?
	if key then
		Giver.addPlayerStats(player, key, amt)
	end
end


function Giver.Give(player, mainHeader, statName, amt): (boolean | nil)
	local thing = Finder.followPathAsync(player, mainHeader, statName):: NumberValue
	thing.Value += amt
	
	Giver.tryAddPlayerStats(player, "Give", statName, amt)
	return true
end

function Giver.Take(player, mainHeader, statName, amt: number, minimumValue): (boolean | nil)
	minimumValue = minimumValue or 0
	
	local thing = Finder.followPathAsync(player, mainHeader, statName):: NumberValue
	if thing.Value - amt >= minimumValue then
		thing.Value -= amt
		Giver.tryAddPlayerStats(player, "Take", statName, amt)
		return true
	end
	return false
end

function Giver.NewVariable(player, newthingType, newthingValue, newthingName, ...: string | nil): Instance
	
	local folder = Finder.followPathAsync(player,...):: Folder
	
	local existing = folder:FindFirstChild(newthingName)
	
	if existing then
		return existing
	end
	local bv = Instance.new(newthingType)
	bv.Name = newthingName;
	bv.Value = newthingValue
	bv.Parent = folder
	
	return bv
end

return Giver