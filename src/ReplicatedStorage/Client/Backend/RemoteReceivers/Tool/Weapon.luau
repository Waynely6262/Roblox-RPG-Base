local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LVSender = require(game.ReplicatedStorage.Client.Backend.SendLookVector)

local E = game.ReplicatedStorage.Remotes.MainE :: RemoteEvent

local player = Players.LocalPlayer
local Mouse = player:GetMouse()

return {
	input_began = function(input: InputObject)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		-- While loop for auto-attack / hold-to-attack behavior
		task.spawn(function()
			while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				LVSender.request(5)
				E:FireServer("Tool", "click", Mouse.Hit.Position)
				task.wait(0.1)  -- attack rate / swing speed
			end
		end)
	end,

	input_ended = function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Optional: can be used later for release effects, combo finishers, etc.
			-- print("MouseButton1 released")
		end
	end,
	
	input_hints = {
		[Enum.UserInputType] = {
			[Enum.UserInputType.MouseButton1] = "Attack";
		};
	},
}