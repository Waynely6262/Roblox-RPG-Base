local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LVSender = require(game.ReplicatedStorage.Client.Backend.SendLookVector)

local E = game.ReplicatedStorage.Remotes.MainE :: RemoteEvent

local player = Players.LocalPlayer
local Mouse = player:GetMouse()

return {
	input_began = function(input: InputObject)
		if input.KeyCode == Enum.KeyCode.G then
			E:FireServer("Tool", "t")
		end
	end,

	input_ended = function(input: InputObject)
		if input.KeyCode == Enum.KeyCode.G then
			E:FireServer("Tool", "f")
		end
	end,
	
	input_hints = {
		[Enum.KeyCode] = {
			[Enum.KeyCode.G] = "Block";
		};
	},
}