--!strict
local ReplicatedStorage = game.ReplicatedStorage

local QuestData = require(ReplicatedStorage.Modules.Data.Quests)
local QuestGraphics = require(ReplicatedStorage.Client.Graphics.quests)
local Currencies = require(ReplicatedStorage.Client.Graphics.currencies)
local RemoteE = ReplicatedStorage.Remotes.MainE
local Finder = require(ReplicatedStorage.Modules.Utility.Finder)

local player = game:GetService("Players").LocalPlayer:: Player

local coinVB = Finder.followPathAsync(player, "leaderstats", "Cash"):: NumberValue

for questName, methods in QuestData do
	local currentAmtVB = Finder.followPathAsync(player, "Data", questName):: NumberValue
	local beginAmtVB = Finder.followPathAsync(player, "Data", "QuestBegin", questName):: NumberValue
	local questNumberVB = Finder.followPathAsync(player, "Data", "QuestCompletedCounts", questName):: NumberValue

	local currentQuota: number

	local function newQuest(newQuestNumber: number)
		currentQuota = methods.getNextQuota(newQuestNumber)
		QuestGraphics.setQuest(questName, currentQuota)
		Currencies.animateSetCash(coinVB.Value)
	end

	local function refreshQuestProgress(currentAmt: number)
		QuestGraphics.setQuestProgress(questName, currentAmt - beginAmtVB.Value, currentQuota)
	end
	
	questNumberVB.Changed:Connect(newQuest)
	currentQuota = methods.getNextQuota(questNumberVB.Value)
	QuestGraphics.setQuest(questName, currentQuota)
	
	currentAmtVB.Changed:Connect(refreshQuestProgress)
	refreshQuestProgress(currentAmtVB.Value)
	
end

QuestGraphics.claimAllRequest:Connect(function()
	RemoteE:FireServer("completeQuest")
end)

QuestGraphics.claimRequest:Connect(function(questName: string)
	RemoteE:FireServer("completeQuest", questName)
end)

local util = {}

return util