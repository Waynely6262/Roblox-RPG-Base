--!strict
-- Written by Grok
-- Queries/SpearThrust.lua

local Spatial = require(game.ServerScriptService.Root.Other.MovesAsync.SpatialQuery)

local SPEAR_LENGTH = 20
local SPEAR_RADIUS = 3.5   -- quite thin

return function(rig: Model, chumanoid: CHumanoid, direction: Vector3)
	local root = rig.PrimaryPart or rig:FindFirstChild("HumanoidRootPart"):: BasePart?
	if not root then return {} end

	local origin  = root.Position + Vector3.new(0, 2, 0)
	local forward = direction.Unit
	local params  = chumanoid:getOverlapParams()

	-- Oriented capsule approximation with GetPartBoundsInBox
	local mid     = origin + forward * (SPEAR_LENGTH / 2)
	local cf      = CFrame.new(mid, mid + forward)
	local size    = Vector3.new(SPEAR_RADIUS * 2, SPEAR_RADIUS * 2, SPEAR_LENGTH)

	local parts = workspace:GetPartBoundsInBox(cf, size, params)
	-- or Spatial.fromTo(origin, origin + forward * SPEAR_LENGTH, SPEAR_RADIUS, params)

	local seen: {[Model]: boolean} = {}
	for _, part in parts do
		local model = part:FindFirstAncestorWhichIsA("Model")
		if model and not seen[model] then
			seen[model] = true
		end
	end

	return seen
end