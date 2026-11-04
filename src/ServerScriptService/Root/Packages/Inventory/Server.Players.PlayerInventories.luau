--!strict
local Util = {}

local Inventories = require(game.ReplicatedStorage.Modules.Inventory)
local Items = require(game.ReplicatedStorage.Modules.Inventory.Item)

local Profiles = require(game.ServerScriptService.Root.Players.Profiles)
local Remote = require(game.ServerScriptService.Root.Remotes)
local Signal = require(game.ReplicatedStorage.Modules.Utility.Signal)

Util.EmptyInventoryJSON = Inventories.new():toJSON():: string
local PlayerInventories: {[Player]: Inventories.Inventory} = {} --TODO.TEST: Check if this is a memory leak without weak table; Assumption: Once a player leaves, the player key is weak? maybe?

-- Fired by Server/RemoteReceivers/inv.luau
Util.Equipped = Signal.new():: Signal.Signal<Player, string, Items.item> -- make sure to fire this one second, if unequipped is also called.
Util.Unequipped = Signal.new():: Signal.Signal<Player, string, Items.item> -- make sure to fire this one first, if equip is also called.

function Util.loadJSON(player: Player, JSON: string)
	
	Remote.FireClient(player, "inv", "overwrite", JSON)
	local Inventory = Inventories.fromJSON(JSON)
	PlayerInventories[player] = Inventory
	
end

function Util.reconcile(player: Player)
	Remote.FireClient(player, "inv", "overwrite", PlayerInventories[player]:toJSON())
end

function Util.getInventory(player: Player)
	return PlayerInventories[player] or Util.EmptyInventoryJSON
end

function Util.giveItem(player: Player, item: Items.item)
	local inv = PlayerInventories[player]
	
	if inv then
		Remote.FireClient(player, "inv", "modify", "insert", item:toJSON())
		inv:insert(item)
	else
		warn(`Could not add {item:toJSON()} to {player.Name} because could not find their inventory`)
	end
	
end

function Util.removeItem(player: Player, item_name: string, quota: number)
	local inv = PlayerInventories[player]

	if inv then
		Remote.FireClient(player, "inv", "modify", "remove", item_name, quota)
		inv:remove(item_name, quota)
	else
		warn(`Could not remove {quota} of {item_name} from {player.Name} because could not find their inventory`)
	end

end

function Util.countOf(player: Player, item_name: string): number
	local inv = PlayerInventories[player]
	
	if inv then
		return inv:count(item_name)
	else
		warn(`Could not query {player.Name}'s inventory because missing inventory`)
		return 0
	end
end

function Util.giveNewItem(player: Player, name: string, dynamic: Items.dynamic)
	return Util.giveItem(player, Items.new(name, dynamic))
end

Util.clientRequests = {}


return Util