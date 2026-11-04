--!strict
local DEFAULT = game:GetService("RunService").Heartbeat
return function(intrvl: number, c: RBXScriptSignal?, f: (elapsed: number, ...unknown)-> ())
	c = c or DEFAULT
	local prv = os.clock()
	local cnxn = c:Connect(function(...)
		local now = os.clock()
		
		local passed = now - prv

		if passed >= intrvl then
			prv = now
			
			f(passed, ...)
		end
		
	end)
	
	return cnxn
end