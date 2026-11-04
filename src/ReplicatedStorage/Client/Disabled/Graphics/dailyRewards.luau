--!strict

local GROUP = "Menus"

----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage
local RunService = game:GetService("RunService")

local GraphicsUtilPath = ReplicatedStorage.Client.Graphics.Util
local UIAPI = require(GraphicsUtilPath.UIAPI)

local ThrottleRun = require(ReplicatedStorage.Modules.Utility.ThrottleRun)
local Signal = require(ReplicatedStorage.Modules.Utility.Signal)
local Button = require(ReplicatedStorage.Client.Graphics.Util.Button)
local DailyRewardsData = require(ReplicatedStorage.Modules.Data.DailyRewards)
local SyncedTimeUtil = require(ReplicatedStorage.Modules.Game.SyncedTimeUtil)
local toHHMMSS = require(ReplicatedStorage.Client.Graphics.Util.hhmmssFormat)
----------------------------------------------------------------------------------------------------
local screenGui = UIAPI.load("Daily"):: typeof(ReplicatedStorage.Client.UserInterface.Daily)
local mainframe = screenGui.Main

UIAPI.newGroupedFrame(mainframe, GROUP, screenGui)


local claimSignal = Signal.new()
local framesFolder = mainframe.Holder.Frames

local nextTimestamp = math.huge
local currentDay = 1

local frames = {}
for rewardNumber, stuff in DailyRewardsData.Rewards do
	local frame = framesFolder:FindFirstChild("D" .. rewardNumber):: typeof(script.DailyRewardFrameType)
	frame.TextLabel.Text = "DAY " .. rewardNumber .. " (" .. stuff.Title .. ")"
	frame.ClaimButton.TextLabel.Text = "Locked"
	Button.new(frame.ClaimButton).Activated:Connect(function()
		if currentDay == rewardNumber then
			claimSignal:Fire()
		end
	end)
	
	frames[rewardNumber] = frame
end

Button.new(mainframe.Close).Activated:Connect(function()
	UIAPI.closeGroup("Menus")
end)

local begun: RBXScriptConnection?
local function begin()
	if begun then begun:Disconnect() end
	
	
	for i = currentDay - 1, 1, -1 do
		frames[i].ClaimButton.TextLabel.Text = "CLAIMED"
		frames[i].ClaimButton.Background.Gradient.Color = ColorSequence.new(Color3.new(0.9,0.9,0.9))
	end
	for i = currentDay + 1, #DailyRewardsData.Rewards do
		frames[i].ClaimButton.TextLabel.Text = "LOCKED"
		frames[i].ClaimButton.Background.Gradient.Color = ColorSequence.new(Color3.new(0.9,0.9,0.9))
	end
	frames[currentDay].ClaimButton.Background.Gradient.Color = ColorSequence.new(Color3.new(0.5,1,0.5))
	begun = ThrottleRun(0.1, RunService.RenderStepped, function()
		local remaining = math.max(0,nextTimestamp - SyncedTimeUtil.timestamp())
		
		frames[currentDay].ClaimButton.TextLabel.Text = toHHMMSS(remaining)
		if remaining == 0 then
			(begun:: RBXScriptConnection):Disconnect()
			begun = nil
			frames[currentDay].ClaimButton.TextLabel.Text = "CLAIM"
		end
	end)
end

return {
	toggle = function(bool)
		if bool then
			UIAPI.enableFrame(mainframe)
		else
			UIAPI.closeGroup(GROUP)
		end
	end,
	setCurrentDay = function(dayNum: number, newTimestamp: number)
		
		currentDay = dayNum
		nextTimestamp = newTimestamp
		
		begin()
	end,
	
	claimRequest = claimSignal,
}