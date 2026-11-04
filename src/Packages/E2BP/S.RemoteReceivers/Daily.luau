local RE = game.ReplicatedStorage.Remotes.MainF

local notif = require(game.ReplicatedStorage.Client.Graphics.Notifications)
local MarketplaceService = game:GetService("MarketplaceService")
local GroupService = game:GetService("GroupService")
local DailyRewardsData = require(game.ReplicatedStorage.Modules.Data.DailyRewards)
local SyncedTimeUtil = require(game.ReplicatedStorage.Modules.Game.SyncedTimeUtil)

local Finder = require(game.ReplicatedStorage.Modules.Utility.Finder)

return {
	onInvoke = function(player): boolean
		local playerDailyRewardData = Finder.followPathAsync(player, "Data", "DailyRewards")
		
		local dayNumberValueBase = playerDailyRewardData.NextReward
		local nextTimeValueBase = playerDailyRewardData.NextClaimTime
		
		local dayNumber = dayNumberValueBase.Value
		local nextTime = nextTimeValueBase.Value

		local now = SyncedTimeUtil.timestamp()

		if nextTime <= now then
			
			if DailyRewardsData.Rewards[dayNumber].Give(player) then

				dayNumberValueBase.Value = (dayNumber % #DailyRewardsData.Rewards) + 1
				nextTimeValueBase.Value = SyncedTimeUtil.timestamp() + DailyRewardsData.Interval 
				
				notif.NotifyClient(player, "Successfully claimed the rewards for day ".. dayNumber .."!", 1)
				--if player:GetRankInGroup(33738605) > 0 then
				--	DailyRewardsData.Rewards[dayNumber](player)
				--	notif.NotifyClient(player, "You received double rewards for being in our group!", "Success")
				--else
				--	notif.NotifyClient(player, "Join our group for double daily rewards!", "Any")
				--end
				return true
			else
				notif.NotifyClient(player, "Unable to claim your rewards, try again later. Sorry for the inconvenience!", 4)
			end
		else
			notif.NotifyClient(player, "Please wait " .. nextTime - now .. " more seconds.", 4)
		end
	end
}

