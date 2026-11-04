local E = game.ReplicatedStorage.Remotes.MainE

local mouse = game.Players.LocalPlayer:GetMouse()

local Camera = workspace.CurrentCamera

return {
	input_began = function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			E:FireServer("Tool", "click")
		end
	end,
	
	input_ended = function(input: InputObject)
	end,
	
	input_hints = {
		[Enum.UserInputType] = {
			[Enum.UserInputType.MouseButton1] = "Consume";
		}
	},
}