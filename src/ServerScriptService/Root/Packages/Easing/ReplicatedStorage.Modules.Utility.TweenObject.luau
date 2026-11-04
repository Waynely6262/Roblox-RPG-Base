--!strict
local ReplicatedStorage = game.ReplicatedStorage
local Lerpable = {
	Color3 = true;
	Vector3 = true;
	CFrame = true;
	UDim2 = true;
}

local RenderStepped = 
	game:GetService("RunService")[game:GetService("RunService"):IsServer() and "Heartbeat" or "RenderStepped"]:: RBXScriptSignal

local Private = setmetatable({}, {__mode = "k"}):: {[any]: any}

local TweenObject = {}
TweenObject.__index = TweenObject

export type TweenObject<T> = typeof(setmetatable({}:: {
	connection: RBXScriptConnection?,
	v: T,
	ease: (number) -> (number),
}, TweenObject))

local linear = function(x) return x end
-- use TweenCallback instead
@deprecated
function TweenObject.new<T>(currentValue: T, duration: number, EasingFunction: ((number) -> (number))?): TweenObject<T>

	local self = {
		ease = (EasingFunction or linear):: (number) -> (number);
		connection = nil:: RBXScriptConnection?;
		v = currentValue;
	}

	Private[self] = {
		speed = 1 / duration;
		duration = duration;
	} 

	return setmetatable(self, TweenObject)

end

function TweenObject.setDuration(self: any, n: number)
	Private[self].speed = 1/n
	Private[self].duration = n;
end

function TweenObject:getDuration()
	return Private[self].duration
end

function TweenObject.play<T>(self: any, new: T, f: (value: T, unit_alpha: number) -> (), onComplete: () -> ()?)
	-- endfunc only triggers when tween completed successfully

	self:disconnect()
	local t = 0

	local before = os.clock()

	local current = self.v;

	local duration = Private[self].duration
	local speed = Private[self].speed

	if Lerpable[typeof(new)] then
		self.connection = RenderStepped:Connect(function(dt: number)
			local now = os.clock()
			local dt = now - before
			before = now

			t = math.min(duration, t + dt)

			local v = self.ease(t * speed)

			self.v = (current:: {Lerp: (T, T, number) -> (T)}):Lerp(new, v)
			f(self.v, v)

			if t == duration then
				(self.connection:: RBXScriptConnection):Disconnect()
				self.connection = nil
				if onComplete then onComplete() end
			end
		end)
	else
		self.connection = RenderStepped:Connect(function(dt: number)
			local now = os.clock()
			local dt = now - before
			before = now

			t = math.min(duration, t + dt)

			local v0 = self.ease(t * speed)
			local v1 = 1 - v0

			self.v = (v1 * current:: any + v0 * new:: any)
			f(self.v, v0)

			if t == duration then
				(self.connection:: RBXScriptConnection):Disconnect()
				self.connection = nil
			end
		end)
	end
end

function TweenObject:disconnect()
	if self.connection then
		(self.connection:: RBXScriptConnection):Disconnect()
	end
end

-- weak ref test
--task.defer(function()
--	TweenObject.new(0,0)
--	print(Private)
--	while next(Private) do
--		print("waiting")
--		task.wait(10)
--	end
--	print("garbage collected")
--	print(Private)
--end)

-- yo how do I FREAKING. USE. "<>". HELP ME. IT DuzzNT. WORK.
return TweenObject