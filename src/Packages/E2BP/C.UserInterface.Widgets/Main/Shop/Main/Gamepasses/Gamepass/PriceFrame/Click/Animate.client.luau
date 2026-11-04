local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game.ReplicatedStorage
local Modules = ReplicatedStorage.Modules
local Utilities = require(Modules.Utilities)

local TextButton = script.Parent
local Frame = script.Parent.Parent

if not Frame then
	warn("Frame not found!")
	return
end

if not TextButton then
	warn("TextButton not found!")
	return
end


local UIScale = Frame:FindFirstChild("Scale")

function AnimateButton(TargetScale, TweenTime)
	local TweenInfoData = TweenInfo.new(TweenTime, Enum.EasingStyle.Back)

	TweenService:Create(UIScale, TweenInfoData, {
		Scale = TargetScale
	}):Play()
end

TextButton.MouseEnter:Connect(function()
	AnimateButton(1.06, 0.13)
	Utilities.Audio.PlayAudio("Hover")
end)

TextButton.MouseLeave:Connect(function()
	AnimateButton(1, 0.13)
end)

TextButton.MouseButton1Down:Connect(function()
	AnimateButton(0.94, 0.13)
end)

TextButton.MouseButton1Up:Connect(function()
	AnimateButton(1.06, 0.13)
end)

TextButton.MouseButton1Click:Connect(function()
	Utilities.Audio.PlayAudio("Click")
end)
