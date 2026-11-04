--!strict


local vars: {[Player]: {[string]: any}} = setmetatable({}, {__mode = "k"})

local E = game.ReplicatedStorage.Remotes.MainE

local function throughPath(t: any, path: {string}): any

	for _, i in path do
		t = t[i]
		if not t then
			return nil
		end
	end
	return t
end

local f = {}

function f.get(player: Player, ...): any
	if not player.Parent then 
		return
	end
	return vars[player] and throughPath(vars[player], {...})
end


-- sets a value without replicating on the server
function f.ghostSet(player: Player, k, v)
	if not player.Parent then return end
	E:FireClient(player, "vars", "set", k, v)
end

-- sets a value without replicating to the client
function f.quietSet(player: Player, k, v)
	if not player.Parent then return end
	vars[player][k] = v
end

-- used as a cheaper option than 'longset', by differentiating between a 'longsetted' signal fire and a 'changed' signal fire on the client
function f.set(player: Player, k, v)
	if not player.Parent then return end
	
	vars[player][k] = v
	E:FireClient(player, "vars", "set", k, v)
end


function f.inc(player: Player, k, inc)
	if not player.Parent then return end
	
	vars[player][k] = vars[player][k] or 0
	
	local v = vars[player][k] + inc
	vars[player][k] = v
	E:FireClient(player, "vars", "set", k, v)
end

function f.insert(player: Player, k: string, v: any)
	if not player.Parent then return end

	table.insert(vars[player][k]:: {any}, v)
	
	E:FireClient(player, "vars", "insert", k, v)
end

function f.remove(player: Player, k: string, i: number)
	if not player.Parent then return end

	table.remove(vars[player][k]:: {any}, i)

	E:FireClient(player, "vars", "remove", k, i)
end

function f.setScope(player: Player, t: {[string]: any}?)
	if player.Parent or t == nil then
		vars[player] = t
		if t then
			E:FireClient(player, "vars", "setScope", t)
		end
	end
end


function f.longQuietSet(player: Player, ...)
	local args = {...}:: {string}

	local len = #args

	local v = table.remove(args, len)

	local k = table.remove(args, len - 1)
	local t = throughPath(vars[player], args):: {[typeof(k)]: typeof(v)}
	t[k] = v
end

function f.longGhostSet(player: Player, ...)

	if not player.Parent then return end
	E:FireClient(player, "vars", "longset", ...)
end


function f.longset(player: Player, ...)
	
	if not player.Parent then return end
	local args = {...}:: {string}

	local len = #args

	local v = table.remove(args, len)

	local k = table.remove(args, len - 1)
	local t = throughPath(vars[player], args):: {[typeof(k)]: typeof(v)}
	t[k] = v
	E:FireClient(player, "vars", "longset", ...)
	
end

function f.longclear(player: Player, ...)

	if not player.Parent then return end
	local args = {...}:: {string}

	local len = #args

	local k = table.remove(args, len)
	local t = throughPath(vars[player], args)
	t[k] = nil
	E:FireClient(player, "vars", "longclear", ...)

end

game.Players.PlayerRemoving:Connect(f.setScope:: (Player, any) -> ())

f.variables = vars;

return f