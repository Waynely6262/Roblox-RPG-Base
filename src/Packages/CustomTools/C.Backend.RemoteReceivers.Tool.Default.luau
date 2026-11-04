local E = game.ReplicatedStorage.Remotes.MainE

local mouse = game.Players.LocalPlayer:GetMouse()

return {
	input_began = function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			while game.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				E:FireServer("Tool", "click")
				task.wait()
			end
		end
	end,
	
	input_ended = function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			print("unclick")
		end
	end,
	
	input_hints = {
		[Enum.UserInputType] = {
			[Enum.UserInputType.MouseButton1] = "Click";
		}
	},
}