local LocalPlayer = game:GetService("Players").LocalPlayer or game:GetService("Players"):FindFirstChildWhichIsA("Player")
while not LocalPlayer do
	warn("A local player has not been found")
	LocalPlayer = game:GetService("Players"):FindFirstChildWhichIsA("Player")
	task.wait(1)
end
local Player = setmetatable({}, {
	__index = function(self, v)
		print("using local player property", v)
		return LocalPlayer[v]
	end,
})
Player.__index = Player

function Player.new(uid)
	
	local self = {
		UserId = uid;
		CharacterAppearanceId = uid;
		Character = game:GetService("Players"):CreateHumanoidModelFromUserId(uid);
		Name = game:GetService("Players"):GetNameFromUserIdAsync(uid);
		
		__children = {};
	}
	self.DisplayName = Name;
	self.PlayerGui = Instance.new("Folder");
	self.PlayerScripts = Instance.new("Folder");
	self.CharacterAdded = require(game.ReplicatedStorage.Modules.Utility.Signal).new();
	return setmetatable(self, Player)
end

function Player:WaitForChild(v)
	return LocalPlayer:WaitForChild(v)
end
function Player:FindFirstChild(v)
	return LocalPlayer:FindFirstChild(v)
end

return Player