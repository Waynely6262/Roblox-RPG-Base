--!strict

----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")


local l_require = require(game.ReplicatedStorage.Modules.Utility.LazyRequire)
local Remote = require(ServerScriptService.Root.Remotes)
local Teams = require(ServerScriptService.Root.Other.Teams)
local CombatStats = require(script.CombatStats)
local ModifierStats = require(script.CombatStatsModifier)
local SpecialStats = require(script.SpecialStats)
local vars = require(ServerScriptService.Root.Players.vars)
local RunOnNextFrame = require(ReplicatedStorage.Modules.Utility.RunOnNextFrame)
local PhysicsProp = require(ServerScriptService.Root.Other.PhysicsProp)
local getReplicationBuffer = require(ReplicatedStorage.Modules.Utility.ReplicationBuffer)
local PlayerInventories = require(ServerScriptService.Root.Players.PlayerInventories)
local PlayerInventoriesRemote = l_require(ServerScriptService.Root.RemoteReceivers.Inventory)
local ItemCreator = require(ServerScriptService.Root.World.EntityGenManager.Items)
local CollisionGroups = require(ServerScriptService.Root.CollisionGroups)
local Config = require(ReplicatedStorage.Modules.Game.Config)
local Finder = require(ReplicatedStorage.Modules.Utility.Finder)
local Signal = require(ReplicatedStorage.Modules.Utility.Signal)
local Skills = require(ServerScriptService.Root.Players.Skills)
local Upgrades = require(ServerScriptService.Root.RemoteReceivers.Upgrades)
local StatusEffects = l_require(ServerScriptService.Root.StatusEffects)
local AccessRS = require(ServerScriptService.Root.Utils.AccessRS)
local ReadReincarnations = require(ServerScriptService.Root.ReadReincarnation)
local CTools = l_require(ServerScriptService.Root.Tools)
----------------------------------------------------------------------------------------------------

local E = ReplicatedStorage.Remotes.MainE

local PlayerHumanoidCreated = Signal.new():: Signal.Signal<Player, CustomHumanoid>

local DEFAULT_TEAM = Teams.get("Entities")
local fxTeam = Teams.get("fx")
local DespawnTeam = Teams.get("Despawnables")
DEFAULT_TEAM:setFriendlyFireEnabled(true)
DEFAULT_TEAM:addFriendlyTeam(fxTeam)
DEFAULT_TEAM:addFriendlyTeam(DespawnTeam)

local Random = Random.new()

local activeHumanoids: {[Instance]: CustomHumanoid} = setmetatable({}, {__mode = "k"})
local replicationQueue: {{("dt" | "collected" | "destroyed") | Model | any}} = {} -- NOTE: check replicateThingInteraction for the structure of each element in this table

local replicationPending = false

local function replicateThingInteraction(m: Model, event: string, ...) -- to reduce FireClient calls by placing replication requests in a table
	table.insert(replicationQueue, {event, m, ...})

	if not replicationPending then
		replicationPending = true
		RunOnNextFrame(function()
			Remote.StreamFireClients(m:GetPivot().Position, "mam", replicationQueue)
			replicationPending = false
			replicationQueue = {}
		end)
	end


end

local function generalReward(player: Player, magnitude: number)
	
	local multiplier = 1 + Upgrades.getUpgradeLevel(player, "Essence Collector") * 0.10 + (0.05 * ReadReincarnations.getTotalCount(player))
	
	vars.inc(player, "essence", magnitude * multiplier)
	Skills.addSkillXP(player, "hunting", 10 * magnitude)
end

type HumanoidStaticInfo = {
	onHit: (CustomHumanoid?, CustomHumanoid, damage: number, crit: boolean?, pos: Vector3?) -> (), 
	reward: (player: Player, killed: CustomHumanoid) -> ()?,
	onDied: (CustomHumanoid?, CustomHumanoid) -> (), 
	onHeal: (CustomHumanoid, damage: number) -> (),
	onAttributeChange: (CustomHumanoid, string, any?) -> (),
	baseCombatStats: CombatStats.Stats,
	sanitizeDmg: ((CustomHumanoid, damage: number) -> (number)) | number?,
	sanitizeHeal: ((CustomHumanoid, damage: number) -> (number)) | number?,
	defaultHealth: number,
	essence: number?,
	coreLoopMethod: "Neutral" | "Hostile" | "Passive" | "Guard",
	infamy: number?,
	
}

local humanoids_info: {[string]: HumanoidStaticInfo | any}

local default_humanoid_info = {

	defaultHealth = 50,
	
	sanitizeDmg = nil,
	
	sanitizeHeal = nil,
	
	-- Since generalReward is applied to basically all mobs, it's turned into this variable which determines the reward.
	essence = 0,
	onHit = function(attacker: CustomHumanoid?, humanoid: CustomHumanoid, damage: number, crit: boolean?)
		replicateThingInteraction(humanoid.adornee, crit and "!" or "-", damage)
		if damage > 0 then
			replicateThingInteraction(humanoid.adornee, "%", humanoid.hp / humanoid.combat_stats.MaxHealth)
		end
	end,
	onHeal = function(humanoid: CustomHumanoid, heal: number)
		if heal > 0 then
			replicateThingInteraction(humanoid.adornee, "+", heal)
			replicateThingInteraction(humanoid.adornee, "%", humanoid.hp / humanoid.combat_stats.MaxHealth)
		end
	end,
	
	onDied = function(killer: CustomHumanoid, humanoid: CustomHumanoid)
	end,
	
	baseCombatStats = CombatStats.new(1, 0, 1, 1, 0, 16, 0, 1, 1, 50),
	
	coreLoopMethod = "Neutral",

}:: HumanoidStaticInfo

local dflt_hinf = default_humanoid_info


local TypeTranslations = {
	--[Resource Name] = {skill name, item drops data}
	["Tin Ore"] = {"mining"};
	["Copper Ore"] = {"mining"};
	["Iron Ore"] = {"mining"};
	["Gold Ore"] = {"mining"};
	["Titanium Ore"] = {"mining"};
	["Coal Ore"] = {"mining"; "Coal";};
	["Stone"] = {"mining"};
	["Tree"] = {"chopping"; "Wood"};
	["Bush"] = {"foraging"; "Berries"};
	
}

local multipliers = {
	chopping = "chop_mul";
	mining = "mine_mul";
}

local function ResourceElementOnHit(attacker: CustomHumanoid?, humanoid: CustomHumanoid, pos: Vector3?, itemType: string, chance: number, baseWeight: number)
	
	if not attacker then return end
	
	
	attacker:ifPlayer(function(player: Player)		
		
		local SkillData: {string} = TypeTranslations[itemType] or {"mining"}
		local SkillName = SkillData[1]
		local ItemName = SkillData[2] or itemType
		
		local PlayerSkillLevel = Skills.getSkillLevel(player, SkillName)
		
		-- multiplier
		local playerEquip = attacker.equipment.main
		if playerEquip then
			local data = playerEquip:getData()
			local keyReq = multipliers[SkillName]
			if keyReq and data[keyReq] then
				PlayerSkillLevel *= data[keyReq]
			end
		end
		
		local levelWeight = 1 - baseWeight
		
		Skills.addSkillXP(player, SkillName, 3)
		if math.random(100) < (100 * baseWeight + PlayerSkillLevel * levelWeight) * chance then
			PlayerInventories.giveNewItem(player, ItemName, {amt = 1;})
			
			local humanoidPos = humanoid.adornee:GetPivot().Position
			
			if pos then
				humanoidPos += (pos - humanoidPos).Unit * math.sqrt((pos - humanoidPos).Magnitude)
			end
			
			PhysicsProp(AccessRS.getTool(ItemName), humanoidPos)
		end
	end)


end

local function MobDrops(victim: CustomHumanoid, drops: {[string]: {number}})
	local pos = victim.adornee:GetPivot().Position

	for itemName: string, info: {number} in pairs(drops) do
		local chance     = info[1]   -- 0–1 range expected
		local minCount   = info[2]
		local maxCount   = info[3]

		if math.random() <= chance then
			local amount = math.random(minCount, maxCount)

			if amount > 0 then
				ItemCreator.spawnItem(pos, itemName, {amt = amount})
			end
		end
	end
end

humanoids_info = {
	
	["Tin Ore"] = {
		defaultHealth = 100,
		sanitizeDmg = 1,
		sanitizeHeal = 0,
		onHit = function(attacker: CustomHumanoid?, humanoid: CustomHumanoid, a, b, pos: Vector3?)
			default_humanoid_info.onHit(attacker, humanoid, a, b, pos)
			ResourceElementOnHit(attacker, humanoid, pos, "Tin Ore", 0.5, 0.25)
		end,
	};
	
	["Copper Ore"] = {
		defaultHealth = 100,
		sanitizeDmg = 1,
		sanitizeHeal = 0,
		onHit = function(attacker: CustomHumanoid?, humanoid: CustomHumanoid, a, b, pos: Vector3?)
			default_humanoid_info.onHit(attacker, humanoid, a, b, pos)
			ResourceElementOnHit(attacker, humanoid, pos, "Copper Ore", 0.5, 0.25)
		end,
		
	};
	
	["Coal Ore"] = {
		defaultHealth = 100,
		sanitizeDmg = 1,
		sanitizeHeal = 0,
		onHit = function(attacker: CustomHumanoid?, humanoid: CustomHumanoid, a, b, pos: Vector3?)
			default_humanoid_info.onHit(attacker, humanoid, a, b, pos)
			ResourceElementOnHit(attacker, humanoid, pos, "Coal Ore", 0.5, 0.25)
		end,
		
	};
	
	["Gold Ore"] = {
		defaultHealth = 4,
		sanitizeDmg = 1,
		sanitizeHeal = 0,
		onHit = function(attacker: CustomHumanoid?, humanoid: CustomHumanoid, a, b,  pos: Vector3?)
			default_humanoid_info.onHit(attacker, humanoid, a, b, pos)
			ResourceElementOnHit(attacker, humanoid, pos, "Gold Ore", 0.1, 0.5)
		end,
		
	};
	
	["Titanium Ore"] = {
		defaultHealth = 100,
		sanitizeDmg = 1,
		sanitizeHeal = 0,
		onHit = function(attacker: CustomHumanoid?, humanoid: CustomHumanoid, a, b, pos: Vector3?)
			default_humanoid_info.onHit(attacker, humanoid, a, b, pos)
			ResourceElementOnHit(attacker, humanoid, pos, "Titanium Ore", 0.1, 0.5)
		end,
		
	};
	
	["Iron Ore"] = {
		defaultHealth = 100,
		sanitizeDmg = 1,
		sanitizeHeal = 0,
		onHit = function(attacker: CustomHumanoid?, humanoid: CustomHumanoid, a, b, pos: Vector3?)
			default_humanoid_info.onHit(attacker, humanoid, a, b, pos)
			ResourceElementOnHit(attacker, humanoid, pos, "Iron Ore", 0.4, 0.20)
		end,
		
	};
	
	["Stone"] = {
		defaultHealth = 100,
		sanitizeDmg = 1,
		sanitizeHeal = 0,
		onHit = function(attacker: CustomHumanoid?, humanoid: CustomHumanoid, a, b, pos: Vector3?)
			default_humanoid_info.onHit(attacker, humanoid, a, b, pos)
			ResourceElementOnHit(attacker, humanoid, pos, "Stone", 1, 0.25)
		end,
		
	};
	
	["Tree"] = {
		defaultHealth = 100,
		sanitizeDmg = 1,
		sanitizeHeal = 0,
		onHit = function(attacker: CustomHumanoid?, humanoid: CustomHumanoid, a, b, pos: Vector3?)
			default_humanoid_info.onHit(attacker, humanoid, a, b, pos)
			ResourceElementOnHit(attacker, humanoid, pos, "Tree", 1, 0.30) 
		end,
		
	};
	
	["Bush"] = {
		defaultHealth = 30,
		--sanitizeDmg = 1,
		sanitizeHeal = 0,
		onHit = function(attacker: CustomHumanoid?, humanoid: CustomHumanoid, a, b, pos: Vector3?)
			default_humanoid_info.onHit(attacker, humanoid, a, b, pos)
			ResourceElementOnHit(attacker, humanoid, pos, "Tree", 1, 0.20) 
		end,

	};
	
	-- Civil
	
	["Villager"] = {
		baseCombatStats = CombatStats.new(3, 1, 2.8, 0.6, 0, 16, 0, 1, 1, 60);
		essence = 20;
		infamy = 30;
		onDied = function(killer: CustomHumanoid, victim: CustomHumanoid)
			MobDrops(victim, {
				["Silver"] = {0.2, 1, 4};
			})
		end,
		coreLoopMethod = "Passive",
	};
	
	["Guard"] = {
		baseCombatStats = CombatStats.new(60, 20, 5, 3, 0, 24, 50, 1, 1.1, 480);
		essence = 200;
		infamy = 10;
		onDied = function(killer: CustomHumanoid, victim: CustomHumanoid)
			MobDrops(victim, {
				["Gold"] = {0.1, 1, 3};
			})
		end,
		coreLoopMethod = "Guard",
	};
	
	["Royal Guard"] = {
		baseCombatStats = CombatStats.new(80, 30, 10, 4, 0, 30, 70, 1.5, 1.25, 800);
		essence = 500;
		infamy = 10;
		onDied = function(killer: CustomHumanoid, victim: CustomHumanoid)
			MobDrops(victim, {
				["Gold"] = {0.2, 1, 4};
			})
		end,
		coreLoopMethod = "Guard",
	};

	
	
	-- Farm
	Sheep = {
		baseCombatStats = CombatStats.new(3, 1, 2.8, 0.6, 0, 16, 0, 1, 1, 60);
		essence = 10;
		onDied = function(killer: CustomHumanoid, victim: CustomHumanoid)
			MobDrops(victim, {
				["Bone"] = {0.4, 1, 3};
			})
		end,
	};
	
	Cow = {
		baseCombatStats = CombatStats.new(4, 2, 3, 0.5, 0, 16, 0, 1, 1, 120);
		essence = 15;
		onDied = function(killer: CustomHumanoid, victim: CustomHumanoid)
			MobDrops(victim, {
				["Bone"] = {0.5, 2, 4};
			})
		end,
		
	};
	
	Rat = {
		baseCombatStats = CombatStats.new(1, 1, 2.5, 0.65, 0, 16, 0, 1, 1, 30);
		essence = 5;
		onDied = function(killer: CustomHumanoid, victim: CustomHumanoid)
			MobDrops(victim, {
				["Bone"] = {0.25, 1, 1};
			})
		end,
	};
	
	["Giant Spider"] = {
		baseCombatStats = CombatStats.new(5, 0, 4, 2, 0, 24, 5, 1, 1, 40);
		essence = 20;
		onDied = function(killer: CustomHumanoid, victim: CustomHumanoid)
			MobDrops(victim, {
				["Spider Silk"] = {0.5, 1, 2};
			})
		end,
		coreLoopMethod = "Hostile";
	};
	
	-- Hostile
	
	
	-- Neutral
	
	-- Special
	Tanker = {
		baseCombatStats = CombatStats.new(2, 100, 10, 0, 0, 10, 0, 0, 0, 10000);
		essence = 1000;
		coreLoopMethod = "Hostile";
	};
	
	Dodger = {
		baseCombatStats = CombatStats.new(2, 10, 1.5, 10, 0, 26, 0, 0, 0, 50);
		essence = 400;
		coreLoopMethod = "Hostile";
	};
	
	HotShot = { -- meme guy; misses basically all his shots
		baseCombatStats = CombatStats.new(2, 1, 0.1, 0, 0, 26, 0, 0, 0, 1);
		essence = 10;
		coreLoopMethod = "Hostile";
	};
	
	Striker = {
		baseCombatStats = CombatStats.new(100, 3, 100, 0, 0, 15, 25, 0, 0, 20);
		essence = 500;
		coreLoopMethod = "Hostile";
	};
	
	["Super Death"] = {
		baseCombatStats = CombatStats.new(100, 7, 100, 0, 0, 15, 80, 0, 0, 20);
		essence = 1000;
		coreLoopMethod = "Hostile";
	};
	
	Player = {
		defaultHealth = 100,
		infamy = 5,
		reward = function(player: Player, killed: CustomHumanoid)
			Skills.addSkillXP(player, "assassin", 100)
		end,
		
		sanitizeDmg = function(humanoid: CustomHumanoid, dmg: number)
			return math.min(dmg, humanoid.combat_stats.MaxHealth*0.2)
		end,
		
		onHit = function(attacker: CustomHumanoid?, humanoid: CustomHumanoid, dmg: number, crit: boolean)
			default_humanoid_info.onHit(attacker, humanoid, dmg, crit)
			--TODO: Add in-combat status effect
			if not humanoid._player then warn(`couldn't find Player {humanoid.adornee.Name}`) return end
			
			if dmg > 0 then
				Skills.addSkillXP(humanoid._player, "armor", dmg)
			end
			
			E:FireClient(humanoid._player:: Player, "hp", "dt", humanoid.hp)
		end,
		onHeal = function(humanoid: CustomHumanoid, heal)
			default_humanoid_info.onHeal(humanoid, heal)
			if not humanoid._player then warn(`couldn't find Player {humanoid.adornee.Name}`) return end
			E:FireClient(humanoid._player:: Player, "hp", "dt", humanoid.hp)
		end,
		
		onDied = function(killer: CustomHumanoid?, victim: CustomHumanoid)
			default_humanoid_info.onDied(killer, victim)
			
			local builtin_humanoid = victim.adornee:FindFirstChildWhichIsA("Humanoid")
			if builtin_humanoid then
				builtin_humanoid.Health = 0
			end
			
			PlayerInventoriesRemote.reset(victim._player:: Player)
			
			local victimLevel: number = Skills.getSkillLevel(victim._player:: Player)
			local killerLevel: number = killer and (killer:ifPlayer(function(player)
				return Skills.getSkillLevel(player)
			end) or victimLevel) or 0
			
			local victimInv = assert(PlayerInventories.getInventory(victim._player:: Player), `{victim.adornee.Name} player evaded inventory loss because no player is associated with this humanoid`)

			local items = victimInv:getEverything()

			local itemLoss = math.floor(1 + math.sqrt(victimLevel - killerLevel))
			if not (itemLoss > 0 or itemLoss < 0) then return end

			for _, v: any in items do

				if 0.25 > math.random() then
					itemLoss -= 1
					-- using the existence of the function v.remove to determine whether the element is an item
					if typeof((v.__index:: any).remove) == "function" then
						(v:: any):remove()
					end
				end


				if itemLoss == 0 then break end
			end

			PlayerInventories.reconcile(victim._player:: Player)

		end,
		
		onAttributeChange = function(chum: CustomHumanoid, id: string, new: any?)
		end,
	},
	
	Wall = {
		defaultHealth = 20,
		reward = function(player: Player)
			Skills.addSkillXP(player, "destruction", 5)
		end,
		onHit = function() end,
		sanitizeHeal = 0,
		onHeal = function() end,
	},
}

do
	
	local meta = {
		__index = default_humanoid_info
	}
	for _, v in humanoids_info do
		setmetatable(v:: {any}, meta)
		table.freeze(v)
	end
	table.freeze(humanoids_info)
end


local function damagePacket(attacker: CustomHumanoid?, receiver: CustomHumanoid, damage: number, crit: boolean?, pos: Vector3?)
	
	local sanitizer = receiver.static.sanitizeDmg
	damage = typeof(sanitizer) == "function" and (sanitizer:: (CustomHumanoid, number) -> (number))(receiver, damage) or sanitizer:: number? or damage
	if damage > 0 and attacker then
		
		receiver._death_credit = attacker
		receiver._credit_period = os.clock() + Config.KILL_CREDIT_PERIOD
	end
	damage = math.ceil(damage)
	receiver.hp -= damage
	
	task.spawn(receiver.static.onHit, attacker, receiver, damage, crit, pos)

	-- safe handling of this potentially being nan:
	
	-- (nan > 0) -> false
	-- (nan <= 0) -> false
	if not (receiver.hp > 0) then
		receiver:kill()
	end
	
end

local function healPacket(attacker: CustomHumanoid?, receiver: CustomHumanoid, heal: number)
	heal = math.ceil(heal)
	
	local sanitizer = receiver.static.sanitizeHeal
	heal = typeof(sanitizer) == "function" and (sanitizer:: (CustomHumanoid, number) -> (number))(receiver, heal) or sanitizer:: number? or heal
	
	local oldhp = receiver.hp
	receiver.hp = math.min(receiver.combat_stats.MaxHealth, receiver.hp + heal)
	
	local diff = receiver.hp - oldhp

	if diff ~= 0 then
		receiver.static.onHeal(receiver, diff)
	end
end

local HitChanceF = require(ServerScriptService.Root.Other.RandomizedGameplay.Hit)
local BlockChanceF = require(ServerScriptService.Root.Other.RandomizedGameplay.ShieldBlock)

local function hitPacket(attacker: CustomHumanoid, defender: CustomHumanoid, pos: Vector3?, attackerStats: CombatStats.Stats?)
	
	
	
	local attackerStats = attackerStats or attacker.combat_stats
	
	if not HitChanceF(attackerStats.Precision, defender.combat_stats.Dodge) then
		damagePacket(attacker, defender, 0, nil, pos) -- miss
		return
	else
		
		if defender.static.infamy then
			StatusEffects.setEffect(attacker, "infamous", defender.static.infamy, nil, true, 150)
		end
		
		
		attacker:ifPlayer(function(player: Player)
			local toolType = attacker.equipment and attacker.equipment.main and (attacker.equipment.main:: any):getData().type or "unarmed"
			Skills.addSkillXP(player, toolType, 9)
		end)
		
		if defender.effects.immune then
			damagePacket(attacker, defender, 1, nil, pos)
			return
		end

		local defenderStats: CombatStats.Stats = defender.combat_stats


		-- crit >>>
		local chance = attackerStats.CritChance
		local critMultiplier: number = (chance // 100) * Config.CRIT_MULTIPLIER

		if chance % 100 > math.random(100) then
			critMultiplier += Config.CRIT_MULTIPLIER
		end
		critMultiplier = math.max(1, critMultiplier)
		-- <<< crit
		
		local piercedPercentage = math.clamp(attackerStats.Piercing / 100, 0, 1)
		local unpiercedPercentage = 1 - piercedPercentage
		

		local damage = critMultiplier * (
			unpiercedPercentage * attackerStats.Damage / (1 + 0.0075 * defenderStats.Defense^2)
			+
			piercedPercentage * attackerStats.Damage
		)
		damage *= (1 - Config.DAMAGE_FUZZY * math.random())
		
		local shieldBlockSkillLevel = defender:ifPlayer(function(player: Player)
			return Skills.getSkillLevel(player, "shield")
		end) or 1
		
		if 
			defender.special_stats.shieldActive 
			or (
				defender.equipment 
				and defender.equipment.Offhand 
				and (defender.equipment.Offhand:: any):getData().type == "shield" 
				and BlockChanceF(shieldBlockSkillLevel)
			) then
			
			damage *= (0.05 + 0.2 * math.random())
			
			task.defer(function()
				-- TODO:FRONTEND >>>
				defender:ifPlayer(function(player)
					Skills.addSkillXP(player, "shield", 10)
				end)
				replicateThingInteraction(defender.adornee, "?", "BLOCKED")
				-- <<< FRONTEND
			end)
		end
		

		damagePacket(attacker, defender, damage, critMultiplier > 1, pos)

	end

end

local function getCHumanoid(m: Model | Player): CustomHumanoid?
	return activeHumanoids[m]
end

-- sole purpose of the functions with identifiers starting with "model" is to parse for a CHumanoid
local function modelHitPacket(attacker: CustomHumanoid, Model: Model, pos: Vector3?, attackerStats: CombatStats.Stats)

	local defender: CustomHumanoid? = getCHumanoid(Model)

	if defender then
		return hitPacket(attacker, defender, pos, attackerStats)
	end

end

local function modelDamagePacket(attacker: CustomHumanoid?, Model: Model, damage: number, crit: boolean?, pos: Vector3?)


	local receiver: CustomHumanoid? = getCHumanoid(Model)
	if receiver then
		return damagePacket(attacker, receiver, damage, crit, pos)
	end
end

local function modelHealPacket(attacker: CustomHumanoid?, Model: Model, heal: number)

	local receiver: CustomHumanoid? = getCHumanoid(Model)
	if receiver then
		return healPacket(attacker, receiver, heal)
	end
end

local CHumanoid = {}
CHumanoid.__index = CHumanoid

export type CustomHumanoid = typeof(setmetatable({}:: {
	adornee: Model,
	hitbox: BasePart?,
	static: HumanoidStaticInfo,
	hp: number,
	died: Signal.Signal<CustomHumanoid?>,
	stats_changed: Signal.Signal<CombatStats.Stats, ModifierStats.Modifier>,
	
	equipment: {[string]: any?},
	
	_attributes: {[string]: any?},
	effects: {[string]: any},
	special_stats: SpecialStats.Stats, -- things like shield activation chance
	
	_accumulated_stats: ModifierStats.Modifier, -- mutable for additions, sum of add modifiers
	_add_stats_modifiers: {[string]: ModifierStats.Modifier}, -- applied additively
	
	_multiplied_stats: ModifierStats.Modifier, -- mutable for multiplication, product of mul modifiers
	_mul_stats_modifiers: {[string]: ModifierStats.Modifier}, -- applied multiplicatively
	
	combat_stats: CombatStats.Stats, -- immutable, final stats to be used for gameplay
	
	
	_death_credit: CustomHumanoid?,
	_credit_period: number,
	_player: Player?,
	_team: Teams.Team,
	_cached_exclusion_list: {Instance}?,
	_overlap_params: OverlapParams?,
	_raycast_params: RaycastParams?,
	
	_isDead: boolean?,
}, CHumanoid))

@deprecated
function CHumanoid:changeMaxHealth(newmax: number)
	warn("This function is deprecated!")
end

function CHumanoid:isAlive()
	return not self._isDead
end

function CHumanoid.kill(self: CustomHumanoid)
	if self._isDead then return end
	self.hp = 0
	self._isDead = true
	local deathCredit: CustomHumanoid?

	if self._credit_period and self._credit_period > os.clock() then -- the period for receiving credit for a kill isn't over
		deathCredit = self._death_credit
		
		deathCredit:ifPlayer(function(player: Player)
			if self.static.essence ~= 0 then
				generalReward(player, self.static.essence)
			end
			
			if self.static.reward then
				self.static.reward(player)
			end
		end)
	end
	self.died:Fire(deathCredit)
	
	task.spawn(replicateThingInteraction, self.adornee, "x")
	self:changeTeam(fxTeam)
	task.delay(4, function() -- give time to replicate
		self.adornee:Destroy()
	end)

	self.stats_changed:Destroy()
	self.died:Destroy()
	
	task.defer(self.static.onDied, deathCredit, self)
	
	activeHumanoids[self.adornee] = nil
	
	self:ifPlayer(function(player: Player)
		activeHumanoids[player] = nil
	end)
	
	StatusEffects.clearAllEffects(self)
	
end

function CHumanoid.getImmediateEnemy(self: CustomHumanoid): CustomHumanoid?
	return self._credit_period and os.clock() < self._credit_period and self._death_credit or nil
end

function CHumanoid.ifPlayer(self: CustomHumanoid,f: (Player, ...any) -> (), ...)
	if self._player then
		return f(self._player:: Player, ...)
	end
end

function CHumanoid.reconcileParent(self: CustomHumanoid)
	self._team:addChild(self.adornee)
end

function CHumanoid.changeTeam(self: CustomHumanoid, team: Teams.Team | string?)
	self._team = typeof(team) == "string" and Teams.get(team:: string) or (team:: Teams.Team? or DEFAULT_TEAM)
	
	self:reconcileParent()
	
	self._cached_exclusion_list = nil
end

do
	-- parameters are constructed using exclusion lists. Exclusion lists are
	-- constructed using the Teams class. Parameters need to be reconciled whenever
	-- the Team object's 'alliances' have changed. In practice, this doesn't happen
	-- very often, so optimization of this reconcile function is not too big of a deal.
	function CHumanoid._reconcileParameters(self: CustomHumanoid)
		if not (self._team._exclusionListUpToDate and self._cached_exclusion_list) then
			self._cached_exclusion_list = self._team:getAccompaniedExclusionList({self.adornee}):: {Instance}
			
			local RParams = RaycastParams.new()
			RParams.FilterDescendantsInstances = self._cached_exclusion_list:: {Instance}
			RParams.FilterType = Enum.RaycastFilterType.Exclude
			self._raycast_params = RParams
			
			local OParams = OverlapParams.new()
			OParams.FilterDescendantsInstances = self._cached_exclusion_list:: {Instance}
			OParams.FilterType = Enum.RaycastFilterType.Exclude
			self._overlap_params = OParams
		end

	end
	function CHumanoid.getRaycastParams(self: CustomHumanoid): RaycastParams
		self:_reconcileParameters()
		return self._raycast_params:: RaycastParams
	end
	
	function CHumanoid.getOverlapParams(self: CustomHumanoid): OverlapParams
		self:_reconcileParameters()
		return self._overlap_params:: OverlapParams
	end
end

-- >>> Combat Stats

--[[
]]

-- recalculates the sum of all addition modifiers and saves it as _accumulated_stats
function CHumanoid.__reconcileAddedCombatStats(self: CustomHumanoid, skipUpdate: boolean?)
	
	local accumulated_stats = self.static.baseCombatStats:clone(true)

	for _, v in self._add_stats_modifiers do
		accumulated_stats = (accumulated_stats + v)
	end
	
	self._accumulated_stats = accumulated_stats
	
	if skipUpdate then return end
	self.combat_stats = accumulated_stats * self._multiplied_stats
	self.stats_changed:Fire(self.combat_stats, self.combat_stats)
end

-- reapplies all multiplication modifiers to a copy of _accumulated_stats and saves it as combat_stats
function CHumanoid.__reconcileMultipliedCombatStats(self: CustomHumanoid, skipUpdate: boolean?)
	
	local mul_stats: CombatStats.Stats = CombatStats.one
	for _, v in self._mul_stats_modifiers do
		mul_stats = (mul_stats * v)
	end
	self._multiplied_stats = mul_stats
	
	if skipUpdate then return end
	self.combat_stats = self._accumulated_stats * mul_stats
	self.stats_changed:Fire(self.combat_stats, self.combat_stats)
end

function CHumanoid.__reconcileAllCombatStats(self: CustomHumanoid)
	
	self:__reconcileAddedCombatStats(true)
	self:__reconcileMultipliedCombatStats()
end

function CHumanoid.setAddedStats(self: CustomHumanoid, identifier: string, new_stats: ModifierStats.Modifier?)
	local old_stats = self._add_stats_modifiers[identifier]
	if old_stats == new_stats then return end
	if old_stats then
		self._accumulated_stats = (self._accumulated_stats - old_stats)
	end
	
	if new_stats then
		if not getmetatable(new_stats) then
			new_stats = ModifierStats.fromRaw(new_stats:: ModifierStats.RawModifier)
		end
		
		self._accumulated_stats = (self._accumulated_stats + new_stats)
	end
	self._add_stats_modifiers[identifier] = new_stats
	
	self.combat_stats = (self._accumulated_stats * self._multiplied_stats)
	
	
	
	self.stats_changed:Fire(self.combat_stats, ModifierStats.fromRaw(new_stats) - (old_stats or {}:: ModifierStats.RawModifier))
	
end

function CHumanoid.setMultipliedStats(self: CustomHumanoid, identifier: string, new_stats: ModifierStats.Modifier?)
	local old_stats = self._mul_stats_modifiers[identifier]
	if old_stats == new_stats then return end
	if old_stats then
		self._accumulated_stats = (self._accumulated_stats / old_stats)
	end
	if new_stats then
		self._multiplied_stats = (self._multiplied_stats * new_stats)
	end
	self._mul_stats_modifiers[identifier] = new_stats
	
	self.combat_stats = (self._accumulated_stats * self._multiplied_stats)
	
	self.stats_changed:Fire(self.combat_stats, ModifierStats.fromRaw(new_stats) - (old_stats or {}:: ModifierStats.RawModifier))

end

function CHumanoid.setAttribute(self: CustomHumanoid, id: string, new: any?)
	
	self._attributes[id] = new
	task.defer(self.static.onAttributeChange, self, id, new)
end
function CHumanoid.getAttribute(self: CustomHumanoid, id: string)
	return self._attributes[id]
end

-- Initial purpose of implementation: for 'Moves' to know which theme to pass to clients
function CHumanoid.registerEquip(self: CustomHumanoid, group: string, item: any)
	self.equipment[group] = item
	
	local data: any = item:getData()
	
	self:setAddedStats(group, data.stats)
	if item.level then
		self:setAddedStats(`{group}Lv`, data.lv_stats * item.level)
	end
	if item.runes then
		self:setAddedStats(`{group}Rune`, item.runes)
	end
end

function CHumanoid.registerUnequip(self: CustomHumanoid, group: string)
	
	self.equipment[group] = nil
	
	self:setAddedStats(group, nil)
	self:setAddedStats(`{group}Lv`, nil)
	self:setAddedStats(`{group}Rune`, nil)
	
end

-- <<< Combat Stats

local Waiting = {}:: {[Instance]: {thread}}

function CHumanoid.new(instance: Model, type: string, hp: number?): CustomHumanoid
	local static = humanoids_info[type] or default_humanoid_info
	
	local detectedPlayer = Players:GetPlayerFromCharacter(instance):: Player?
	
	local humanoid = setmetatable({
		static = static;
		hp = math.min(static.baseCombatStats.MaxHealth, hp or static.baseCombatStats.MaxHealth);
		adornee = instance;
		died = Signal.new();
		stats_changed = Signal.new();
		
		_death_credit = nil;
		_credit_period = 0;
		_player = detectedPlayer;
		
		special_stats = SpecialStats.new();
		effects = {};
		equipment = {}:: {[string]: any?};
		
		_multiplied_stats = ModifierStats.new():: ModifierStats.Modifier,
		_accumulated_stats = static.baseCombatStats:: ModifierStats.Modifier, -- valid because at init, no accumulated_stats exist
		combat_stats = static.baseCombatStats, -- same as accumulated_stats because no multiplications exist
		
		_add_stats_modifiers = {}:: {[string]: ModifierStats.Modifier},
		_mul_stats_modifiers = {}:: {[string]: ModifierStats.Modifier},
		_team = DEFAULT_TEAM,
		
		_attributes = {}:: {[string]: any?}; -- for special properties that specific humanoid types may access
	}, CHumanoid):: CustomHumanoid
	
	activeHumanoids[instance] = humanoid
	if detectedPlayer then
		activeHumanoids[detectedPlayer] = humanoid
		
		humanoid.died:Once(function()
			-- this could be overwritten if a new humanoid was built on the same player before this one died, so check if it's the same
			if activeHumanoids[detectedPlayer] == humanoid then
				activeHumanoids[detectedPlayer] = nil
			end
		end)
		
		PlayerHumanoidCreated:Fire(detectedPlayer, humanoid)
	end
	
	humanoid:reconcileParent()
	
	if Waiting[instance] then
		for _, t in Waiting[instance] do
			if coroutine.status(t) == "suspended" then
				coroutine.resume(t)
			end
		end
		Waiting[instance] = nil
	end
	
	return humanoid
end

PlayerInventories.Equipped:Connect(function(player: Player, group: string | false, item: any)
	local chum = assert(getCHumanoid(player), `Failed to update stats for {player.Name}'s humanoid because it doesn't exist`)
	local group = tostring(group)
	chum:registerEquip(group, item)
end)

PlayerInventories.Unequipped:Connect(function(player: Player, group: string | false, item)
	local chum = getCHumanoid(player)
	-- since dying is a common occurrence of unequipping, asserting chum is replaced with simply silent exitting
	if not chum then return end
	
	local group = tostring(group)
	chum:registerUnequip(group)
end)

return {

	modelDamagePacket = modelDamagePacket,
	modelHitPacket = modelHitPacket,
	modelHealPacket = modelHealPacket,

	rawDamagePacket = damagePacket,
	rawHitPacket = hitPacket,
	rawHealPacket = healPacket,

	newHumanoid = CHumanoid.new,
	
	HumanoidTypes = humanoids_info,
	
	getHumanoid = getCHumanoid,
	
	WaitForHumanoid = function(adornee: Model | Player, timeout: number?): CustomHumanoid
		local initialQueryResult = getCHumanoid(adornee)
		if initialQueryResult then return initialQueryResult end
		Waiting[adornee] = Waiting[adornee] or {}
		local found = false
		table.insert(Waiting[adornee], coroutine.running())
		
		if timeout then
			local timeoutThread = task.delay(timeout, function()
				if not found then
					warn(`WaitForHumanoid timed out for expected adornee {adornee:GetFullName()}`)
				end
				return nil
			end)
		end
		
		coroutine.yield()
		found = true
		return getCHumanoid(adornee):: CustomHumanoid
	end,
	
}