--!strict
local NPCs = {}
local NPC = {}
NPC.__index = NPC


NPCs.class = NPC




local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game.ReplicatedStorage
local Tools = require(ServerScriptService.Root.Tools)

local Looker = require(script.Looker)
local Entities = require(ServerScriptService.Root.World.Entities)
local Pathfinder = require(ReplicatedStorage.Modules.Utility.Pathfind)
local CollisionGroups = require(ServerScriptService.Root.CollisionGroups)
local Target = require(ServerScriptService.Root.Other.OptimalTarget)

local Heartbeat = RunService.Heartbeat

local Templates = setmetatable({
	
}, {
	__index = function()
		return ReplicatedStorage.Models.Entities.DefaultRig
	end,
}):: {[string]: {HumanoidRootPart: BasePart, Humanoid: Humanoid} & Model}

for i, v in ReplicatedStorage.Models.Entities:GetChildren() do
	local h = v:FindFirstChildWhichIsA("Humanoid")
	
	if h then
		Templates[v.Name] = v:: any
	end
end

local pointsOfInterest = {}
--TODO.move_to_config
local maxSight = 256
local fov = 180
local fov_trig_ratio = math.cos(fov/2)

local function table_random(t)
	return t[math.random(1, #t)]
end

function NPCs.new(name: string)
	local self = {}
	
	local RigTemplate = Templates[name]
	
	self.Rig = RigTemplate:Clone()
	--TODO: Create a simplified animation module for
	local AnimatorScript = script.Animate:Clone()
	AnimatorScript.Parent = self.Rig	
	AnimatorScript.Enabled = true
	self.Viewpoint = (self.Rig:: any).Head:: BasePart
	self.Humanoid = (self.Rig:: any).Humanoid:: Humanoid
	self.chumanoid = Entities.newHumanoid(self.Rig, name)
	self.RootPart = self.Rig.HumanoidRootPart:: BasePart
	self.Looker = Looker.new(self.RootPart)
	self.HomePosition = nil:: Vector3?
	
	self.StateRunner = nil:: RBXScriptConnection?
	self.state = "roam"
	self._onStateFinished = nil:: () -> ()?

	Tools.equip(self.Rig, "Unarmed", "Weapon", true)
	
	local function onStatsChanged(stats, changes)

		if not changes then return end
		if changes.WalkSpeed then
			self.Humanoid.WalkSpeed = stats.WalkSpeed
		end
	end
	onStatsChanged(self.chumanoid.combat_stats, self.chumanoid.combat_stats)
	self.chumanoid.stats_changed:Connect(onStatsChanged)
	
	
	return setmetatable(self, NPC)
end
type NPC = typeof(NPCs.new(""))

function NPC.newState(self: NPC, n: string?, onHeartbeat: (number) -> ()?, onStateFinished: () -> ()?)
	if n == self.state then return end
	self.state = n
	

	if self.StateRunner then self.StateRunner:Disconnect() end
	if self._onStateFinished then
		(self._onStateFinished:: () -> ())()
	end
	self._onStateFinished = onStateFinished
	if not (n and onHeartbeat) then return end
	
	local Rig = self.Rig
	local RootPart = self.RootPart
	if 
		not (Rig.Parent and RootPart.Parent) or
		not self.chumanoid:isAlive()
	then
		if onStateFinished then
			onStateFinished()
		end
		return
	end
	
	local s, r = pcall(function()
		self.RootPart:SetNetworkOwner()
		return nil
	end)
	
	if not s then warn(`Failed to set network owner ({r})`)  end
	
	self.StateRunner = RunService.Heartbeat:Connect(function(dt)
		if not self.chumanoid:isAlive() then
			self.StateRunner:Disconnect()
			self.StateRunner = nil
			
			if self._onStateFinished then
				self._onStateFinished()
			end
			self._onStateFinished = nil
			
			return
		end
		onHeartbeat(dt)
	end)
		
	
end

function NPC.roam(self: NPC)

	local nextTaskDistribute = os.clock() + math.random(3, 7)
	
	self.Looker:toggle(false)
	
	self:newState("roam", function()
		if os.clock() > nextTaskDistribute then
			nextTaskDistribute = os.clock() + math.random(3, 7)
			Pathfinder.pathfindInterruptable(self.Rig, self.HomePosition:: Vector3 + Vector3.new((math.random() - 0.5) * 2 * (maxSight), 0, (math.random() - 0.5) * 2 * (maxSight)))
		end
		local target = self.chumanoid:getImmediateEnemy()
		if target and target:isAlive() then
			self:attack(target)
		end
	end)
end

function NPC:isRagdolled()
	return self.Humanoid:GetAttribute("Ragdolled")
end

local function getNear(myPos: Vector3, newPos: Vector3, minDist: number): Vector3
	local dir = myPos - newPos
	local dist = dir.Magnitude
	if dist < minDist then
		return myPos
	else
		return newPos + dir.Unit * minDist
	end
end

function NPC.attack(self: NPC, chumanoid: Entities.CustomHumanoid, ...: (Entities.CustomHumanoid) -> ())
	
	if not chumanoid:isAlive() then print(`NPC@{self.chumanoid.adornee.Name} can't attack {chumanoid.adornee.Name} because target is dead`) return end
	
	local targetDiedCnxn: Connection
	
	local function retarget(target: Entities.CustomHumanoid?): Entities.CustomHumanoid?
		if target and target:isAlive() then
			if targetDiedCnxn then
				targetDiedCnxn:Disconnect()
			end
			targetDiedCnxn = target.died:Once(function()
				retarget()
			end)
			return target
		end
		return nil
	end
	
	local fns = {...}	
	
	self:newState("attack", function()
		
		
		
		if chumanoid and chumanoid:isAlive() then
			for _, fn in fns do
				fn(chumanoid)
			end
			
			local targetPosition = chumanoid.adornee:GetPivot().Position;
			
			(self.Humanoid:: Humanoid):MoveTo(getNear(self.RootPart.Position, targetPosition, 4))
			self.Looker:lookAt(targetPosition)
			Target(self.Rig, chumanoid.adornee)
		else
			chumanoid = retarget(self.chumanoid:getImmediateEnemy(), true)
			if not chumanoid then
				self:newState(nil)
				self:roam()
				return
			end
		end
	end, function()
		if targetDiedCnxn then
			targetDiedCnxn:Disconnect()
		end
	end)

end

function NPC:isEntityInView(humanoid: Entities.CustomHumanoid): (boolean?)

	local pos = humanoid.adornee:GetPivot().Position

	local differenceVector = (pos - self.Viewpoint.Position).Unit
	if differenceVector:Dot(self.Viewpoint.CFrame.LookVector) < fov_trig_ratio then
		return false
	end
	--TODO: Add a "Vision" raycast params to the NPC class, for viewing queries such as this one
	local result = workspace:Raycast(self.Viewpoint.Position, differenceVector * maxSight , (self.chumanoid:: Entities.CustomHumanoid):getRaycastParams())
	if result and result.Instance:IsDescendantOf(humanoid.adornee) then
		return true
	end

	return false
end
function NPC.playersInView(self: type, count: number?): {[Player]: Entities.CustomHumanoid}
	local count = count or -1
	local overallResults = {}
	for _, player in Players:GetPlayers() do
		
		local chum = player.Character and Entities.getHumanoid(player.Character)
		if not chum then continue end
		
		local isInView = self:isEntityInView(chum)
		if isInView then
			overallResults[player] = chum
			count -= 1
		end
		if count == 0 then break end
	end
	return overallResults
end

function NPC.despawnAsync(self: NPC)
	self.chumanoid:kill()
	self.Rig:Destroy()
	if self.StateRunner then
		self.StateRunner:Disconnect()
	end
end

export type type = typeof(NPCs.new("Hello World"))

return NPCs