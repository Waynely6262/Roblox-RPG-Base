return function(count,callback: () -> (),...): (boolean, any | {string})
	if count > 5 then warn(`Attempt {count} will take {2^(count-1)} seconds to reach.`) end

	local results = {}

	for i = 1, count do
		local s,r = pcall(callback,...)

		if s then
			return s,r
		end
		warn(`Request failed ({i}/{count}): {r}`)
		table.insert(results, r)
		task.wait(2^i)
	end
	return false, results
end