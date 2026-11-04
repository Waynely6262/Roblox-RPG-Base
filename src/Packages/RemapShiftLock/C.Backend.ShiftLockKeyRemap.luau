local Players = game:GetService("Players")

local keys = {
	Enum.KeyCode.LeftAlt;
}

local src = ""
for i, v in keys do
	src = src .. v.Name .. (next(keys, i) ~= nil and "," or "") 
end


local mouseLockController = Players.LocalPlayer.PlayerScripts
	:WaitForChild("PlayerModule")
	:WaitForChild("CameraModule")
	:WaitForChild("MouseLockController")

local obj = mouseLockController:FindFirstChild("BoundKeys")
if obj then
	obj.Value = src
else
	obj = Instance.new("StringValue")
	obj.Name = "BoundKeys"
	obj.Parent = mouseLockController
end
obj.Value = src

return obj