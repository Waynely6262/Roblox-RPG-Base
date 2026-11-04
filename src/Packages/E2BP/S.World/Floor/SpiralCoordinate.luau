-- Written by ChatGPT

-- Returns (x, y) for n >= 1 in a square spiral
local function spiralCoord(n: number): (number, number)
	assert(n >= 1 and n % 1 == 0, "n must be an integer >= 1")

	if n == 1 then
		return 0, 0
	end

	local k = math.ceil((math.sqrt(n) - 1) / 2)
	local t = 2 * k + 1
	local m = t * t
	local d = m - n
	local side = 2 * k

	if d < side then
		-- right side, going up
		return k, -k + 1 + d
	elseif d < 2 * side then
		-- top side, going left
		return k - 1 - (d - side), k
	elseif d < 3 * side then
		-- left side, going down
		return -k, k - 1 - (d - 2 * side)
	else
		-- bottom side, going right
		return -k + 1 + (d - 3 * side), -k
	end
end

return spiralCoord