local IsServer = game:GetService("RunService"):IsServer()
local util = {
	clock_offset = nil
}



if IsServer then
	function util.timestamp()
		return DateTime.now().UnixTimestamp
	end
else
	-- client time should, if incorrect, always be LESS than the actual server time in this situation.
	
	util._internal_time_f = os.clock

	function util.offsetResync()
		if IsServer then error("You can't call this method on the server.") end
		local server_time = script.getServerTime:InvokeServer()

		local offset = (server_time - util._internal_time_f())

		util.clock_offset = offset - 1 -- 1 second diff
	end
	
	function util.timestamp()
		return util._internal_time_f() + util.clock_offset
	end
	util.offsetResync()
end



return util
