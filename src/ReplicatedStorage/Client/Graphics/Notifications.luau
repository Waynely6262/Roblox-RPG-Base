local DEFAULT_DURATION = 5

local TypeInfo = {
	Any = {
		TextColor = Color3.new(1,1,1);
		TextStrokeColor = Color3.new(0.5,0.5,0.5);
	};
	Success = {
		TextColor = Color3.new(0.5,1,0.5);
		TextStrokeColor = Color3.new(0.2,0.5,0.2);
	};
	Failure = {
		TextColor = Color3.new(1,0.5,0.5);
		TextStrokeColor = Color3.new(0.5,0.2,0.2);
	};
	Warning = {
		TextColor = Color3.new(1,1,0.5);
		TextStrokeColor = Color3.new(0.5,0.25,0.2);
	}
}

local Levels = {
	TypeInfo.Success;
	TypeInfo.Any;
	TypeInfo.Warning;
	TypeInfo.Failure;
}


local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")

local NotificationsUI = ReplicatedStorage.Client.UserInterface.Notifications.Notifications
local Template = script.Template

local TEMPLATE_ORIGINAL_SIZE = Template.Size


local info1
local textInfoIn = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local textInfoOut = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local infoIn = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local infoOut = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

return function(NotificationText, Level: number)
	task.defer(function()
		local NotificationInstance = Template:Clone()

		NotificationInstance.Label.TextTransparency = 1
		NotificationInstance.Label.UIStroke.Transparency = 1
		NotificationInstance.Size = UDim2.new()
		NotificationInstance.Parent = NotificationsUI

		NotificationInstance.Label.Text = NotificationText
		NotificationInstance.Label.TextColor3 = Levels[Level].TextColor
		NotificationInstance.Label.UIStroke.Color = Levels[Level].TextStrokeColor

		local ShowTween = TweenService:Create(NotificationInstance, infoIn, {Size = TEMPLATE_ORIGINAL_SIZE})
		local FadeInText = TweenService:Create(NotificationInstance.Label, textInfoIn, {TextTransparency = 0})
		local FadeInStroke = TweenService:Create(NotificationInstance.Label.UIStroke, textInfoIn, {Transparency = 0})

		ShowTween:Play()
		FadeInText:Play()
		FadeInStroke:Play()

		task.wait(DEFAULT_DURATION)

		local HideTween = TweenService:Create(NotificationInstance, infoOut, {Size = UDim2.new()})
		local FadeOutText = TweenService:Create(NotificationInstance.Label, textInfoOut, {TextTransparency = 1})
		local FadeOutStroke = TweenService:Create(NotificationInstance.Label.UIStroke, textInfoOut, {Transparency = 1})

		FadeOutText:Play()
		FadeOutStroke:Play()
		HideTween:Play()

		task.wait(0.2)

		NotificationInstance:Destroy()
	end)
end
