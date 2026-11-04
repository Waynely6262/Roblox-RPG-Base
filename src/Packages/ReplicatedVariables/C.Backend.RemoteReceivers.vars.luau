--!strict
local vars = {}
local Signal = require(game.ReplicatedStorage.Modules.Utility.Signal)

local reset = Signal.new()
local changed: Signal.Signal<string> = Signal.new()
local longsetted: Signal.Signal<...any> = Signal.new()
local longcleared: Signal.Signal<...any> = Signal.new()
local inserted: Signal.Signal<string, any> = Signal.new()
local removed: Signal.Signal<string, number> = Signal.new()
local indexed: Signal.Signal<string, any, any> = Signal.new()

local function throughPath(t: any, path: {string}): any
	
	for _, i in path do
		t = t[i]
		if not t then
			return nil
		end
	end
	return t
end

-- copies datastore methods
local acts = {
	set = function(k: string, v: any)
		vars[k] = v
		changed:Fire(k, v)
	end,
	
	clear = function()
		vars = {}
		reset:Fire()
	end,
	
	setScope = function(t: {[string]: any})
		vars = t
		reset:Fire()
	end,
	
	insert = function(k: string, v: any)
		table.insert(vars[k]:: {any}, v)
		inserted:Fire(k, v)
	end,
	
	remove = function(k: string, i: number)
		table.remove(vars[k]:: {any}, i)
		removed:Fire(k, i)
	end,
	
	setIndex = function(k: string, i: any, v: any)
		(vars[k]:: {[any]: any})[i] = v
		indexed:Fire(k,i,v)
	end,
	
	longset = function(...) -- at least two args are required: key1, value
		
		local args = {...}:: {string}
		
		local len = #args
		
		local v = table.remove(args, len)
		
		local k = table.remove(args, len - 1)
		local t = throughPath(vars, args):: {[typeof(k)]: typeof(v)}
		t[k] = v
		
		longsetted:Fire(...)
	end,
	
	longclear = function(...) -- at least one arg is required: key

		local args = {...}:: {string}

		local len = #args

		local k = table.remove(args, len)
		local t = throughPath(vars, args):: {[typeof(k)]: typeof(v)}
		t[k] = nil

		longcleared:Fire(...)
	end,

	
	
}

return {
	onInvoke = function(act: string, ...)
		return acts[act](...)
	end;
	changed = changed;
	reset = reset;
	inserted = inserted;
	removed = removed;
	indexed = indexed;
	longsetted = longsetted;
	longcleared = longcleared;
	getCurrentVariablesArray = function() return vars end;
	
	get = function(...: string)
		return throughPath(vars, {...})
	end,
}