--!strict
-- Written by Grok
-- Queries/SweepArc.lua

local Spatial = require(game.ServerScriptService.Root.Other.MovesAsync.SpatialQuery)

local ARC_ANGLE_DEG    = 140    -- wide swing
local ARC_RADIUS       = 13     -- greatsword a bit longer
local ARC_HEIGHT       = 8

local DOT_THRESHOLD = math.cos(math.rad(ARC_ANGLE_DEG / 2))

return function(rig: Model, chumanoid: CHumanoid, direction: Vector3): {[Model]: true}
	local root = rig.PrimaryPart or rig:FindFirstChild("HumanoidRootPart")
	if not root then return {} end

	local origin  = root.Position
	local forward = direction.Unit
	local right   = forward:Cross(Vector3.yAxis).Unit
	local params  = chumanoid:getOverlapParams()

	-- Large forward-biased sphere → filter with angle
	local parts = Spatial.query(origin, ARC_RADIUS * 1.1, params)

	local seen: {[Model]: true} = {}

	for _, part in parts do
		local model = part:FindFirstAncestorWhichIsA("Model")
		if not model then continue end
		seen[model] = true
	end

	return seen
end