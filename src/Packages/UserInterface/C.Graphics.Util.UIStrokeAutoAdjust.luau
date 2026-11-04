--!strict
local player = game:GetService("Players").LocalPlayer::Player
local emptyGui = Instance.new("ScreenGui")
emptyGui.IgnoreGuiInset = true
emptyGui.ResetOnSpawn = false
emptyGui.Parent = player.PlayerGui

local listening = {}:: {[UIStroke]: number}
local function listenIndefinitely(v: UIStroke)
	if listening[v] then return end
	
	listening[v] = v.Thickness
end

-- auto-listen to everything

local auto: {Instance} = {
	workspace;
	game.ReplicatedStorage;
	player.PlayerGui
}

for _, src in auto do
	for _, v in src:GetDescendants() do
		if v:IsA("UIStroke") then
			listenIndefinitely(v)
		end
	end
end

local scale = 1.5
local xinv = scale/1920
local yinv = scale/1080

local function resize()
	local n = math.min(emptyGui.AbsoluteSize.X * xinv, emptyGui.AbsoluteSize.Y * yinv, 1)
	for stroke, thick in listening do
		if not stroke.Parent then listening[stroke] = nil end
		stroke.Thickness = thick * n
	end
end

emptyGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
resize()

return {
	listen = listenIndefinitely
}