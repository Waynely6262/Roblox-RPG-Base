--!strict
local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Root = game:GetService("ServerScriptService").Root

local Tween = require(ReplicatedStorage.Modules.Utility.Tween)
local TweenCallback = require(ReplicatedStorage.Modules.Utility.TweenCallback)
local RunOnNextFrame = require(ReplicatedStorage.Modules.Utility.RunOnNextFrame)
local TweenObject = require(ReplicatedStorage.Modules.Utility.TweenObject)
local EasingFunctions = require(ReplicatedStorage.Modules.Utility.EasingFunctions)
local Finder = require(ReplicatedStorage.Modules.Utility.Finder)
local EmitterUtil = require(ReplicatedStorage.Modules.Utility.Emit)
local KnockbackTypes = require(ReplicatedStorage.Modules.Game.KnockbackTypes)
local Config = require(ReplicatedStorage.Modules.Game.Config)
local CardData = require(ReplicatedStorage.Modules.Data.Cards)

local Remote = require(Root.Remotes)
local StatusEffects = require(Root.StatusEffects)
local CollisionGroups = require(Root.CollisionGroups)
local Teams = require(Root.Other.Teams)
local Entities = require(Root.World.Entities)
local CombatStats = require(Root.World.Entities.CombatStats)
local ModifierStats = require(Root.World.Entities.CombatStatsModifier)

local DamagePacketHandler = require(script.DamagePacketHandler)
local HealPacketHandler = require(script.HealPacketHandler)
local BezierParams = require(script.BezierParams)
local Spatial = require(script.SpatialQuery)
local CastUtil = require(script.CastUtil)

local E = ReplicatedStorage.Remotes:WaitForChild("MainE"):: RemoteEvent
local F = ReplicatedStorage.Remotes:WaitForChild("MainF"):: RemoteFunction

local rand = Random.new()

local fxFolder = Teams.get("fx"):getFolder()

local NeutralHumanoid = Entities.newHumanoid(Instance.new("Model"), "", math.huge)
NeutralHumanoid:changeTeam()
local NeutralOverlapParams = NeutralHumanoid:getOverlapParams()
local NeutralRaycastParams = NeutralHumanoid:getRaycastParams()
NeutralHumanoid:kill()

local function getHRP(H: Entities.CustomHumanoid): BasePart?
	return H.adornee:FindFirstChild("HumanoidRootPart"):: BasePart?
end

local function setAnchored(h: Entities.CustomHumanoid, enabled: boolean?)
	local hrp = getHRP(h)
	if hrp then
		hrp.Anchored = enabled == true
	end
end

local function weldToRootPart(h: Entities.CustomHumanoid, p: BasePart)
	
	local w = Instance.new("Weld")
	
	w.Part0 = getHRP(h)
	w.Part1 = p
	w.Name = p.Name .. "_weld"
	w.Parent = p
end

local function vfxDebris(n: Instance, dur: number?)
	
	dur = dur or 5
	
	EmitterUtil.setEnabled(n, false)
	for _, v in n:GetDescendants() do
		if v:IsA("BasePart") then
			v.Transparency = 1
		end
	end
	
	task.defer(function()
		
		task.wait(dur)
		n:Destroy()
	end)
end

local function repeatFor(t: number, f: (any) -> (any), hog_scheduler: boolean?)
	
		local finish = os.clock() + t
	if hog_scheduler then
		while os.clock() < finish do
			f()
		end
	else
		local running = coroutine.running()
		
		local cnxn: RBXScriptConnection
		
		cnxn = RunService.Heartbeat:Connect(function()
			f()
			if os.clock() >= finish then
				cnxn:Disconnect()
				coroutine.resume(running)
			end
		end)
	end
	coroutine.yield()
end

local function assertVector(v: Vector3): Vector3
	return v.Unit ~= Vector3.zero and v.Unit or Vector3.zero
end

local MovesAsync = {}
warn("high priority todo: " .. debug.info(1, "lnf"))
--TODO: Add support for NPCs to be able to cast moves (accept no "player" object, or create "owner" object class to pass)
do
	
	local impact_addstats = ModifierStats.new(10, nil, 10, nil, nil, nil, 5)
	local impact_mulstats = ModifierStats.new(1.1, nil, nil, nil, nil, nil, nil)
	
	local addstats = {}:: CombatStats.RawModifier
	local mulstats = ModifierStats.new(1.5, nil, nil, nil, nil, nil, 0.9)
	
	local add_attack_stats: CombatStats.RawModifier = {Damage = 10; AttackSize = 4; AttackSpeed = 10}
	
	MovesAsync.default = function(_: number, humanoid: Entities.CustomHumanoid, origin: Vector3, position: any)
		local position = assert(typeof(position) == "Vector3") and position:: Vector3
		
		local direction = (position - origin).Unit
		
		local new = ReplicatedStorage.Models.Effects.KineticBlastTrail:Clone()
		
		local info: CombatStats.Stats = (humanoid.combat_stats + add_attack_stats):clone()
		
		-- apply base values
		
		local blastRadius = info.AttackSize
		local radius = math.sqrt(info.AttackSize)
		local range = 60 + 2 * radius
		
		new:ScaleTo(radius)
		new.Parent = fxFolder
		
		local function interp_callback(pos1: Vector3, pos2: Vector3, t: number)
			new:PivotTo(CFrame.new(pos1, pos2))
		end
		interp_callback(origin, origin + direction, 0)
		
		local result = CastUtil.sphereQueryAsync(
			origin,
			radius,
			direction,
			range,
			10 + info.AttackSpeed,
			humanoid:getRaycastParams(),
			humanoid:getOverlapParams(),
			interp_callback
		)
		Remote.StreamFireClients(origin, "ca", "shrinkOut", new)
		

		local this = coroutine.running()
		
		local targets = {}:: {[Model]: DamagePacketHandler.Packet}
		
		if result then
			targets[result.Instance.Parent:: Model] = {atk_stats = (info + impact_addstats) * impact_mulstats}
		end
		
		local finalPos = result and (result:: RaycastResult).Position or (origin + direction * range)
		
		-- predefine this to save some memory by reusing packet info
		local packetInfo: DamagePacketHandler.Packet = {atk_stats = (info + addstats) * mulstats}
		for _, v in Spatial.query(finalPos, blastRadius, humanoid:getOverlapParams()) do
			targets[v.Parent:: Model] = targets[v.Parent:: Model] or packetInfo
		end
		Remote.StreamFireClients(finalPos, "Emit", nil, "build", ReplicatedStorage.Models.Effects.KineticImpact, CFrame.new(finalPos), 2)
		Remote.StreamFireClients(finalPos, "ca", "sphere", blastRadius, finalPos, Color3.new(1,1,0.5))
		
		DamagePacketHandler(humanoid, targets, finalPos)
		
		vfxDebris(new)
		
		
	end
	
	MovesAsync.blast = MovesAsync.default
end
do
	local addstats = ModifierStats.new(5, nil, nil, nil, nil, nil, nil)
	local mulstats = ModifierStats.new(1, nil, 2, nil, nil, nil, 0.25)
	
	local impact_addstats = ModifierStats.new(10, nil, 10, nil, nil, nil, 5)
	local impact_mulstats = ModifierStats.new(1.1, nil, 2, nil, 1.25, 1.25)
	
	local final_blast_addstats = ModifierStats.new(3, nil, nil, nil, nil, nil, nil)
	local final_blast_mulstats = ModifierStats.new(nil, nil, nil, nil, nil, nil, 0.5)
	
	MovesAsync.pulsar = function(level: number, humanoid: Entities.CustomHumanoid, origin: Vector3, position: any)
		local position = assert(typeof(position) == "Vector3") and position:: Vector3
		local direction = (position - origin).Unit

		local new = ReplicatedStorage.Models.Effects.KineticBlastTrail:Clone()

		local info: CombatStats.Stats = (humanoid.combat_stats):clone()
		
		local blastRadius = info.AttackSize * 15
		local radius = info.AttackSize * 2
		
		local studSpeed = 30 * info.AttackSpeed
		
		new:ScaleTo(radius)
		
		new.Parent = fxFolder
		
		local pulseCount = 3 * math.ceil(math.sqrt(level))
		
		local duration = 1 + pulseCount / math.sqrt(studSpeed)
		
		local interval = duration / (pulseCount + 1)
		
		local range = duration * studSpeed
			
		local nextT = 0
		
		local OverlapParameters = humanoid:getOverlapParams()
		
		local packetInfo: DamagePacketHandler.Packet = {atk_stats = (info + addstats) * mulstats}
		local function interp_callback(pos1: Vector3, pos2: Vector3, t: number)
			new:PivotTo(CFrame.new(pos1, pos2))
			
			if t >= nextT then
				nextT += interval
				
				Remote.StreamFireClients(pos1, "ca", "sphere", blastRadius, pos1, Color3.new(1,1,1))
				Remote.StreamFireClients(pos1, "Emit", nil, "build", ReplicatedStorage.Models.Effects.KineticImpact, CFrame.new(pos1), 2)
				local targets = {}:: {[Model]: DamagePacketHandler.Packet}


				for _, v in Spatial.query(pos1, blastRadius, OverlapParameters) do
					targets[v.Parent:: Model] = targets[v.Parent:: Model] or packetInfo
				end
				
				DamagePacketHandler(humanoid, targets, pos1)
				
				interp_callback(pos1,pos2,t) -- in case the nextT was already reached
			end
		end
		interp_callback(origin, origin + direction, -1)

		local result = CastUtil.sphereQueryAsync(
			origin,
			radius,
			direction,
			range,
			studSpeed,
			humanoid:getRaycastParams():: RaycastParams,
			humanoid:getOverlapParams(),
			interp_callback
		)
		-- final impact
		local this = coroutine.running()

		local targets = {}:: {[Model]: DamagePacketHandler.Packet}

		local packetInfo: DamagePacketHandler.Packet = {atk_stats = (info + impact_addstats) * impact_mulstats}
		
		if result then
			targets[result.Instance.Parent:: Model] = packetInfo
		end

		local finalPos = result and (result:: RaycastResult).Position or (origin + direction * range)


		for _, v in Spatial.query(finalPos, blastRadius, OverlapParameters) do
			targets[v.Parent:: Model] = targets[v.Parent:: Model] or packetInfo
		end
		Remote.StreamFireClients(finalPos, "ca", "sphere", blastRadius, finalPos, Color3.new(1,1,1))
		
		DamagePacketHandler(humanoid, targets, finalPos)

		Remote.StreamFireClients(finalPos, "Emit", nil, "build", ReplicatedStorage.Models.Effects.KineticImpact, CFrame.new(finalPos), 2)

		vfxDebris(new)


	end
end

MovesAsync.shell = function(lv: number, humanoid: Entities.CustomHumanoid, _: Vector3)

	local new = ReplicatedStorage.Models.Effects.Shell.Handle.Attachment:Clone()
	
	new.Parent = getHRP(humanoid):: any
	
	local duration = 1 + math.sqrt(lv)
	
	StatusEffects.setEffect(humanoid, "immune", duration, lv)
	task.delay(duration - 1, vfxDebris, new, nil)
	

end


MovesAsync.healrain = function(lv: number, humanoid: Entities.CustomHumanoid, spot: Vector3)
	
	local new = ReplicatedStorage.Models.Effects.Shell:Clone()
	
	local info: CombatStats.Stats = humanoid.combat_stats:clone()

	local blastRadius = math.sqrt(info.AttackSize) + 25
	
	local targets = {}
	local packetInfo: HealPacketHandler.Packet = {add = lv * 10; percent = math.sqrt(0.1 * lv); effects = {{"regen"; lv; lv}}}
	for _, v in Spatial.query(spot, blastRadius, NeutralOverlapParams) do
		targets[v.Parent:: Model] = targets[v.Parent:: Model] or packetInfo
	end

	HealPacketHandler(humanoid, targets)
	
	
	new:ScaleTo(blastRadius)
	new:PivotTo(CFrame.new(spot))
	
	new.Parent = fxFolder
	
	task.delay(1, vfxDebris, new)
end


do
	local addstats = ModifierStats.new(5, nil, nil, nil, nil, nil, nil)
	local mulstats = ModifierStats.new(1, nil, 2, nil, nil, nil, 0.25)

	local impact_addstats = ModifierStats.new(10, nil, 10, nil, nil, nil, 5)
	local impact_mulstats = ModifierStats.new(1.1, nil, 2, nil, 1.25, 1.25)

	local final_blast_addstats = ModifierStats.new(3, nil, nil, nil, nil, nil, nil)
	local final_blast_mulstats = ModifierStats.new(nil, nil, nil, nil, nil, nil, 0.5)

	local attack_addstats = {AttackSize = 8; AttackSpeed = 10;}:: CombatStats.RawModifier

	MovesAsync.fireball = function(_: number, humanoid: Entities.CustomHumanoid, origin: Vector3, position: any)
		local position = assert(typeof(position) == "Vector3") and position:: Vector3
		
		local new = ReplicatedStorage.Models.Effects.Fireball:Clone()

		local info: CombatStats.Stats = (humanoid.combat_stats + attack_addstats):clone()
		
		local hrp = getHRP(humanoid)

		-- apply base values

		new:ScaleTo(math.sqrt(info.AttackSize))
		new.Parent = fxFolder

		local function interp_callback(cf)
			new:PivotTo(cf)
		end
		interp_callback(CFrame.new(origin, position))

		local BezierParameters = BezierParams.new()
		BezierParameters.Duration = 1 / (1 + math.sqrt(info.AttackSpeed))
		BezierParameters.MaxSegmentLength = info.AttackSize
		BezierParameters.DeflectionRelativeSize = 1
		local _, result, finalCFrame = CastUtil.BezierCast.fromStartFinishAsync(
			origin,
			position,
			BezierParameters,
			interp_callback,
			(hrp and hrp.CFrame.LookVector:Dot((position - origin).Unit) > -0.707 and hrp.CFrame.LookVector) or Vector3.yAxis,
			humanoid:getRaycastParams():: RaycastParams
		)

		
		local this = coroutine.running()
		-- direct impact
		local targets = {}:: {[Model]: DamagePacketHandler.Packet}
		if result then
			targets[result.Instance.Parent:: Model] = { 
				atk_stats = (info + impact_addstats) * impact_mulstats,
				effects = {
					{"fire", 7, 3}
				},
			}
		end
		vfxDebris(new, 5)

		local finalPos = result and (result:: RaycastResult).Position or (finalCFrame.Position)
		
		
		-- blast from impact
		local packetInfo: DamagePacketHandler.Packet = {
			atk_stats = (info + final_blast_addstats) * final_blast_mulstats,
			effects = {
				{"fire", 5, 2}
			}
		}

		for _, v in Spatial.query(finalPos, info.AttackSize, humanoid:getOverlapParams():: OverlapParams) do
			targets[v.Parent:: Model] = targets[v.Parent:: Model] or packetInfo
		end
		Remote.StreamFireClients(finalPos, "ca", "sphere", info.AttackSize, finalPos, Color3.new(1,0.5,0.25))

		DamagePacketHandler(humanoid, targets, finalPos)
		
		Remote.StreamFireClients(finalPos, "Emit", nil, "build", ReplicatedStorage.Models.Effects.FireExplosion, CFrame.new(finalPos), 5)
		
	end
end
do
	local impact_addstats = {Damage = 5;}:: CombatStats.RawModifier
	local impact_mulstats = {Piercing = .5;}:: CombatStats.RawModifier
	
	local add_stats = {Damage = 5;}:: CombatStats.RawModifier
	local mul_stats = {Damage = 0.5; Piercing = 0.1;}:: CombatStats.RawModifier
	
	local attack_addstats = {AttackSize = 3; AttackSpeed = 5;}:: CombatStats.RawModifier
	
	MovesAsync.moonfang = function(_: number, humanoid: Entities.CustomHumanoid, origin: Vector3, position: any)
		local position = assert(typeof(position) == "Vector3") and position:: Vector3
		
		local direction = position - origin
		
		direction = Vector3.new(direction.X, 0, direction.Z)
		if direction.Magnitude == 0 then return end
		
		local new = ReplicatedStorage.Models.Effects.moonfang:Clone()
		
		local info: CombatStats.Stats = (humanoid.combat_stats + attack_addstats):clone()
		
		local range = info.AttackSize + 20
		local queryRadius = info.AttackSize
		local blastRadius = 10 + queryRadius
		
		-- apply base values

		new:ScaleTo(math.sqrt(info.AttackSize))
		new.Parent = workspace
		
		local OverlapParameters = humanoid:getOverlapParams():: OverlapParams
		
		direction = direction.Unit


		local duration = range / info.AttackSpeed
		local finalPos = origin + direction * range
		
		local previousSpatialPos = origin
		local previousUpdate = os.clock()
		
		local packetInfo: DamagePacketHandler.Packet = {
			atk_stats = (info + add_stats) * mul_stats
		}
		
		TweenCallback.run(duration, EasingFunctions.InQuad, function(alpha)
			local pos = origin:Lerp(finalPos, alpha)
			
			
			new:PivotTo(CFrame.new(previousSpatialPos, pos))

			local now = os.clock()
			if now - previousUpdate < 0.15 then return end
			previousUpdate = now

			local targets = {}

			local queryResult = Spatial.fromTo(previousSpatialPos, pos, queryRadius, OverlapParameters)


			for _, v in queryResult do
				targets[v.Parent:: Model] = targets[v.Parent:: Model] or packetInfo
			end
			DamagePacketHandler(humanoid, targets, pos)
			previousSpatialPos = pos

		end)
		
		task.wait(duration)

		local this = coroutine.running()

		local targets = {}:: {[Model]: DamagePacketHandler.Packet}

		local packetInfo: DamagePacketHandler.Packet = {
			atk_stats = (info + impact_addstats) * impact_mulstats
		}

		for _, v in Spatial.query(finalPos, blastRadius, humanoid:getOverlapParams():: OverlapParams) do
			targets[v.Parent:: Model] = packetInfo 
		end

		DamagePacketHandler(humanoid, targets, finalPos)
		Remote.StreamFireClients(finalPos, "ca", "sphere", blastRadius, finalPos, Color3.new(0.75,1,0.25))
		Remote.StreamFireClients(finalPos, "Emit", nil, "build", ReplicatedStorage.Models.Effects.moonfangExplosion, CFrame.new(finalPos), 2)

		vfxDebris(new)


	end
end

do
	

	local template = game.ReplicatedStorage.Models.Misc.CrystalMesh

	local CrystalTInfo = TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local GravityTInfo = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	local baseLifetime = 2
	local variationLifetime = 1

	local function getNextPointVector()
		return rand:NextUnitVector() + Vector3.yAxis

	end


	local function simulateNewCrystal(position: Vector3, emissionDirection: Vector3)

		local pathVector = getNextPointVector() * 8

		local crystal = template:Clone()
		crystal.CFrame = CFrame.new(position - pathVector, position) * CFrame.Angles(-math.pi/2,0,0)
		crystal.Parent = fxFolder
		crystal.Size = Vector3.zero
		local T = TweenService:Create(crystal, CrystalTInfo, {Size = template.Size * (1 + math.random() * 0.2); CFrame = CFrame.new(position, position + pathVector) * CFrame.Angles(-math.pi/2,0,0)})

		T.Completed:Once(function()
			local T2 = TweenService:Create(crystal, GravityTInfo, {Position = crystal.Position - Vector3.new(0, 10, 0); Transparency = 1; Size = Vector3.zero})
			task.wait(baseLifetime + math.random() * variationLifetime)
			T2.Completed:Once(function()
				crystal:Destroy()
			end)
			T2:Play()
		end)

		T:Play()

	end

	local function emit(origin: Vector3, emissionDirection: Vector3, range: number)

		for i = range, 1, -3 do
			for j = 1, math.random(4) do
				simulateNewCrystal(origin + emissionDirection * i, emissionDirection)
			end
		end

	end


	local mulstats = ModifierStats.new(0.25, nil, nil, nil, 0 --[[0 is used here because this modifier shouldn't be used in a context where it would be reversed]])
	MovesAsync.frostbite = function(level: number, humanoid: Entities.CustomHumanoid, origin: Vector3, position: any)
		local position: Vector3 = assert(typeof(position) == "Vector3") and position
		
		local direction = assertVector(position - origin)
		
		direction = Vector3.new(direction.X, 0, direction.Z).Unit

		local Range = 15 * level
		local Size = 8 + math.log10(level) + humanoid.combat_stats.AttackSize * 0.1

		local targets = {}:: {[Entities.CustomHumanoid]: DamagePacketHandler.Packet}
		
		emit(origin, direction, Range)

		for _, v in Spatial.fromTo(origin, origin + direction * Range, Size, humanoid:getOverlapParams():: OverlapParams) do
			local chum = Entities.getHumanoid(v.Parent:: Model)
			if chum then
				targets[chum] = {atk_stats = humanoid.combat_stats * mulstats}
				chum:setMultipliedStats("frost", {WalkSpeed = 0.25})
			end
		end
		
		task.delay(math.sqrt(level) + 1, function()
			for v, _ in targets do
				v:setMultipliedStats("frost", nil)
			end
		end)
		DamagePacketHandler(humanoid, targets, origin)
		
	end
end

do
	
	local swipe_addstats = ModifierStats.new(5, nil, nil, nil, nil, nil, nil)
	local swipe_mulstats = ModifierStats.new(1, nil, 2, nil, nil, nil, 0.25)

	local impact_addstats = ModifierStats.new(10, nil, 10, nil, nil, nil, 5)
	local impact_mulstats = ModifierStats.new(1.1, nil, 2, nil, 1.25, 1.25)
	
	local level_addstats = {
		ModifierStats.new(5);
		ModifierStats.new(5);
		ModifierStats.new(5);
		ModifierStats.new(5);
	}
	
	local level_mulstats = {
		ModifierStats.new();
		ModifierStats.new(1.1);
		ModifierStats.new(1.25);
		ModifierStats.new(1.5);
	}
	
	
	
	MovesAsync.dash = function(level: number, humanoid: Entities.CustomHumanoid, origin: Vector3, direction: any)
		local direction: Vector3 = assert(typeof(direction) == "Vector3") and direction
		
		direction = assertVector(direction)

		local info: CombatStats.Stats = humanoid.combat_stats:clone()

		local Range = 30 * math.sqrt(level)
		local Size = 8 + math.log10(level) + info.AttackSize * 0.1

		local result = CastUtil.sphereQueryInstant(
			origin + Vector3.new(0,0.1,0),
			2,
			direction,
			Range,
			humanoid:getRaycastParams(),
			humanoid:getOverlapParams()
		)

		local finalPos = if result then result.Position else origin + direction * Range
		
		local cf = CFrame.new(finalPos, finalPos + direction)
		
		local baseDuration = (info.AttackSpeed * Range) / 300
		local alpha = result and (result.Distance / Range) or 1
		local appliedDuration = baseDuration * alpha
		
		local exitVelocity = direction * Range / baseDuration / 2
		
		if humanoid._player then
			E:FireClient(humanoid._player, {
				{"kb", "reset_impulse", exitVelocity}:: {any},
				{"kb", "cframe", cf, appliedDuration}:: {any},
			})
		else
			local hrp = getHRP(humanoid):: BasePart?
			if not hrp then warn("Failed to retrieve HRP") return end
			KnockbackTypes.reset_impulse(hrp, exitVelocity)
			KnockbackTypes.cframe(hrp, cf, appliedDuration)
		end
	
		local fx = ReplicatedStorage.Models.Effects.dashTrail:Clone()
		fx.CFrame = CFrame.new(origin, finalPos)
		fx.Parent = fxFolder
		Remote.StreamFireClients(origin, "Emit", nil, "build", ReplicatedStorage.Models.Effects.tpBegin, fx.CFrame)
		local t = TweenService:Create(fx, TweenInfo.new(appliedDuration), {CFrame = cf})
		t:Play()
		t.Completed:Once(function()
			vfxDebris(fx)
			Remote.StreamFireClients(origin, "Emit", nil, "build", ReplicatedStorage.Models.Effects.tpFinish, fx.CFrame)
		end)
		
		local targets = {}:: {[Model]: DamagePacketHandler.Packet}

		local packetInfo: DamagePacketHandler.Packet = {atk_stats = (info + level_addstats[level] + swipe_addstats) * (level_mulstats[level] * swipe_mulstats)}

		for _, v in Spatial.fromTo(origin, finalPos, Size, humanoid:getOverlapParams():: OverlapParams) do
			targets[v.Parent:: Model] = packetInfo 
		end 
		if result then
			targets[result.Instance.Parent:: Model] = {
				atk_stats = (info + level_addstats[level] + impact_addstats) * (level_mulstats[level] + impact_mulstats)
			}
		end

		DamagePacketHandler(humanoid, targets, finalPos)
	end
end

do
	
	local swipe_addstats = ModifierStats.new(5, nil, nil, nil, nil, nil, nil)
	local swipe_mulstats = ModifierStats.new(1, nil, 2, nil, nil, nil, 0.25)
	
	local impact_addstats = ModifierStats.new(10, nil, 10, nil, nil, nil, 5)
	local impact_mulstats = ModifierStats.new(1.1, nil, 2, nil, 1.25, 1.25)
	
	local level_addstats = setmetatable({
		ModifierStats.new(5);
		ModifierStats.new(5);
		ModifierStats.new(5);
		ModifierStats.new(5);
	}, {__index = function() return ModifierStats.new(5) end})
	
	local level_mulstats = setmetatable({
		ModifierStats.new();
		ModifierStats.new(1.1);
		ModifierStats.new(1.25);
		ModifierStats.new(1.5);
	}, {__index = function() return ModifierStats.new(2) end})
	
	
	
	MovesAsync.leap = function(level: number, humanoid: Entities.CustomHumanoid, origin: Vector3)

		local info = humanoid.combat_stats:clone()
		
		local direction = Vector3.yAxis
		
		local Range = 20 * math.sqrt(level)
		local Size = 8 + math.log10(level) + info.AttackSize * 0.1
		
		local result = CastUtil.sphereQueryInstant(
			origin,
			2,
			direction,
			Range,
			humanoid:getRaycastParams(),
			humanoid:getOverlapParams()
		)
		
		local finalPos = if result then result.Position else origin + direction * Range
		
		local cf = CFrame.new(finalPos) * humanoid.adornee:GetPivot().Rotation
		
		local baseDuration = (info.AttackSpeed * Range) / 300
		local alpha = result and (result.Distance / Range) or 1
		local appliedDuration = baseDuration * alpha
		
		local exitVelocity = direction * Range / baseDuration / 2
		
		if humanoid._player then
			E:FireClient(humanoid._player, {
				{"kb", "reset_impulse", exitVelocity}:: {any},
				{"kb", "cframe", cf, appliedDuration}:: {any},
			})
		else
			task.delay(0, function()
				local hrp = getHRP(humanoid):: BasePart?
				if not hrp then warn("Failed to retrieve HRP") return end
				KnockbackTypes.reset_impulse(hrp, exitVelocity)
				KnockbackTypes.cframe(hrp, cf, appliedDuration)
			end)
		end
		
		local fx = ReplicatedStorage.Models.Effects.dashTrail:Clone()
		fx.CFrame = CFrame.new(origin, finalPos)
		fx.Parent = fxFolder
		Remote.StreamFireClients(origin, "Emit", nil, "build", ReplicatedStorage.Models.Effects.tpBegin, fx.CFrame)
		local t = TweenService:Create(fx, TweenInfo.new(appliedDuration), {CFrame = cf})
		t:Play()
		t.Completed:Once(function()
			vfxDebris(fx)
			Remote.StreamFireClients(origin, "Emit", nil, "build", ReplicatedStorage.Models.Effects.tpFinish, fx.CFrame)
		end)
		
		local targets = {}:: {[Model]: DamagePacketHandler.Packet}
		
		local packetInfo: DamagePacketHandler.Packet = {atk_stats = (info + level_addstats[level] + swipe_addstats) * level_mulstats[level] * swipe_mulstats}
		
		for _, v in Spatial.fromTo(origin, finalPos, Size, humanoid:getOverlapParams():: OverlapParams) do
			targets[v.Parent:: Model] = packetInfo 
		end 
		if result then
			targets[result.Instance.Parent:: Model] = {
				atk_stats = (info + level_addstats[level] + impact_addstats) * level_mulstats[level] * impact_mulstats
			}
		end
		
		DamagePacketHandler(humanoid, targets, finalPos)
	end
end

do
	local addstats = ModifierStats.new(100, nil, 4, nil, nil, 1, 50)
	local mulstats = ModifierStats.new(1.5, nil, 2, nil, nil, 0.5, 1.25)
	
	MovesAsync.reign = function(lv: number, humanoid: Entities.CustomHumanoid, origin: Vector3, strikePoint: any)
		local strikePoint = assert(typeof(strikePoint) == "Vector3") and strikePoint:: Vector3

		--strikePoint = Vector3.new(strikePoint.X, Config.GroundLevel, strikePoint.Z)

		local info: CombatStats.Stats = humanoid.combat_stats:clone()

		local radius = 20 + math.sqrt(info.AttackSize)
		local speed = math.sqrt(info.AttackSpeed)

		local range = math.min(128 + info.AttackSize, 160)

		local params = humanoid:getOverlapParams():: OverlapParams
		
		Remote.StreamFireClients(strikePoint, "Emit", nil--[[originUser]], "build", ReplicatedStorage.Models.Misc.AttackIndicatorCircle, CFrame.new(strikePoint), 5, radius)

		task.wait(1 + speed)

		local m = ReplicatedStorage.Models.Effects.reignShape:Clone()
		m.Parent = fxFolder
		m:PivotTo(CFrame.new(strikePoint) * CFrame.Angles(0, 0, math.pi/2))
		m:ScaleTo(radius)
		
		local packetInfo: DamagePacketHandler.Packet = {
			atk_stats = (info + addstats) * mulstats
		}
		
		local i_p, f_p = {
			Material = Enum.Material.Neon;
			Color = Color3.new(0.5,1,0.25);
			Size = Vector3.new(0, 2048, 0);
			Position = strikePoint;
		},
		{
			Size = Vector3.new(radius, 2048, radius);
			Color = Color3.new(1,1,1);
			Transparency = 1;
		}
		
		for i = 1, 3 do


			EmitterUtil.existing(m)

			local targets = {}:: {[Model]: DamagePacketHandler.Packet}

			local result = Spatial.fromPartBounds(
				m.Handle,
				params
			)


			for _, v in result do
				targets[v.Parent:: Model] = packetInfo
			end
			DamagePacketHandler(humanoid, targets, strikePoint)
			Remote.StreamFireClients(strikePoint, "ca", "sphere", radius, strikePoint, Color3.new(0.5,1,0.2))
			Remote.StreamFireClients(strikePoint, "mfx", "Cylinder", i_p, f_p, "OutExpo", 1.2)

			task.wait(.5/ (1 + info.AttackSpeed))
		end

		vfxDebris(m)

	end
end

do
	local addstats = ModifierStats.new(5, nil, 0, nil, nil, 1, 0)
	local mulstats = ModifierStats.new(1.1, nil, 0.9, nil, nil, 1, 0.7)

	MovesAsync.whirlwind = function(lv: number, humanoid: Entities.CustomHumanoid, origin: Vector3, strikePoint: any)
		local strikePoint = assert(typeof(strikePoint) == "Vector3") and strikePoint:: Vector3

		--strikePoint = Vector3.new(strikePoint.X, Config.GroundLevel, strikePoint.Z)

		local info: CombatStats.Stats = humanoid.combat_stats:clone()

		local radius = 10 * lv^2

		local packetInfo: DamagePacketHandler.Packet = {
			atk_stats = (info + addstats) * mulstats
		}


		local targets = {}:: {[Model]: DamagePacketHandler.Packet}

		local result = Spatial.query(origin, radius, humanoid:getOverlapParams())

		for _, v in result do
			targets[v.Parent:: Model] = packetInfo
		end
		
		DamagePacketHandler(humanoid, targets, strikePoint)
		Remote.StreamFireClients(origin, "ca", "sphere", radius, origin, Color3.new(0.5,1,1))
	end
end

do
	
	local addstats = ModifierStats.new(20, nil, nil, nil, nil, nil, 20)
	local mulstats = ModifierStats.new(1.2, nil, 1.5, nil, nil, 0.5, nil)

	MovesAsync.beam = function(lv: number, humanoid: Entities.CustomHumanoid, origin: Vector3, strikePoint: any)
		local strikePoint = assert(typeof(strikePoint) == "Vector3") and strikePoint:: Vector3
		local dir = (strikePoint - origin).Unit
		if not (dir.Magnitude > 0) then
			warn(`Invalid strike point: equivalent to the origin, causing nan direction components`)
			return 
		end
		
		local info: CombatStats.Stats = humanoid.combat_stats:clone()

		local radius = 3 + math.sqrt(info.AttackSize)
		origin += dir * radius
		local blastRadius = radius * 2
		local speed = 512 + math.sqrt(info.AttackSpeed)

		local range = 256 + info.AttackSize

		local params = humanoid:getOverlapParams():: OverlapParams

		local indicatorCircle = ReplicatedStorage.Models.Misc.AttackIndicatorCircle:Clone()
		indicatorCircle:ScaleTo(radius)
		indicatorCircle:PivotTo(CFrame.new(origin, strikePoint) * CFrame.Angles(math.pi/2, 0, 0))
		indicatorCircle.Parent = fxFolder
		indicatorCircle.Handle.Transparency = 0

		EmitterUtil.existing(indicatorCircle)

		task.wait(.25 + 1/speed)
		
		local ray_result = CastUtil.sphereQueryAsync(origin, math.min(radius, 2), dir, range, speed, humanoid:getRaycastParams(), humanoid:getOverlapParams(), function(pos0, pos1, t: number)
			indicatorCircle:PivotTo(CFrame.new(pos0, pos1) * CFrame.Angles(math.pi/2, 0, 0))
		end)
		
		local distance = ray_result and (ray_result.Position - origin).Magnitude or range
		local finalPos = origin + dir * distance

		local i_p, f_p = {
			Material = Enum.Material.Neon;
			Color = Color3.new(0.4,0.65,1);
			Size = Vector3.new(radius, distance, radius);
			CFrame = CFrame.new(origin + dir * distance/2, origin) * CFrame.Angles(math.pi/2, 0, 0);
		},
		{
			Size = Vector3.new(0, distance, 0);
			Color = Color3.new(.25,0,.25);
			Transparency = 1;
		}

		local targets = {ray_result and ray_result.Instance.Parent}:: {[Model]: DamagePacketHandler.Packet}

		local result = Spatial.query(finalPos, blastRadius, humanoid:getOverlapParams())
		
		local packetInfo: DamagePacketHandler.Packet = {
			atk_stats = (info + addstats) * mulstats
		}
		
		for _, v in result do
			targets[v.Parent:: Model] = packetInfo
		end
		DamagePacketHandler(humanoid, targets, strikePoint)
		Remote.StreamFireClients(strikePoint, "ca", "sphere", radius, finalPos, Color3.new(0.6,0.4,1))
		Remote.StreamFireClients(strikePoint, "mfx", "Cylinder", i_p, f_p, "OutExpo", 1.2)

		vfxDebris(indicatorCircle, 3)

	end
end

return MovesAsync