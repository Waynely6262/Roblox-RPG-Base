--!strict
local WorldItems = {}
local Items = require(game.ReplicatedStorage.Modules.Inventory.Item)
local Remotes = require(game:GetService("ServerScriptService").Root.Remotes)
local Finder = require(game.ReplicatedStorage.Modules.Utility.Finder)
local PlayerInventories = require(game.ServerScriptService.Root.Players.PlayerInventories)
local CONFIG = require(game.ReplicatedStorage.Modules.Game.Config)
local Despawnables = require(script.Parent.Despawnables)
local AccessRS = require(game.ServerScriptService.Root.Utils.AccessRS)

local PromptTemplate = Instance.new("ProximityPrompt")
PromptTemplate.RequiresLineOfSight = false
PromptTemplate.ActionText = "Pick Up"
PromptTemplate.ObjectText = "Unknown"
PromptTemplate.MaxActivationDistance = 8
PromptTemplate.KeyboardKeyCode = Enum.KeyCode.LeftShift

local function IsAlive(player: Player)
	local VB = Finder.followPath(player, "Transient", "IsAlive"):: BoolValue?
	return VB and VB.Value
end



function WorldItems.dropItem(position: Vector3, item: Items.item)

	local model, handle = Despawnables.new(position, AccessRS.getTool(item.name))

	local Prompt = PromptTemplate:Clone()
	Prompt.Parent = handle
	Prompt.ObjectText = `{item.name} ({(not item.dynamic.amt or item.dynamic.amt == 1) and "" or item.dynamic.amt})`

	item:remove()

	local cnxn: RBXScriptConnection

	cnxn = Prompt.Triggered:Connect(function(player)

		if IsAlive(player) then
			local d = player:DistanceFromCharacter(position)

			if d > 0 and d < 18 then

				PlayerInventories.giveItem(player, item)

				model:Destroy()
				cnxn:Disconnect()
				return
			end
		end

	end)

	return model
end

function WorldItems.spawnItem(position: Vector3, name: string, dynamic: Items.dynamic)
	return WorldItems.dropItem(position, Items.new(name, dynamic))
end

return WorldItems