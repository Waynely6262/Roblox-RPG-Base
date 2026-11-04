local UIElement = script.Parent

local Amplitude = -0.05
local Speed = 1.7

local InitialPositionUI = UIElement.Position

local TimeElapsed = 0

game:GetService("RunService").RenderStepped:Connect(function(DeltaTime)
	TimeElapsed = TimeElapsed + DeltaTime
	local SineValue = math.abs(math.sin(TimeElapsed * Speed))
	local Offset = SineValue * Amplitude
	UIElement.Position = InitialPositionUI + UDim2.new(0, 0, Offset, 0)
end)
