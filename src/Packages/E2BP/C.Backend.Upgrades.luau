--!strict

local Levelling = require(game.ReplicatedStorage.Modules.Game.Levelling)

local Upgrades = Levelling.Upgrades

local Vars = require(game.ReplicatedStorage.Client.Backend.RemoteReceivers.vars)

local Graphics = require(game.ReplicatedStorage.Client.Graphics.Upgrades)

local E = game.ReplicatedStorage.Remotes.MainE

do
	local count = 0
	for _, _ in Upgrades do
		count += 1
	end
	
	Graphics.setCount(count)
end
local function onChange(name: string, level: number?)
	local level = level or 0
	local GeoSeriesCalculator = Upgrades[name]

 	local req = GeoSeriesCalculator:xpToNextLevel(level)

	Graphics.update(name, level, req)
end

local function Reset()
	
	local data = Vars.get("upgrades")
	print(data, Vars.get("upgrades"))
	print(Vars.getCurrentVariablesArray())
	if data then
		for name, _ in Upgrades do
			print(name)
			onChange(name, data[name])
		end
	end
	
end

Vars.reset:Connect(Reset)
Reset()

Vars.longsetted:Connect(function(k1, k2, k3)
	if k1 == "upgrades" and k3 then
		onChange(k2, k3)
	end
end)

Graphics.requested:Connect(function(name: string)
	E:FireServer("Upgrades", name)
end)

return {}