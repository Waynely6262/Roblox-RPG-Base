local ScrollPositions = {
	["Egg"] = 0,
	["Bundle"] = 280,
	["Pet"] = 560,
	["Codes"] = 1400,
}

local ShopScroll = script.Parent.Parent.Main
local ScrollBar = script.Parent

for ButtonName, PositionY in pairs(ScrollPositions) do
	local Button = ScrollBar:FindFirstChild(ButtonName)
	if not Button then continue end

	Button.Click.MouseButton1Click:Connect(function()
		game:GetService("TweenService"):Create(
			ShopScroll,
			TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{CanvasPosition = Vector2.new(0, PositionY)}
		):Play()
	end)
end