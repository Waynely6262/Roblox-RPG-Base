--!strict

local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera

local Player = game:GetService("Players").LocalPlayer

local latestValidCFrame = CFrame.new(Vector3.zero, Vector3.yAxis)

local HRP: BasePart?

Player.CharacterAdded:Connect(function(char)
	HRP = char:WaitForChild("HumanoidRootPart")
end)

Player.CharacterRemoving:Connect(function()
	HRP = nil
end)

local Height = 10
local ZOffset = 5

RunService:BindToRenderStep("2D Pointer", 301, function()
	
	Camera.CFrame = HRP and CFrame.new(Vector3.new(HRP.Position.X, HRP.Position.Y + Height, HRP.Position.Z + ZOffset), HRP.Position) or latestValidCFrame
	
	latestValidCFrame = Camera.CFrame
	
end)