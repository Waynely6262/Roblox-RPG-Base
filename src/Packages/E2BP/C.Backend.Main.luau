local Player = game:GetService("Players").LocalPlayer

local ReplicatedStorage = game.ReplicatedStorage

local Controls = require(Player.PlayerScripts.PlayerModule):GetControls()

local Vars = require(ReplicatedStorage.Client.Backend.RemoteReceivers.vars)
local CurrenciesGraphics = require(ReplicatedStorage.Client.Graphics.currencies)
local Finder = require(ReplicatedStorage.Modules.Utility.Finder)

local E = ReplicatedStorage.Remotes.MainE
local F = ReplicatedStorage.Remotes.MainF

CurrenciesGraphics.newCurrency("Essence", "http://www.roblox.com/asset/?id=7130084926")
CurrenciesGraphics.update("Essence", 0)

local fns = {
	essence = function(n)
		CurrenciesGraphics.animateUpdate("Essence", n)
	end,
}

Vars.changed:Connect(function(str: string, v)
	if fns[str] then
		fns[str](v)
	end
	
end)

Vars.reset:Connect(function()
	for k, fn in fns do
		fn(Vars.get(k) or 0)
	end
end)


return nil