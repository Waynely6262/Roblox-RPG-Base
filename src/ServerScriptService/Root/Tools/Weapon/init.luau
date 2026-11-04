--!strict
local UserDB = require(game.ServerScriptService.Root.Utils.UserDebounce)
local Signal = require(game.ReplicatedStorage.Modules.Utility.Signal)

local Config = require(game.ReplicatedStorage.Modules.Game.Config)
local ToolConfig = require(game.ReplicatedStorage.Modules.PackageConfig.CustomTools)
local CHumanoid = require(game.ServerScriptService.Root.World.Entities)
local CombatStats = require(game.ServerScriptService.Root.World.Entities.CombatStats)
local SpatialQuery = require(game.ServerScriptService.Root.Other.MovesAsync.SpatialQuery)
local Skills = require(game.ServerScriptService.Root.Players.Skills)
local LoadAnimation = require(game.ServerScriptService.Root.Utils.LoadAnimation)

-- Passed values:
-- (Position: Vector3, Direction: Vector3, Queries: tuple(string))
local Queries = {}
for _, v in script:GetChildren() do
	Queries[v.Name] = require(v)
end
-- Written by Grok >>>
export type QueryModuleName = "FrontalCone" | "SweepArc" | "Projectile" | "ForwardThrust"

local WeaponToQueryMap: { [string]: QueryModuleName } = {
	-- Melee blunt/heavy/close-range weapons (mace, hammer, axe, pickaxe, unarmed, dagger)
	["mace"]     = "FrontalCone",
	["hammer"]   = "FrontalCone",
	["axe"]      = "FrontalCone",
	["pickaxe"]  = "FrontalCone",
	["unarmed"]  = "FrontalCone",
	["dagger"]   = "FrontalCone",

	-- Slashing/sweeping weapons
	["sword"]       = "SweepArc",
	["greatsword"]  = "SweepArc",

	-- Long-reach piercing thrust
	["spear"]    = "ForwardThrust",

	-- Ranged projectile (arrow, bolt, thrown knife?, etc.)
	["bow"]      = "Projectile",

	-- Fallback / default behavior
	_default     = "FrontalCone",   -- used when toolType is unknown or nil
}

-- Helper function to get the correct query name (with fallback)
local function GetQueryNameForTool(toolType: string?): QueryModuleName
	if not toolType then
		return WeaponToQueryMap._default
	end

	local mapped = WeaponToQueryMap[toolType]
	if mapped then
		return mapped
	end

	-- Optional: warn about unknown weapon types during development
	warn(`Unknown weapon/tool type '{toolType}' — falling back to FrontalCone`)
	return WeaponToQueryMap._default
end

local function getCharacterForwardXZ(character: Model): Vector3

	local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return Vector3.zAxis end

	-- Take the look vector (forward), flatten to XZ plane, normalize
	local look = root.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)

	if flat.Magnitude < 0.001 then
		-- Rare case: character is perfectly vertical — fallback to some default
		return root.CFrame.RightVector -- or any non-zero horizontal vector
	end

	return flat.Unit
end

-- <<<



local LMB_CD = UserDB.new()

-- intention is to use weak keys mode so if the rig is destroyed then the signal reference is also removed
local UnequippedSignals = setmetatable({}:: {[Model]: Signal.Signal<>}, {__mode = "k"})

local DefaultDuration = 1

local f = {

	click = function(rig: Model, humanoid: Humanoid, tool: Model, item: any, pos)
		-- using attributes to pass values to here, because I don't want to accommodate for passing the Item object through the CustomTools package class

		local data = item and item:getData()
		local toolType: string = data and data.type or "unarmed"

		if LMB_CD:isDebounced(rig) then return end

		local chumanoid = CHumanoid.getHumanoid(rig)
		if not chumanoid then print(`Aborting action because bro ({rig:GetFullName()})'s dead`) return end

		local debounce = DefaultDuration / chumanoid.combat_stats.AttackSpeed
		LMB_CD:setDebounced(rig, debounce)
		
		local executed = false
		task.delay(2, function()
			if not executed then
				error()
			end
		end)
		local function execute()
			executed = true

			if not chumanoid:isAlive() then print("Humanoid died; aborting action") return end

			-----

			local queryFn = Queries[GetQueryNameForTool(toolType)]

			local targets = queryFn(rig, chumanoid, getCharacterForwardXZ(rig), pos)

			------

			for m, v in targets do
				local enemy = CHumanoid.getHumanoid(m)
				if enemy then
					CHumanoid.rawHitPacket(chumanoid, enemy)
				end
			end
		end

		LoadAnimation.once(humanoid, toolType,"click", 1/debounce, execute)

	end,

	_equip = function(rig: Model, humanoid: Humanoid, tool: Model, item: any)
		
		if not UnequippedSignals[rig] then

			UnequippedSignals[rig] = Signal.new()
			rig.Destroying:Once(function()
				UnequippedSignals[rig] = nil
			end)
		end
		local Track = LoadAnimation.pose(humanoid, "Weapon", "grip", nil)
		UnequippedSignals[rig]:Once(function()
			Track:Stop()
		end)
		
		
	end,

	_unequip = function(rig: Model, humanoid: Humanoid, tool: Model)
		if UnequippedSignals[rig] then
			UnequippedSignals[rig]:Fire()
		end
	end,
}

f.auto = f.click

return f