local TweenService = game:GetService("TweenService")
local Icon = script.Parent.Parent

function animateButton(rotation)
	TweenService:Create(Icon, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
		Rotation = rotation
	}):Play()
end

script.Parent.MouseEnter:Connect(function()
	animateButton(-15)
end)
script.Parent.MouseLeave:Connect(function()
	animateButton(0)
end)
script.Parent.MouseButton1Down:Connect(function()
	animateButton(15)
end)
script.Parent.MouseButton1Up:Connect(function()
	animateButton(0)
end)