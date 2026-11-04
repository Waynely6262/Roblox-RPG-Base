local Finder = require(game.ReplicatedStorage.Modules.Utility.Finder)
local ReplicationBuffer = require(game.ReplicatedStorage.Modules.Utility.ReplicationBuffer)
local CardData = require(game.ReplicatedStorage.Modules.Data.Cards)
local CardUtil = require(game.ReplicatedStorage.Modules.Game.CardUtil)
local UserDebounce = require(game.ServerScriptService.Root.Utils.UserDebounce)
local vars = require(game.ServerScriptService.Root.Players.vars)
local Entities = require(game.ServerScriptService.Root.World.Entities)
local MovesAsync = require(game.ServerScriptService.Root.Other.MovesAsync)

local E = game.ReplicatedStorage.Remotes.MainE



local Debouncers: {[string]: UserDebounce.class | any} = {}


-- if a property is tiered, it will be a table of values instead of the value itself. It will be read based on the passed level associated with the value.
-- if the level of that value does not exist, it will default to the last element in the list
-- if the value is not tiered, it will be returned as is
local function readTieredValue(v: any | {any}, l: number)
	return typeof(v) == "table" and (v[l] or v[#v]) or v
end

return {
	onInvoke = function(player: Player, abilitySlot: number, client_pos: Vector3, clientData: any)
		
		-- although the client can send a non-zero y-axis on the dir, it wouldn't benefit the player anyway so it doesn't need to be dealt with
		
		local slot_content = vars.get(player, "abilities")[abilitySlot]:: string?
		
		
		local attackName, attackLevel = CardUtil.fromSource(slot_content)
		
		if not attackName then return end
		
		local Data = CardData[attackName]
		attackLevel = attackLevel or 1
		
		local group = Data.group
		Debouncers[group] = Debouncers[group] or UserDebounce.new()
		if Debouncers[group]:isDebounced(player) then return end
		
		local isAliveVB = Finder.followPath(player, "Transient", "IsAlive"):: BoolValue
		
		if not (isAliveVB and isAliveVB.Value) then return end
		
		local character = player.Character
		if not character then return end
		
		local cHumanoid = Entities.getHumanoid(character)
		if not cHumanoid then return end
		
		
		local essence = vars.get(player, "essence") or 0
		
		local req = readTieredValue(Data.essence, attackLevel)
		
		if essence < req then return end
		-- end of sanitization
		vars.inc(player, "essence", -req)
		
		local server_pos = character:GetPivot().Position
		
		local vec_diff = client_pos - server_pos
		
		local bufferSize = ReplicationBuffer(cHumanoid.combat_stats.WalkSpeed)
		
		local pos = client_pos -- default the client's position
		if vec_diff.Magnitude > bufferSize then -- exceeds buffer: use server pos and moved the maximum to client pos
			pos = server_pos + vec_diff.Unit * bufferSize
		end
		
		-- Tiered
		local cooldown = readTieredValue(CardData[attackName].cooldown, attackLevel)
		
		E:FireClient(player, "cd", group, cooldown)
		Debouncers[group]:setDebounced(player, cooldown)
		
		MovesAsync[attackName](attackLevel, cHumanoid, pos, clientData)
		
	end,
}