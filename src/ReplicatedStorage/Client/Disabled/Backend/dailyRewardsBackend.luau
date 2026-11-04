--!strict
local ReplicatedStorage = game.ReplicatedStorage

local DailyRewardsData = require(ReplicatedStorage.Modules.Data.DailyRewards)
local SyncedTimeUtil = require(ReplicatedStorage.Modules.Game.SyncedTimeUtil)
local DailyRewardsGraphics = require(ReplicatedStorage.Client.Graphics.dailyRewards)
local Currencies = require(ReplicatedStorage.Client.Graphics.currencies)
local RemoteE = ReplicatedStorage.Remotes.MainE
local Finder = require(ReplicatedStorage.Modules.Utility.Finder)
local notif = require(ReplicatedStorage.Client.Graphics.Notifications)

local player = game:GetService("Players").LocalPlayer:: Player

local coinVB = Finder.followPathAsync(player, "leaderstats", "Cash"):: NumberValue
local dayNumberValueBase: NumberValue = Finder.followPathAsync(player, "Data", "DailyRewards").NextReward:: NumberValue
local nextTimeValueBase: NumberValue = Finder.followPathAsync(player, "Data", "DailyRewards").NextClaimTime:: NumberValue

local function canClaim(): (boolean, number)
	
	local dayNumber = dayNumberValueBase.Value
	local nextTime = nextTimeValueBase.Value -- to account for the second delay

	local now = SyncedTimeUtil.timestamp()
	
	return nextTime <= now, nextTime - now
end

local function claim()
	
	local can, missing = canClaim()
	if can then
		RemoteE:FireServer("Daily")
	else
		notif.Notify("Please wait " .. math.ceil(missing) .. " more seconds.", "Failure")
	end
end

local function dayClaimed(newDay)
	DailyRewardsGraphics.setCurrentDay(newDay,nextTimeValueBase.Value)
	Currencies.animateSetCash(coinVB.Value)
end

dayNumberValueBase.Changed:Connect(dayClaimed)
DailyRewardsGraphics.setCurrentDay(dayNumberValueBase.Value,nextTimeValueBase.Value)

if canClaim() then
	DailyRewardsGraphics.toggle(true)
end

DailyRewardsGraphics.claimRequest:Connect(claim)
return nil