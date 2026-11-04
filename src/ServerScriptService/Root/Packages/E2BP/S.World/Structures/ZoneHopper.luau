local Players = game:GetService("Players")

local l_require = require(game.ReplicatedStorage.Modules.Utility.LazyRequire)

local Template = game.ReplicatedStorage.Models.Hopper

local World = l_require(script.Parent.Parent)

local Teams = require(game.ServerScriptService.Root.Other.Teams)
local DTeam = Teams.get("Despawnables")

local OFFSET = Vector3.new(0,0.001,0)

local dbt = {}

return function(pos: Vector3, destination: string, x: number?, y: number?)
	local New = Template:Clone()
	New.Name = `Hopper ({tostring(destination)})`
	New:PivotTo(CFrame.new(pos+ OFFSET))
	-- Parent is set here so that this method can be used easily OUTSIDE of the entityGenManager class, e.g. for sandboxing
	-- Note that the primary user, EntityGenManager also calls <Despawnables Team>:addChild(<Hole>) via EntityGenManager.registerDespawnable
	-- Since this is not a hot method and addChild is relatively inexpensive, it should be fine
	DTeam:addChild(New)

	New.GUI.LocationTextLabel.Text = destination
	New.Handle.Touched:Connect(function(p)

		local player = Players:GetPlayerFromCharacter(p.Parent)
		if player then
			if dbt[player] then return end
			World.teleportPlayer(player, destination, x, y)

			dbt[player] = true
			wait(1)
			dbt[player] = nil
		end
	end)
	return New
end