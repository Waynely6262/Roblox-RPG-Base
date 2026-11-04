--!strict
local GROUP = "Menus"
----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")

local UIAPI = require(ReplicatedStorage.Client.Graphics.Util.UIAPI)

local Widget = require(ReplicatedStorage.Client.Graphics.Util.Widget)
local Signal = require(ReplicatedStorage.Modules.Utility.Signal)
local Button = require(ReplicatedStorage.Client.Graphics.Util.Button)

local QuestsData = require(ReplicatedStorage.Modules.Data.Quests)
----------------------------------------------------------------------------------------------------
local Mainframe = ReplicatedStorage.Client.UserInterface.Quests.Main
local Contents = Mainframe.Holder.Contents

UIAPI.newGroupedFrame(Mainframe, GROUP, ReplicatedStorage.Client.UserInterface.Quests)

local ClaimSignal: Signal.Signal<string> = Signal.new()
local questHolders: {[string]: typeof(script.QuestTemplate)} = {}

for _, questUnit in Contents:GetChildren() do
	if questUnit:IsA("GuiObject") then
		questHolders[questUnit.Name] = questUnit:: typeof(script.QuestTemplate)
		Button.new(questUnit.ClaimButton).Activated:Connect(function()
			ClaimSignal:Fire(questUnit.Name)
		end)
	end
end

Button.new(Mainframe.Close).Activated:Connect(function()
	UIAPI.closeGroup(GROUP)
end)


local claimAllSignal = Signal.new()
Button.new(Mainframe.Holder.ClaimButton).Activated:Connect(function()
	claimAllSignal:Fire()
end)

local PROGRESS_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

return {
	claimRequest = ClaimSignal,
	toggle = function(enabled: boolean?): boolean
		return QuestWidget:Toggle(enabled)
	end,
	setQuest = function(quest: string, total: number)
		questHolders[quest].QuestLabel.Text = QuestsData[quest].getDescription(total)
		questHolders[quest].ProgressLabel.Text = "0/" .. total
		TweenService:Create(
			questHolders[quest].BackgroundProgressBar.ProgressBar,
			PROGRESS_INFO,
			{Size = UDim2.fromScale(0, 1)}
		):Play()
		questHolders[quest].ClaimButton.Visible = false
	end,
	
	setQuestProgress = function(quest: string, progress: number, total: number)
		local percent = math.min(progress / total,1)
		questHolders[quest].ProgressLabel.Text = progress .. "/" .. total
		TweenService:Create(
			questHolders[quest].BackgroundProgressBar.ProgressBar,
			PROGRESS_INFO,
			{Size = UDim2.fromScale(percent, 1)}
		):Play()
		questHolders[quest].ClaimButton.Visible = percent >= 1
	end,
	
	claimAllRequest = claimAllSignal,
}