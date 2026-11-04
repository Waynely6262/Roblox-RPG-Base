--!strict
local Class = {}	
Class.__index = Class

local Roller = {}

function Roller.new(t: {[string]: number}?)
	
	local self = {
		Pool = {}:: {{n: string, w: number; tw: number}};
		Outcomes = {}:: {[string]: {n: string, w: number; tw: number}};
		TotalWeight = 0;
	}
	
	setmetatable(self, Class)
	
	if t then
		self:importOutcomes(t)
	end
	
	return self
end

function Class.addOutcome(self: Class, name: string, weight: number)
	if weight <= 0 then
		warn(`Skipped '{name}' because invalid weight ({weight})`)
		return
	end
	
	if self.Outcomes[name] then 
		warn(`The item '{name}' is already in the pool. `)
	else
		
		local previous_total_weight = #self.Pool > 0 and (self.Pool[#self.Pool]).tw or 0
		local new_total_weight = previous_total_weight + weight
		local candidate = {n = name; w = weight; tw = new_total_weight}
		self.Outcomes[name] = candidate
		table.insert(self.Pool, candidate)
		self.TotalWeight = new_total_weight
	end

	
	
end
-- receives a key-value name=weight dictionary and inserts it into the loot pool.
function Class.importOutcomes(self: Class, t: {[string]: number})
	for n, w in t do
		self:addOutcome(n,w)
	end
end

function Class.chanceOf(self: Class, n: string)
	
	if not self.Outcomes[n] then return 0 end
	
	return self.Outcomes[n].w / self.TotalWeight
	
end

-- determines the next outcome using binary search
function Class.nextOutcome(self: Class): string?
	
	if not next(self.Pool) then return nil end
	
	local nextWeight = math.random() * self.TotalWeight

	local low = 1
	local high = 1 + #self.Pool -- Add 1 for edge case: #self.Pool = 2, element to be found at i=2; (1 + 2) // 2 = 1, so 2 will be skipped

	while low <= high do
		local mid = (low + high) // 2
		
		local query_up = self.Pool[mid]
		local query_down = self.Pool[mid - 1]
		
		if query_up.tw >= nextWeight then
			if ((query_down and query_down.tw or 0) < nextWeight) then
				return query_up.n
			else
				high = mid - 1
			end
		elseif query_up.tw < nextWeight then
			low = mid + 1
		end
	end

	error(`No candidate found. Are you sure the pool isn't empty? (w={nextWeight})`)

end

export type Class = typeof(Roller.new())
return Roller