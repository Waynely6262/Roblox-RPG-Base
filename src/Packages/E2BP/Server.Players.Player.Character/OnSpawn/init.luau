local Players = game:GetService("Players")

local WorldConfig = require(game.ReplicatedStorage.Modules.Game.Config)


local Root = game:GetService("ServerScriptService").Root
local Profiles = require(Root.Players.Profiles)
local Floors = require(Root.World)
local World = require(Root.World)
local Entities = require(Root.World.Entities)
local Finder = require(game.ReplicatedStorage.Modules.Utility.Finder)
local Remote = game.ReplicatedStorage.Remotes.MainE
local OccupiedFloors = {}
local Skills = require(Root.Players.Skills)
local StatusEffects = require(Root.StatusEffects)
local PInvRemote = require(Root.RemoteReceivers.Inventory)

local HumanoidAffectors = {

} do
	for _, v in script:GetChildren() do
		table.insert(HumanoidAffectors, require(v))
	end
end

return function(player, char)
	local level = Skills.getSkillLevel(player)
	
	
	World.teleportPlayer(player, Profiles[player].Data.Instant.Floor or "Crossroads")
	
	local AliveVB = player.Transient.IsAlive
	AliveVB.Value = true
	
	local CustomHumanoid = Entities.newHumanoid(char, "Player")
	
	StatusEffects.setEffect(CustomHumanoid, "regen", math.huge, 10)
	
	local humanoid: Humanoid?
	
	local function onStatsChanged(stats, changes)
		
		if not changes then return end
		if changes.WalkSpeed and humanoid then
			humanoid.WalkSpeed = stats.WalkSpeed
		end
		if changes.MaxHealth then
			Remote:FireClient(player, {
				{"hp", "dt", CustomHumanoid.hp};
				{"hp", "max", stats.MaxHealth};
			})
		end
	end

	CustomHumanoid.stats_changed:Connect(onStatsChanged)
	print(`Maxxing {player.Name}'s hp: {CustomHumanoid.combat_stats.MaxHealth}`)
	for _, Affector in HumanoidAffectors do
		Affector(player, CustomHumanoid)
	end
	CustomHumanoid.hp = CustomHumanoid.combat_stats.MaxHealth
	onStatsChanged(CustomHumanoid.combat_stats, CustomHumanoid.combat_stats)
	
	PInvRemote.reconcileAsync(player)
	
	local onDestroyListener: RBXScriptConnection
	local onDiedListener: RBXScriptConnection?
	-- could be null because the died listener is created after a potential yield
	
	local function onDead()
		
		onDestroyListener:Disconnect()
		
		if onDiedListener then onDiedListener:Disconnect() end
		AliveVB.Value = false
		CustomHumanoid:kill()
		
	end
	onDestroyListener = char.Destroying:Once(onDead)
	
	humanoid = char:WaitForChild("Humanoid"):: Humanoid
	onDiedListener = humanoid.Died:Once(onDead)
	
	
end


