--!strict
local RenderStepped = 
	game:GetService("RunService")[game:GetService("RunService"):IsServer() and "Heartbeat" or "RenderStepped"]:: RBXScriptSignal

local Lerp = require(Game.ReplicatedStorage.Modules.Utility.Lerp)

local defaultEase = function(x: number) return x end

local jobs: {[any]: RBXScriptConnection} = {}

local function Tween(s: any, p1: {[string]: any}, ease: (x: number) -> (number), t1: number, endfunc: (number) -> ()?)
	-- endfunc only triggers when tween completed successfully
	ease = ease or defaultEase
	local p0: {[string]: any} = {}

	for i, fv in p1 do
		if s[i] ~= fv then 
			p0[i] = s[i]
		end
	end
	
	if not next(p0) then return end
	
	if jobs[s] then jobs[s]:Disconnect() end
	
	local flip_t1 = 1/t1
	
	local t = 0
	
	local before = os.clock()
	
	jobs[s] = RenderStepped:Connect(function()
		local now = os.clock()
		local dt = now - before
		before = now
		
		t = math.min(t1, t + dt)

		local a = t * flip_t1 
		
		local b = ease(a)

		for i, v in p0 do
			s[i] = Lerp(v, p1[i], b)
		end

		if t == t1 then
			jobs[s]:Disconnect()
			jobs[s] = nil
			if endfunc then
				endfunc(dt)
			end
		end
	end)
	


end

return Tween