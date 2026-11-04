--!strict
--[[
Releases the client root to players.

The framework stages every client component under ServerScriptService.Root.Client while the server
runs. The only requirement for the client is that the Players module has been initialized, so we
require it first, then move the staged root to its destination (ReplicatedStorage by default),
where the client root script starts running on each player.
]]

local Root = game:GetService("ServerScriptService").Root
local PackageLoader = require(Root._Root.PackageLoader)
local CONFIG = require(game.ReplicatedStorage.Modules.PackageConfig.DSClientRoot)

local Players = Root:FindFirstChild("Players")
if Players then
	require(Players)
end

local staged = Root:FindFirstChild("Client")
if not (staged and staged:IsA("BaseScript")) then
	warn("[DSClientRoot] No client root was staged under Root.Client")
	return nil
end

local existing = CONFIG.destination:FindFirstChild("Client")
if existing then
	-- Usually a copy left behind by loading in Edit mode. The freshly loaded version wins.
	PackageLoader.Merge(existing, staged)
	existing:Destroy()
end

staged.Parent = CONFIG.destination

return nil
