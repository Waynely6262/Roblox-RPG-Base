--!strict
local API = {}

local Inventories = require(game.ReplicatedStorage.Modules.Inventory)
local Items = require(game.ReplicatedStorage.Modules.Inventory.Item)

local Profiles = require(game.ServerScriptService.Root.Players.Profiles)
local Remote = require(game.ServerScriptService.Root.Remotes)
local Signal = require(game.ReplicatedStorage.Modules.Utility.Signal)

API.EmptyInventoryJSON = Inventories.new():toJSON():: string
local PlayerInventories: {[Player]: Inventories.Inventory} = {} --TODO.TEST: Check if this is a memory leak without weak table; Assumption: Once a player leaves, the player key is weak? maybe?

-- Fired by Server/RemoteReceivers/inv.luau
API.Equipped = Signal.new():: Signal.Signal<Player, string, Items.item> -- make sure to fire this one second, if unequipped is also called.
API.Unequipped = Signal.new():: Signal.Signal<Player, string, Items.item> -- make sure to fire this one first, if equip is also called.

function API.loadJSON(player: Player, JSON: string)
	
	Remote.FireClient(player, "inv", "overwrite", JSON)
	local Inventory = Inventories.fromJSON(JSON)
	PlayerInventories[player] = Inventory
	
end

function API.reconcile(player: Player)
	local inv = API.getInventory(player)
	if not inv then warn(`Failed to reconcile {player.Name}'s inventory because it does not exist`) return end
	Remote.FireClient(player, "inv", "overwrite", inv:toJSON())
end

function API.getInventory(player: Player): Inventories.Inventory?
	return PlayerInventories[player]
end

function API.giveItem(player: Player, item: Items.item)
	local inv = API.getInventory(player)
	
	if inv then
		Remote.FireClient(player, "inv", "modify", "insert", item:toJSON())
		inv:insert(item)
	else
		warn(`Could not add {item:toJSON()} to {player.Name} because could not find their inventory`)
	end
	
end

function API.removeItem(player: Player, item_name: string, quota: number)
	local inv = API.getInventory(player)

	if inv then
		Remote.FireClient(player, "inv", "modify", "remove", item_name, quota)
		inv:remove(item_name, quota)
	else
		warn(`Could not remove {quota} of {item_name} from {player.Name} because could not find their inventory`)
	end

end

function API.countOf(player: Player, item_name: string): number
	local inv = API.getInventory(player)
	
	if inv then
		return inv:count(item_name)
	else
		warn(`Could not query {player.Name}'s inventory because missing inventory`)
		return 0
	end
end

function API.giveNewItem(player: Player, name: string, dynamic: Items.dynamic)
	return API.giveItem(player, Items.new(name, dynamic))
end

API.clientRequests = {}


return API