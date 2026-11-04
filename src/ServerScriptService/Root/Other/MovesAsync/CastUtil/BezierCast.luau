--!strict

-- For bezier casting, the 'duration' property of the BezierParams is used for how many seconds it takes to cover one stud

local TweenService = game:GetService("TweenService")

local rand = Random.new()
local function randomPerpendicularVector(v: Vector3)
	return v:Cross(rand:NextUnitVector())
end

local Heartbeat = game:GetService("RunService").Heartbeat

local BezierParams = require(script.Parent.Parent.BezierParams)

local function bezier(origin: Vector3, finalPos: Vector3, Parameters: BezierParams.BezierParams?, f: (CFrame) -> (), DeflectionVector: Vector3?, RCParams: RaycastParams?): (Vector3, RaycastResult?, CFrame)
	local BezierParameters = Parameters or BezierParams.new()
	

	local displacement = (finalPos - origin)
	local length = displacement.Magnitude
	--local duration = length * BezierParameters.Duration


	local lookVector = displacement

	if not DeflectionVector then
		local upVector = randomPerpendicularVector(displacement).Unit
		DeflectionVector = lookVector:Lerp(upVector,BezierParameters.DeflectionAngle / 90)	
	end
	
	DeflectionVector = (DeflectionVector:: Vector3).Unit * length * BezierParameters.DeflectionRelativeSize
	
	-- to account for the duration of the deflection, this is used:
	-- length - DeflectionVector.Unit:Dot(lookVector.Unit) * length * ("percentage of factor affecting duration")
	
	local speed = 1 / ((length - DeflectionVector.Unit:Dot(lookVector.Unit) * length * 0.3) * BezierParameters.Duration) 
	
	
	local rightVector = lookVector:Cross(DeflectionVector:: Vector3)

	local t0 = os.clock()

	local running = coroutine.running()

	local cnxn: RBXScriptConnection
	
	
	local oldPosition: Vector3 = origin
	local returnValue: RaycastResult?
	local cf = CFrame.new(origin)

	local function resume()
		cnxn:Disconnect()
		task.defer(running)
	end
	
	
	cnxn = Heartbeat:Connect(function()

		local a = math.min((os.clock() - t0) * speed, 1)
		
		
		local v0 = TweenService:GetValue(1 - a, BezierParameters.DeflectionEasingStyle, BezierParameters.DeflectionEasingDirection)
		local v1 = TweenService:GetValue(a, BezierParameters.ForwardEasingStyle, BezierParameters.ForwardEasingDirection)


		local displacement = a * (DeflectionVector:: Vector3 * v0 + lookVector * v1)
		local newPosition = origin + displacement
		
		if BezierParameters.MaxSegmentLength and BezierParameters.MaxSegmentLength < displacement.Magnitude then
			resume()
			return
		end
		
		
		
		local instantaneousLookVector = (newPosition - oldPosition)
		
		local result = workspace:Raycast(oldPosition, instantaneousLookVector, RCParams)
		if result then 
			returnValue = result 
			newPosition = result.Position
			resume()
			return
		end
		oldPosition = newPosition

		cf = CFrame.fromMatrix(newPosition,rightVector.Unit, rightVector:Cross(instantaneousLookVector).Unit)
		f(cf)
		if a == 1 then
			resume()
		end
	end)

	coroutine.yield()

	return lookVector.Unit, returnValue, cf
end

local function chainBezier(points: {Vector3}, f: (CFrame) -> (), Params: BezierParams.BezierParams?, deflectionOne: Vector3?, RCParams: RaycastParams?): RaycastResult?

	local lookVector, result = bezier(points[1], points[2], Params, f, deflectionOne, RCParams) 
	
	if result then return result end
	
	local len = #points
	for i = 2, len - 2 do

		lookVector, result = bezier(points[i], points[i + 1], Params, f, lookVector, RCParams)
		if result then return result end
	end
	local _, result = bezier(points[len - 1], points[len], Params, f, lookVector, RCParams)
	
	return result
end


return {
	fromStartFinishAsync = bezier;
	fromPointsAsync = chainBezier;
}