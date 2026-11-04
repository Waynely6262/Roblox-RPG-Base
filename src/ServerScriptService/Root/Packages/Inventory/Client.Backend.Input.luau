local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Graphics = require(game.ReplicatedStorage.Client.Graphics.inventory)

local E = game.ReplicatedStorage.Remotes:WaitForChild("MainE"):: RemoteEvent
local Keys = {
	[Enum.KeyCode.One] = 1;
	[Enum.KeyCode.Two] = 2;
	[Enum.KeyCode.Three] = 3;
	[Enum.KeyCode.Four] = 4;
	[Enum.KeyCode.Five] = 5;
	[Enum.KeyCode.Six] = 6;
	[Enum.KeyCode.Seven] = 7;
	[Enum.KeyCode.Eight] = 8;
	[Enum.KeyCode.Nine] = 9;
	[Enum.KeyCode.Zero] = 10;
}

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if Keys[input.KeyCode] then
		E:FireServer("inv", "hb", Keys[input.KeyCode])
	end
end)

ContextActionService:BindAction("ToggleInv", function(_, state)
	if state == Enum.UserInputState.Begin then
		Graphics.toggle()
	end
end, true, Enum.KeyCode.Backquote)

Graphics.ToggleEquipRequested:Connect(function(c, s)
	if c == "Hotbar" then
		E:FireServer("inv", "hb", s)
	else
		warn(`No implemented equip server API for {c} (slot: {s})`)
	end
end)

return true