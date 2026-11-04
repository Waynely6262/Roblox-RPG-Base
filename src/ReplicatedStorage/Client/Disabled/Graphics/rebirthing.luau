--!strict

----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")

local Widget = require(ReplicatedStorage.Client.Graphics.Util.Widget)
local Signal = require(ReplicatedStorage.Modules.Utility.Signal)
local Button = require(ReplicatedStorage.Client.Graphics.Util.Button)

local RebirthData = require(ReplicatedStorage.Modules.Data.Rebirths)
----------------------------------------------------------------------------------------------------
local RebirthGui = ReplicatedStorage.Client.UserInterface.Rebirths.Main
local ClaimButton = RebirthGui.Holder.ClaimButton
local Contents = RebirthGui.Holder.Contents

local RebirthWidget = Widget.new(ReplicatedStorage.Client.UserInterface.Rebirths, RebirthGui)
RebirthWidget:Toggle(false)

local RebirthHolders: {[string]: typeof(script.Template)} = {}

for _, RebirthUnit in Contents:GetChildren() do
	if RebirthUnit:IsA("GuiObject") then
		RebirthHolders[RebirthUnit.Name] = RebirthUnit
	end
end

Button.new(RebirthGui.Close).Activated:Connect(function()
	RebirthWidget:Toggle(false)
end)


local attemptRebirthSignal = Signal.new()
Button.new(ClaimButton).Activated:Connect(function()
	attemptRebirthSignal:Fire()
end)

local PROGRESS_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

return {
	toggle = function(enabled: boolean?): boolean
		return RebirthWidget:Toggle(enabled)
	end,
	setNextRebirth = function(total: number)
		
		for component, RebirthHolder in RebirthHolders do
			local quota = RebirthData.Requirements[component].getNextQuota(total)
			RebirthHolder.DescriptionLabel.Text = RebirthData.Requirements[component].getDescription(quota)
			RebirthHolder.ProgressLabel.Text = "0/" .. quota
			TweenService:Create(
				RebirthHolder.BackgroundProgressBar.ProgressBar,
				PROGRESS_INFO,
				{Size = UDim2.fromScale(0, 1)}
			):Play()
		end
		
	end,
	
	setComponentProgress = function(component: string, progress: number, total: number)
		local percent = math.min(progress / total,1)
		RebirthHolders[component].ProgressLabel.Text = progress .. "/" .. total
		TweenService:Create(
			RebirthHolders[component].BackgroundProgressBar.ProgressBar,
			PROGRESS_INFO,
			{Size = UDim2.fromScale(percent, 1)}
		):Play()
	end,
	
	setVisible = function(bool: boolean)
		ClaimButton.Visible = bool
	end,
	
	getVisible = function()
		return ClaimButton.Visible
	end,
	attemptRebirth = attemptRebirthSignal,
}