local Effect = {}
local Class = {}
Class.__index = Class
Effect.Class = Class

function Effect.new(duration: number, level: number?)
	
	local finish = os.clock() + duration
	
	local self = {
		t = duration;
		t1 = finish;
		lv = level;
	}
	
	return setmetatable(self, Class):: Effect
end


function Class:clear()
	self.t1 = os.clock()
end

function Class:addDuration(n: number, max: number?)
	if max then
		self.t = math.min(self.t + n, max)
	else
		self.t1 += n
	end
end

function Class:isActive()
	return os.clock() < self.t1
end

export type Effect = typeof(setmetatable({}:: {
	t: number,
	t1: number,
	lv: number,
}, Class))

return Effect