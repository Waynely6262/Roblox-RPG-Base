--!strict
-- Written by Waynely
-- Refined version of the TweenObject utility class

local RenderStepped: RBXScriptSignal = 
	game:GetService("RunService"):IsServer() and game:GetService("RunService").Heartbeat or game:GetService("RunService").RenderStepped

local EasingFunctions = require(game.ReplicatedStorage.Modules.Utility.EasingFunctions)

local TweenCallback = {}
local Class = {}
Class.__index = Class
TweenCallback.Class = Class


export type Class = typeof(setmetatable({}:: {
	callback: (number) -> (),
	_cnxn: RBXScriptConnection?,
	a: number,
	t: number,
	ease: (number) -> (number),
}, Class))

local linear = function(x) return x end

local function AssertEasingFunction(EasingFunction: ((number) -> (number)) | string | nil): (number) -> (number)

	if typeof(EasingFunction) == "string" then
		if EasingFunctions then
			return EasingFunctions[EasingFunction:: string] or linear
		else
			warn(`A string was given, but the EasingFunctions library has not been defined; defaulting to built-in Linear`)
		end
	elseif typeof(EasingFunction) == "function" then
		return EasingFunction
	end
	return linear
end

-- connected runs for smooth overwrites
function TweenCallback.new(currentAlpha: number, duration: number, EasingFunction: ((number) -> (number)) | string?, Callback: (a: number) -> ()): Class

	local self = {
		callback = Callback;
		ease = AssertEasingFunction(EasingFunction);
		_cnxn = nil:: RBXScriptConnection?;
		a = currentAlpha;
		t = duration;
	}

	return setmetatable(self, Class):: Class

end
-- run once
function TweenCallback.run(duration: number, EasingFunction: ((number) -> (number)) | string?, f: (a: number) -> (), onComplete: () -> ()?)

	local EasingFunction = AssertEasingFunction(EasingFunction)
	local t = 0

	local before = os.clock()

	local cnxn: RBXScriptConnection; cnxn = RenderStepped:Connect(function()
		local now = os.clock()
		local dt = now - before
		before = now

		t = math.min(duration, t + dt)

		local a = EasingFunction(t / duration)

		f(a)

		if t == duration then
			cnxn:Disconnect()
			if onComplete then
				onComplete()
			end
		end
	end)

	return cnxn

end

function Class.reset(self: Class)

	self:disconnect()
	if self.a ~= 0 then
		self.callback(0)
	end
	self.a = 0
end

function Class.set(self: Class, v: number)

	self:disconnect()
	if self.a ~= v then
		self.callback(v)
	end
	self.a = v
end

function Class.play(self: Class, new: number, onComplete: () -> ()?)
	-- endfunc only triggers when tween completed successfully
	self:disconnect()
	local initial = self.a;
	if initial == new then self.callback(new) if onComplete then onComplete() end return end

	local t = 0
	local before = os.clock()

	self._cnxn = RenderStepped:Connect(function()
		local now = os.clock()
		local dt = now - before
		before = now

		t = math.min(self.t, t + dt)

		local a = self.ease(t / self.t)

		local v = initial + (new - initial) * a

		self.a = v
		self.callback(v)

		if t == self.t then
			self:disconnect()
			if onComplete then
				onComplete()
			end
		end
	end)
end

function Class.disconnect(self: Class)
	if self._cnxn then
		self._cnxn:Disconnect()
		self._cnxn = nil
	end
end

return TweenCallback