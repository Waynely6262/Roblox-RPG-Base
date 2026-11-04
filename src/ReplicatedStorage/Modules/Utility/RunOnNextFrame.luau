--!strict

--[[
	runs a function at the tail end of a frame
]]

----------------------------------------------------------------------------------------------------
local RunService = game:GetService("RunService")
----------------------------------------------------------------------------------------------------
local cache: {[() -> ()]: true} = {}

local binded = false

return function(runner: () -> ())
	if cache[runner] then
		return
	end
	cache[runner] = true

	if binded then --> already queued up to run
		return
	end
	binded = true
	RunService.Heartbeat:Once(function()
		for running in cache do
			task.spawn(running)
		end

		-->> resetting values
		binded = false
		table.clear(cache)
	end)
end