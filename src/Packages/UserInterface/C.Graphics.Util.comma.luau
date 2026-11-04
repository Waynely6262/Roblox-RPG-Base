-- @author chatgpt
return function(n: number)
	local str = tostring(n)
	local result = str:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	-- Remove leading comma if any (for numbers < 1000)
	if result:sub(1, 1) == "," then
		result = result:sub(2)
	end
	return result
end