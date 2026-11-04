local E = game.ReplicatedStorage.Remotes.MainE

local LocalPlayer = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera:: Camera
local Mouse = LocalPlayer:GetMouse()

local SelectedHighlight = script.Selected
local HoverHighlight = script.Selectable

local E = game.ReplicatedStorage.Remotes.MainE

local fxFolder = workspace:WaitForChild("fx", 30)
local EntityFolder = workspace:WaitForChild("Entities", 30)

SelectedHighlight.Parent = fxFolder
HoverHighlight.Parent = fxFolder

local SelectionRaycastParameters = RaycastParams.new()
SelectionRaycastParameters.FilterType = Enum.RaycastFilterType.Exclude

-- Updates the raycast filter to exclude the local player's latest character 
local function onCharacterAdded(char)
	
	SelectionRaycastParameters.FilterDescendantsInstances = {
		fxFolder,
		char,
	}
end

if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)


local REACH = 32

local function GetMouseTarget(): Model?
	
	local MouseHitPos = Mouse.Hit.Position
	local CameraPos = Camera.CFrame.Position
	
	if MouseHitPos == CameraPos then return end -- NaN unit vector
	local result: RaycastResult? = workspace:Raycast(CameraPos, (MouseHitPos - CameraPos).Unit * REACH, SelectionRaycastParameters)
	
	if 
		result and
		(
			result.Instance:IsDescendantOf(EntityFolder)
		)
	then
		return result.Instance:FindFirstAncestorOfClass("Model")
	end
end

return {
	input_began = function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			SelectedHighlight.Adornee = HoverHighlight.Adornee
			E:FireServer("Selection", SelectedHighlight.Adornee)
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			SelectedHighlight.Adornee = nil
			E:FireServer("Selection", SelectedHighlight.Adornee)
		end
	end,

	input_ended = function(input: InputObject)
	end,
	
	render_stepped = function(dt: number)

		local target = GetMouseTarget()
		
		-- HHL Adornee:
		
		-- SHL Adornee 	| target	 	| HHL Adornee	| Logic
		-- nil			| nil			| nil			| No target, no hover 
		-- nil			| <arb>			| target		| target isn't selection, hover
		-- <arb>		| nil			| nil			| No target, no hover
		-- <arb>		| SHL Adornee	| nil			| Target is already selected, no hover
		
		HoverHighlight.Adornee = SelectedHighlight.Adornee ~= target and target or nil
	end,
	
	input_hints = {
		[Enum.UserInputType] = {
			[Enum.UserInputType.MouseButton1] = "Select";
		}
	},
}
