local uis = game:GetService("UserInputService")
local exitmenupos = Vector3.new(37,-24,0)

local signal = require(game.ReplicatedStorage.Modules.Utility.Signal).new()

local expectedType = uis.MouseEnabled and Enum.UserInputType.MouseButton1 or uis.TouchEnabled and Enum.UserInputType.Touch

local esc = Enum.KeyCode.Escape
uis.InputBegan:Connect(function(input, gpe)
	if 
		input.KeyCode == esc 
		or (
			input.UserInputType == expectedType and 
			(input.Position - exitmenupos).Magnitude < 24
		)
	then
		signal:Fire(input.UserInputType)
	end 
end)


return signal