local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

local Params: RaycastParams do
	Params = RaycastParams.new()
	Params.FilterDescendantsInstances = {Player.Character}
	Params.FilterType = Enum.RaycastFilterType.Exclude

	Player.CharacterAdded:Connect(function(char)
		Params.FilterDescendantsInstances = {Player.Character}
	end)
end

local Camera = workspace.CurrentCamera

local function mouseVector()
	return (Mouse.Hit.Position - Camera.CFrame.Position).Unit
end

local function getMousePosition()

	local rcVector = mouseVector() * 500

	local result = workspace:Raycast(Camera.CFrame.Position, rcVector, Params)

	return result and result.Position or (Camera.CFrame.Position + rcVector)
end

local function getMouseHit()

	local rcVector = mouseVector() * 500

	local result = workspace:Raycast(Camera.CFrame.Position, rcVector, Params)

	return result and CFrame.new(result.Position, result.Position - result.Normal) or CFrame.new(Camera.CFrame.Position + rcVector)
end

return {
	getMouseHit = getMouseHit;
	getMousePosition = getMousePosition;
}