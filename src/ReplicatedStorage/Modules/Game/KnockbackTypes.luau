--!strict
local ReplicatedStorage = game.ReplicatedStorage

local EasingFunctions = require(ReplicatedStorage.Modules.Utility.EasingFunctions)
local Heartbeat = game:GetService("RunService").Heartbeat

local cfcnxns: {[BasePart]: RBXScriptConnection} = {}

local types = {

	impulse = function(hrp: BasePart, v: Vector3)
		hrp.AssemblyLinearVelocity += v
	end,
	
	reset_impulse = function(hrp: BasePart, v: Vector3)
		hrp.AssemblyLinearVelocity = v
	end,
	
	reset = function(hrp: BasePart)
		hrp.AssemblyLinearVelocity = Vector3.zero
	end,
	

	knockback = function(hrp: BasePart, sourcePoint: Vector3, magnitude: number)

		local v = (hrp.Position - sourcePoint)

		if v.Magnitude > 0.0001 then
			v = v.Unit * magnitude
		end

		v = Vector3.new(v.X, 10, v.Z) 

		hrp.AssemblyLinearVelocity += v
	end,

	cframe = function(hrp: BasePart, cf1: CFrame, dur: number?)

		if cfcnxns[hrp] then cfcnxns[hrp]:Disconnect() end

		if dur and dur > 0 then

			local cf0 = hrp.CFrame
			local t0 = os.clock()

			cfcnxns[hrp] = Heartbeat:Connect(function()
				local t = math.min(os.clock() - t0, dur)
				hrp.CFrame = cf0:Lerp(cf1, t / dur) 
				if t == dur then
					cfcnxns[hrp]:Disconnect()
					cfcnxns[hrp] = nil
				end
			end)
		else
			hrp.CFrame = cf1
		end
	end,

	cf_ease = function(hrp: BasePart, cf1: CFrame, f_name: string, dur: number)

		local f = assert(EasingFunctions[f_name], tostring(f_name) .. " is not a valid easing function")
		if cfcnxns[hrp] then cfcnxns[hrp]:Disconnect() end

		local cf0 = hrp.CFrame

		local t0 = os.clock()

		cfcnxns[hrp] = Heartbeat:Connect(function()
			local t = math.min(os.clock() - t0, dur)

			local a = f(t / dur)
			hrp.CFrame = cf0:Lerp(cf1, t / dur) 
			if t == dur then
				cfcnxns[hrp]:Disconnect()
			end
		end)


	end,


}

return types