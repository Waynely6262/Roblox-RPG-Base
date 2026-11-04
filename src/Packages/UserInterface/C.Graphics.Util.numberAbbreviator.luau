local suffixes = { "T", "B", "M", "K" }
local amts = {
	1e12;
	1e9;
	1e6;
	1e3;
}

local n_suffixes = #suffixes

@native
local function abbreviateNumber(n: number): string
	
	if n >= math.huge then
		return tostring(n)
	end
	
	for i, v in amts do
		if math.abs(n) >= v then
			return string.format("%.1f%s", n / v, suffixes[i])
		end
	end

	return tostring(n)
end



return abbreviateNumber
