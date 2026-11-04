--!strict
local BinaryHeap = {}
BinaryHeap.__index = BinaryHeap

local Class = {}

function Class.new(t)
	
	if t then
		for i, v in t:: {any} do
			assert(typeof(i) == "number" , "the given table must only have natural numbers as indexes")
		end
	end
	
	local self = setmetatable({
		heap = t or {};
		len = t and #(t:: {any}) or 0;
		comp = function(a,b) return a < b end;
	}, BinaryHeap)
	
	return self
end

function BinaryHeap:setComparator(comp: (A: any,B: any) -> (boolean))
	self.comp = comp
end

function BinaryHeap:insert(n)
	
	local i = self.len + 1
	self.len = i
	
	self.heap[i] = n
	while i > 1 do
		local p_i = i // 2
		if self.comp(n, self.heap[p_i]) then
			self.heap[p_i], self.heap[i] = n, self.heap[p_i]
			i = p_i
		else
			break
		end
	end
end

function BinaryHeap:isEmpty(): boolean
	return self.len == 0
end

function BinaryHeap:pop()
	if self.len == 0 then return nil end
	
	local v = self.heap[1]
	self.heap[1] = self.heap[self.len]
	self.heap[self.len] = nil
	self.len -= 1
	local n = 1
	while true do
		
		local c1 = self.heap[2 * n]
		if not c1 then break end
		local c2 = self.heap[2 * n + 1]
		
		local small
		local small_i
		
		if (not c2) or self.comp(c1, c2) then
			small = c1
			small_i = 2 * n
		else
			small = c2
			small_i = 2 * n + 1
		end
		
		if self.comp(small, self.heap[n]) then
			self.heap[n], self.heap[small_i] = small, self.heap[n]
		else
			break
		end
		n = small_i
	end
	
	
	return v
end

return Class