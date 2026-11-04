--!strict
-- Written by Grok
-- Queries/ArrowProjectile.lua

local Projectiles = require(game.ServerScriptService.Root.Other.MovesAsync.CastUtil) -- adjust path
local Spatial     = require(game.ServerScriptService.Root.Other.MovesAsync.SpatialQuery)
local LVGet = require(game.ServerScriptService.Root.RemoteReceivers.LookVectors)

local ARROW_SPEED     = 450     -- studs/sec — feels good for Roblox
local ARROW_MAX_DIST  = 300
local ARROW_RADIUS    = .5     -- thin hitbox
local ARROW_GRAVITY = 10

return function(rig: Model, chumanoid: any, charDir: Vector3, pos: Vector3)
	local root = rig.PrimaryPart or rig:FindFirstChild("HumanoidRootPart")
	if not root then return {} end

	
	local origin     = root.Position + Vector3.new(0, 3, 0)  -- slightly above
	local params     = chumanoid:getRaycastParams()          -- raycast params
	local oParams    = chumanoid:getOverlapParams()          -- overlap params (may differ)
	local direction = pos - origin

	local result = Projectiles.g_sphereQueryAsync(
		origin,
		ARROW_RADIUS,
		direction,
		ARROW_MAX_DIST,
		ARROW_SPEED * chumanoid.combat_stats.AttackSpeed,
		ARROW_GRAVITY,
		params,          -- raycast filter
		oParams,         -- initial overlap filter
		nil              -- no dt callback for now
	)

	if not result then return {} end

	local hitModel = result.Instance:FindFirstAncestorWhichIsA("Model")
	if not hitModel then return {} end

	return {[hitModel] = true}
end