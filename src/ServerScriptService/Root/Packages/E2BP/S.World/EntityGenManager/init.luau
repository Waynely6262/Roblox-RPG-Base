--!strict

-- Manages streaming of instances
----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage
local ServerScriptService = game:GetService("ServerScriptService")

local ItemsGen = require(script.Items)
local Despawnables = require(script.Despawnables)
local Entities = require(ServerScriptService.Root.World.Entities)
local Teams = require(ServerScriptService.Root.Other.Teams)
local NPC = require(script.NPC)
local CollisionGroups = require(ServerScriptService.Root.CollisionGroups)
local CONFIG = require(ReplicatedStorage.Modules.Game.Config)
local Signal = require(ReplicatedStorage.Modules.Utility.Signal)
local NPCCoreLoop = require(script.NPCCoreLoop)
local AccessRS = require(ServerScriptService.Root.Utils.AccessRS)


----------------------------------------------------------------------------------------------------


local Class = {}
Class.__index = Class
local EntityGenManager = {}
EntityGenManager.Class = Class

local npcTeam = Teams.get("EnemyNPC")
npcTeam:setFriendlyFireEnabled(false)
npcTeam:addFriendlyTeam("Despawnables")
npcTeam:addFriendlyTeam("fx")
--npcTeam:addFriendlyTeam("Structures")
npcTeam:getFolder().Parent = Teams.get("Entities"):getFolder()
local structureTeam = Teams.get("Structures")
structureTeam:setFriendlyFireEnabled(false)

function EntityGenManager.new(level: number)
	local self = {
		entities = {}:: {[Entities.CustomHumanoid]: (run: boolean?) -> () | false};
		props = {}:: {[Instance]: RBXScriptConnection};
		level = level:: number;
		min_wall_strength = math.floor(math.sqrt(level));
		max_wall_strength = 100 + level^2;
		_is_loaded = false;
	}
	
	setmetatable(self, Class)
	
	return self
end

function Class.newMob(self: Manager, position: Vector3, mobType: string)
	
	local mob = NPC(mobType)
	
	
	mob.Rig:PivotTo(CFrame.new(position + Vector3.new(0,3,0)))
	mob.HomePosition = position
	
	mob.chumanoid:changeTeam(npcTeam)
	
	--TODO: Turn NPCs into that state-updating data structure Laeron was talmbout
	
	self:registerEntity(mob.chumanoid, NPCCoreLoop[mob.chumanoid.static.coreLoopMethod](mob))
	
	return mob.chumanoid
end

function Class.newStructure(self: Manager, position: Vector3, structureType: string): (Model, Entities.CustomHumanoid?)
	
	
	local M = AccessRS.getStructure(structureType):Clone():: Model
	
	M:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.random() * 2 * math.pi, 0))
	
	if Entities.HumanoidTypes[structureType] then
		local chum = Entities.newHumanoid(M, structureType)
		chum:changeTeam(npcTeam)
		self:registerEntity(chum)
		return M, chum
	else
		self:register(M)
		return M, nil
	end
end

function Class.register(self: Manager, M: Instance)
	if self._is_loaded then
		structureTeam:addChild(M)
	else
		M.Parent = CONFIG.UNLOADED_DIR
	end
	
	self.props[M] = M.Destroying:Once(function()
		self:unregister(M)
	end)	
end

function Class.unregister(self: Manager, M: Instance)
	if self.props[M] then
		(self.props[M]:: RBXScriptConnection):Disconnect()
		self.props[M] = nil
	end
end

function Class.registerEntity(self: Manager, cHum: Entities.CustomHumanoid, updateState: (run: boolean?) -> ()?)
	if self._is_loaded then
 		cHum:reconcileParent()
	else
		cHum.adornee.Parent = CONFIG.UNLOADED_DIR
	end
	
	if updateState then
		updateState(self._is_loaded)
	end

	local function unregister()
		self:unregisterEntity(cHum)
	end

	cHum.died:Once(unregister)
	cHum.adornee.Destroying:Once(unregister)
	

	self.entities[cHum] = updateState or false
end

function Class.unregisterEntity(self: Manager, cHum: Entities.CustomHumanoid)
	local fn = self.entities[cHum]
	if fn then
		fn(false)
		self.entities[cHum] = nil
		-- this intends to destroy the connection for cHum.died.Once in Class.registerEntity. This will double-call the function
		-- which is why this method checks if the index is non-nil first, then immediately clears before calling CHum.kill
		cHum:kill()
	elseif fn == false then
		self.entities[cHum] = nil
		cHum:kill()
	end
end

function Class.spawnItem(self: Manager, position: Vector3, name: string, dynamic: {[string]: any})
	local M = ItemsGen.spawnItem(position, name, dynamic)
	self:register(M)
	return M
end

function Class.dropItem(self: Manager, position: Vector3, item)

	local M = ItemsGen.dropItem(position, item)
	self:register(M)

	return M
end

function Class.newDespawnable(self: Manager, position: Vector3, thing: Model): Model
	local new = Despawnables.new(position, thing)
	self:register(new)
	return new
end

function Class.Load(self: Manager)
	if self._is_loaded then return end
	for m, _ in self.props do
		structureTeam:addChild(m)
	end
	
	for ch, fn in self.entities do
		if fn then
			(fn:: (boolean) -> ())(true)
		end
		ch:reconcileParent()
	end
	
	self._is_loaded = true
end

function Class.Unload(self: Manager)
	if not self._is_loaded then return end
	for v, _ in self.props do
		v.Parent = CONFIG.UNLOADED_DIR
	end
	
	for ch, fn in self.entities do
		if fn then
			(fn:: (boolean) -> ())(false)
		end
		ch.adornee.Parent = CONFIG.UNLOADED_DIR
	end
	self._is_loaded = false
end

function Class.Destroy(self: Manager)
	self:Unload()
	self._is_loaded = true
end

export type Manager = typeof(EntityGenManager.new(1))

return EntityGenManager
