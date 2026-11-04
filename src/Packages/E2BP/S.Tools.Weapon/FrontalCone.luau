--!strict
-- Written by Grok
-- Queries/FrontalCone.lua

local Spatial = require(game.ServerScriptService.Root.Other.MovesAsync.SpatialQuery) -- adjust path

local CONE_ANGLE_DEG   = 90     -- total angle (45° each side)
local CONE_RADIUS      = 12     -- max reach
local DEPTH_MULTIPLIER = 1.3    -- slightly deeper than wide (feels better)

local CONE_DOT_THRESHOLD = math.cos(math.rad(CONE_ANGLE_DEG / 2))

return function(rig: Model, chumanoid: CHumanoid, direction: Vector3)
	local root = rig.PrimaryPart or rig:FindFirstChild("HumanoidRootPart")
	if not root then return {} end

	local origin     = root.Position + Vector3.new(0, 2, 0)  -- roughly torso height
	local forward    = direction.Unit
	local params     = chumanoid:getOverlapParams()

	-- Use capsule-like shape: box oriented forward
	local mid        = origin + forward * (CONE_RADIUS * 0.5 * DEPTH_MULTIPLIER)
	local cf         = CFrame.new(mid, mid + forward)
	local boxSize    = Vector3.new(
		CONE_RADIUS,
		CONE_RADIUS * 0.8,          -- height
		CONE_RADIUS * DEPTH_MULTIPLIER
	)

	local parts = Spatial.fromTo(origin, origin + forward * CONE_RADIUS * DEPTH_MULTIPLIER, CONE_RADIUS * 0.6, params)
	-- or use Spatial.query(origin, CONE_RADIUS * 1.1, params) if you prefer sphere + filtering

	local seen: {[Model]: boolean} = {}

	for _, part in parts do
		local model = part:FindFirstAncestorWhichIsA("Model")
		if not model then continue end
			seen[model] = true
	end

	return seen
end