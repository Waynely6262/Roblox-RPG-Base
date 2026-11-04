-- use \t if you want

local TAB = "    "

local function getTabs(depth)
	local str = ""
	for i = 1, depth do
		str = str .. TAB
	end
	return str
end

local function f(t: {[any]: any}, depth: number?)
	local depth = depth or 1
	if typeof(t) ~= "table" then return tostring(t) end
	
	local tabs = getTabs(depth)
	
	
	local str = "{\n"
	
	
	for i, v in t do
		str = str .. tabs .. `[{i}] = {f(v, depth + 1)},\n`
	end
	return str .. getTabs(depth - 1) .. "}"
end
return f