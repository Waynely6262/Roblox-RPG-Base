--!strict
local RunService = game:GetService("RunService")
local Heartbeat = RunService.Heartbeat

local Projectiles = {}

Projectiles.DefaultGravity = workspace.Gravity
Projectiles.DefaultStepTime = 0.016     -- roughly one physics step

-- Optional tracer module support
local tracer = script:FindFirstChild("Tracers") and require(script.Tracers)

local RaycastFn = (tracer and tracer.Raycast or workspace.Raycast) :: (
	workspace: Workspace,
	origin: Vector3,
	direction: Vector3,
	params: RaycastParams?
) -> RaycastResult?

local SpherecastFn = (tracer and tracer.Spherecast or workspace.Spherecast) :: (
	workspace: Workspace,
	origin: Vector3,
	radius: number,
	direction: Vector3,
	params: RaycastParams?
) -> RaycastResult?

export type QueryResult = {
	Position: Vector3,
	Instance: Instance,
	Material: Enum.Material,
	Normal: Vector3,
	Distance: number,
}

local function makeResult(hit: RaycastResult, totalDistance: number): QueryResult
	return {
		Position = hit.Position,
		Instance = hit.Instance,
		Material = hit.Material,
		Normal = hit.Normal,
		Distance = totalDistance,
	}
end

local function checkInitialOverlap(pos: Vector3, radius: number?, overlapParams: OverlapParams?): QueryResult?
	local radius = radius or 0.1

	local parts = workspace:GetPartBoundsInRadius(pos, radius, overlapParams)
	if #parts == 0 then
		return nil
	end

	local first = parts[1]
	return {
		Position = pos,
		Instance = first,
		Material = first.Material or Enum.Material.Plastic,
		Normal = Vector3.yAxis, -- arbitrary / can be improved
		Distance = 0,
	}
end

-- ────────────────────────────────────────────────────────────────
--  Async versions (stepped simulation using Heartbeat)
-- ────────────────────────────────────────────────────────────────

local function simulateProjectileAsync(
	pos0: Vector3,
	dir0: Vector3,
	maxDistance: number,
	speed: number,
	raycastParams: RaycastParams?,
	overlapParams: OverlapParams?,
	radius: number?,
	gravity: number?,
	dtCallback: ((currentPos: Vector3, nextPos: Vector3, time: number) -> ())?
): QueryResult?

	local initialHit = checkInitialOverlap(pos0, radius, overlapParams)
	if initialHit then
		return initialHit
	end

	dir0 = dir0.Unit

	local gravity = gravity or 0
	local forwardXZ = dir0 * Vector3.new(speed, 0, speed)
	local initialYVel = dir0.Y * speed

	local startTime = os.clock()
	local previousUpdateTime = os.clock()
	local totalDistance = 0
	local currentPos = pos0

	local thread = coroutine.running()
	local connection: RBXScriptConnection

	connection = Heartbeat:Connect(function(realDt)
		local now = os.clock()
		local dt = math.min(now - previousUpdateTime, 0.1) -- cap dt
		local t = now - startTime
		
		previousUpdateTime = now

		local yVelocity = initialYVel - gravity * t
		local stepVelocity = Vector3.new(forwardXZ.X, yVelocity, forwardXZ.Z)
		local stepVector = stepVelocity * dt
		local stepDistance = stepVector.Magnitude

		if totalDistance + stepDistance > maxDistance then
			stepVector = stepVector.Unit * (maxDistance - totalDistance)
			stepDistance = maxDistance - totalDistance
		end

		local hit: RaycastResult?
		if radius and radius > 0 then
			hit = SpherecastFn(workspace, currentPos, radius, stepVector, raycastParams)
		else
			hit = RaycastFn(workspace, currentPos, stepVector, raycastParams)
		end

		totalDistance += stepDistance

		if hit then
			connection:Disconnect()
			totalDistance = totalDistance - stepDistance + hit.Distance
			
			-- stepVector is clamped to maxDistance beforehand so we don't have to worry about sanitizing this here
			coroutine.resume(thread, makeResult(hit, totalDistance))

			return
		end

		if totalDistance >= maxDistance then
			connection:Disconnect()
			coroutine.resume(thread, nil)
			return
		end
		local nextPos = currentPos + stepVector
		
		if dtCallback then
			dtCallback(currentPos, nextPos, t)
		end

		currentPos = nextPos
	end)

	local result = coroutine.yield() :: QueryResult?

	return result
end

function Projectiles.g_pointQueryAsync(
	pos0: Vector3,
	dir0: Vector3,
	maxDistance: number,
	speed: number,
	gravity: number?,
	params: RaycastParams?,
	dtCallback: ((Vector3, Vector3, number) -> ())?
): QueryResult?
	return simulateProjectileAsync(pos0, dir0, maxDistance, speed, params, nil, nil, gravity or Projectiles.DefaultGravity, dtCallback)
end

function Projectiles.pointQueryAsync(
	pos0: Vector3,
	dir0: Vector3,
	maxDistance: number,
	speed: number,
	params: RaycastParams?,
	dtCallback: ((Vector3, Vector3, number) -> ())?
): QueryResult?
	return simulateProjectileAsync(pos0, dir0, maxDistance, speed, params, nil, nil, nil, dtCallback)
end

function Projectiles.g_sphereQueryAsync(
	pos0: Vector3,
	radius: number,
	dir0: Vector3,
	maxDistance: number,
	speed: number,
	gravity: number?,
	rayParams: RaycastParams?,
	overlapParams: OverlapParams?,
	dtCallback: ((Vector3, Vector3, number) -> ())?
): QueryResult?
	return simulateProjectileAsync(pos0, dir0, maxDistance, speed, rayParams, overlapParams, radius, gravity or Projectiles.DefaultGravity, dtCallback)
end

function Projectiles.sphereQueryAsync(
	pos0: Vector3,
	radius: number,
	dir0: Vector3,
	maxDistance: number,
	speed: number,
	rayParams: RaycastParams?,
	overlapParams: OverlapParams?,
	dtCallback: ((Vector3, Vector3, number) -> ())?
): QueryResult?
	return simulateProjectileAsync(pos0, dir0, maxDistance, speed, rayParams, overlapParams, radius, nil, dtCallback)
end

-- ────────────────────────────────────────────────────────────────
--  Instant (blocking) versions – stepped but no yield
-- ────────────────────────────────────────────────────────────────

local function simulateInstant(
	pos0: Vector3,
	dir0: Vector3,
	maxDistance: number,
	speed: number,
	params: RaycastParams?,
	overlapParams: OverlapParams?,
	radius: number?,
	gravity: number?
): QueryResult?

	local initialHit = checkInitialOverlap(pos0, radius, overlapParams)
	if initialHit then
		return initialHit
	end

	dir0 = dir0.Unit

	local gravity = gravity or 0
	local horizontal = dir0 * Vector3.new(speed, 0, speed)
	local y0 = dir0.Y * speed

	local t = 0
	local traveled = 0
	local pos = pos0

	while traveled < maxDistance do
		local dt = Projectiles.DefaultStepTime
		local yvel = y0 - gravity * t
		local vel = horizontal + Vector3.new(0, yvel, 0)
		local stepVec = vel * dt
		local stepDist = stepVec.Magnitude
		
		if traveled + stepDist > maxDistance then
			stepDist = maxDistance - traveled
			stepVec = stepVec.Unit * stepDist
		end
		
		if stepDist > 500 then -- roblox limitation
			stepDist = 500
			stepVec = stepVec.Unit * stepDist
		end

		local hit: RaycastResult?
		if radius and radius > 0 then
			hit = SpherecastFn(workspace, pos, radius, stepVec, params)
		else
			hit = RaycastFn(workspace, pos, stepVec, params)
		end

		traveled += stepDist

		if hit then
			traveled = traveled - stepDist + hit.Distance
			return makeResult(hit, traveled)
		end

		pos += stepVec
		t += dt
	end

	return nil
end

function Projectiles.g_pointQueryInstant(
	pos0: Vector3,
	dir0: Vector3,
	maxDistance: number,
	speed: number,
	gravity: number?,
	params: RaycastParams?
): QueryResult?
	return simulateInstant(pos0, dir0, maxDistance, speed, params, nil, nil, gravity or Projectiles.DefaultGravity)
end

function Projectiles.pointQueryInstant(
	pos0: Vector3,
	dir0: Vector3,
	maxDistance: number,
	params: RaycastParams?
): QueryResult?
	-- For instant non-gravity → can use long raycasts if desired
	-- But keeping consistent stepped behaviour for now
	return simulateInstant(pos0, dir0, maxDistance, 999999, params, nil, nil, nil)
end

function Projectiles.sphereQueryInstant(
	pos0: Vector3,
	radius: number,
	dir0: Vector3,
	maxDistance: number,
	params: RaycastParams?,
	overlapParams: OverlapParams?
): QueryResult?
	-- For instant non-gravity → can use long raycasts if desired
	-- But keeping consistent stepped behaviour for now
	return simulateInstant(pos0, dir0, maxDistance, 999999, params, overlapParams, radius, nil)
end


-- Optional: keep your fast straight-line version as alternative
function Projectiles.pointQueryInstantFast(
	pos0: Vector3,
	dir0: Vector3,
	maxDistance: number,
	params: RaycastParams?
): QueryResult?
	dir0 = dir0.Unit
	local remaining = maxDistance
	local pos = pos0

	while remaining > 0 do
		local castDist = math.min(500, remaining)
		local hit = RaycastFn(workspace, pos, dir0 * castDist, params)
		if hit then
			return makeResult(hit, maxDistance - remaining + hit.Distance)
		end
		pos += dir0 * castDist
		remaining -= castDist
	end

	return nil
end

Projectiles.BezierCast = require(script.BezierCast)

return Projectiles