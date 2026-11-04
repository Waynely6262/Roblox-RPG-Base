local E = game.ReplicatedStorage.Remotes.MainE


return {
	input_began = function(input: InputObject)
		if input.KeyCode == Enum.KeyCode.LeftControl then
			E:FireServer("sprint")
		end
	end,
}
