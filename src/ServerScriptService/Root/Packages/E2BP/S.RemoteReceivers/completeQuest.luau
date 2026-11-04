--!strict
local Finder = require(game.ReplicatedStorage.Modules.Utility.Finder)

local QuestData = require(game.ReplicatedStorage.Modules.Data.Quests)
--local QuestUtil = require(game.ReplicatedStorage.Modules.Game.QuestUtil)
local Notifs = require(game.ServerScriptService.Root.Notifications)

local function completeAQuest(player: Player, questName: string)
	local currentAmtVB = Finder.followPathAsync(player, "Data", questName):: NumberValue
	local beginAmtVB = Finder.followPathAsync(player, "Data", "QuestBegin", questName):: NumberValue
	local questNumberVB = Finder.followPathAsync(player, "Data", "QuestCompletedCounts", questName):: NumberValue


	local fulfilled = currentAmtVB.Value - beginAmtVB.Value
	local quota = QuestData[questName].getNextQuota(questNumberVB.Value)

	if fulfilled >= quota then

		local rewardValue = QuestData[questName].getReward(questNumberVB.Value)

		local coinVB = Finder.followPathAsync(player, "leaderstats", "Cash"):: NumberValue
		
		coinVB.Value += rewardValue

		questNumberVB.Value += 1
		beginAmtVB.Value = currentAmtVB.Value
		Notifs.NotifyClient(player, "Successfully completed this quest!", "Success")
		return true
	else
		Notifs.NotifyClient(player, "You need " .. quota - fulfilled .. " more " .. questName .. " to complete this quest.", "Failure")
	end
	return false
end

return function(player: Player, questName: string?): boolean
	
	
	if questName then
		return completeAQuest(player, questName)
	else
		for questName: string, _ in QuestData do
			completeAQuest(player, questName)
		end
	end
	
end